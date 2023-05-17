package organize

import (
	"fmt"
	"net/url"
	"strings"

	"github.com/go-git/go-git/v5"
)

func getRemoteOwnerAndNameFromHttp(s string) (string, string, error) {
	u, err := url.Parse(s)
	if err != nil {
		return "", "", fmt.Errorf("could not parse url for remote: %w", err)
	}

	components := strings.SplitN(u.Path, "/", 3)

	if len(components) < 3 {
		return "", "", fmt.Errorf("url did not contain enough path components")
	}

	return components[1], strings.TrimSuffix(components[2], ".git"), nil
}

func getRemoteOwnerAndNameFromSSH(s string) (string, string, error) {
	path := strings.SplitN(s, ":", 2)[1]
	trimmed := strings.TrimSuffix(path, ".git")
	components := strings.Split(trimmed, "/")

	if len(components) < 2 {
		return "", "", fmt.Errorf("address did not contain enough path components")
	}

	return components[0], components[1], nil
}

func getRemoteOwnerAndName(r *git.Remote) (string, string, error) {
	if len(r.Config().URLs) == 0 {
		return "", "", fmt.Errorf("remote '%s' has not urls", r.Config().Name)
	}

	switch u := r.Config().URLs[0]; {
	case strings.Contains(u, "http"):
		return getRemoteOwnerAndNameFromHttp(u)
	case strings.Contains(u, "@"):
		return getRemoteOwnerAndNameFromSSH(u)
	default:
		return "", "", fmt.Errorf("remote '%s' has an invalid url: %s", r.Config().Name, u)
	}
}
