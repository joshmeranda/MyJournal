package organize

import (
	"errors"
	"fmt"
	"os"
	"path"

	git "github.com/go-git/go-git/v5"
	"github.com/otiai10/copy"
	"github.com/samber/lo"
)

// getRepoPaths returns the path for the repositories origin remote and any
// symlinks to that path that need to be created.
func getRepoPaths(config Config, originalName string, remotes map[string]*git.Remote) (string, []string, error) {
	if len(remotes) == 0 {
		return "", nil, fmt.Errorf("received no remotes")
	}

	origin, found := remotes["origin"]
	if !found {
		return "", nil, fmt.Errorf("no origin remote found")
	}

	owner, name, err := getRemoteOwnerAndName(origin)
	if err != nil {
		return "", nil, fmt.Errorf("could not determine remote owner and name '%s': %w", origin, err)
	}

	fetchPath := path.Join(config.Destination, owner, name)
	if len(remotes) == 1 {
		return fetchPath, nil, nil
	}

	switch config.RemoteStrategy {
	case StrategyOrigin:
		return fetchPath, nil, nil
	case StrategySymlink:
		symlinks := make([]string, 0, len(remotes)-1)
		for name, remote := range remotes {
			if name == "origin" {
				continue
			}

			owner, name, err := getRemoteOwnerAndName(remote)
			if err != nil {
				return "", nil, fmt.Errorf("could not determine remote owner and name '%s': %w", remote.Config().Name, err)
			}

			symlinks = append(symlinks, path.Join(config.Destination, owner, name))
		}

		return fetchPath, symlinks, nil
	case StrategyDefault, StrategyQuarantine:
		return path.Join(config.QuarantinePath(), originalName), nil, nil
	default:
		return "", nil, fmt.Errorf("encountered unsupported remote strategy")
	}
}

func mapRemotes(remotes []*git.Remote) map[string]*git.Remote {
	mapped := make(map[string]*git.Remote, len(remotes))
	for _, remote := range remotes {
		mapped[remote.Config().Name] = remote
	}
	return mapped
}

func OrganizeRepo(config Config, repoPath string, repo *git.Repository) error {
	var stagedRepo string
	if path.IsAbs(config.Stage) {
		stagedRepo = path.Join(config.Stage, path.Base(repoPath))
	} else {
		stagedRepo = path.Join(config.Destination, config.Stage, path.Base(repoPath))
	}

	if err := copy.Copy(repoPath, stagedRepo); err != nil {
		return fmt.Errorf("error staging repo '%s': %w", repoPath, err)
	}

	remotes, err := repo.Remotes()
	if err != nil {
		return err
	}

	remotes = lo.Filter(remotes, func(remote *git.Remote, _ int) bool {
		return config.IsRemoteAllowed(remote.Config().Name)
	})

	source, links, err := getRepoPaths(config, path.Base(repoPath), mapRemotes(remotes))
	if err != nil {
		return fmt.Errorf("could not organize repo '%s': %w", repoPath, err)
	}

	if err := copy.Copy(stagedRepo, source); err != nil {
		return err
	}

	linkErrs := make([]error, 0, len(links))
	for _, link := range links {
		if err := os.MkdirAll(path.Dir(link), 0755); err != nil {
			linkErrs = append(linkErrs, fmt.Errorf("could not create parent directories for symlink '%s': %w", link, err))
		} else if err := os.Symlink(source, link); err != nil {
			linkErrs = append(linkErrs, fmt.Errorf("could not create symlink '%s' -> '%s': %w", link, source, err))
		}
	}

	if len(linkErrs) != 0 {
		return errors.Join(linkErrs...)
	}

	if err := os.RemoveAll(stagedRepo); err != nil {
		return fmt.Errorf("could not remove staged repo '%s': %w", stagedRepo, err)
	}

	return nil
}
