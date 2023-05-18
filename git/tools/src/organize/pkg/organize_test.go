package organize

import (
	"fmt"
	"os"
	"path"
	"testing"

	"github.com/go-git/go-billy/v5/osfs"
	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/config"
	"github.com/go-git/go-git/v5/plumbing/cache"
	"github.com/go-git/go-git/v5/storage/filesystem"
	"github.com/otiai10/copy"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const RepoName = "MyJournal"
const RepoBaseName = "repo"

var (
	remoteOrigin = &config.RemoteConfig{
		Name: "origin",
		URLs: []string{"git@github.com:originuser/origin.git"},
	}
	remoteMirror = &config.RemoteConfig{
		Name: "mirror",
		URLs: []string{"https://github.com/mirroruser/mirror.git"},
	}
	remoteUpstream = &config.RemoteConfig{
		Name: "upstream",
		URLs: []string{"https://github.com/upstreamuser/upstream.git"},
	}
	remoteBad = &config.RemoteConfig{
		Name: "bad",
		URLs: []string{"https://github.com/bad-remote.git"},
	}
)

func symlinkExists(t *testing.T, path string, msgAndArgs ...any) bool {
	info, err := os.Lstat(path)
	if err != nil {
		if os.IsNotExist(err) {
			return assert.Fail(t, fmt.Sprintf("unable to find link %q", path), msgAndArgs)
		}
		return assert.Fail(t, fmt.Sprintf("error when running os.Lstst(%q)): %s", path, err), msgAndArgs)
	}
	if info.IsDir() {
		return assert.Fail(t, fmt.Sprintf("path %q is a directory", path), msgAndArgs)
	}

	if info.Mode()&os.ModeSymlink == 0 {
		return assert.Fail(t, fmt.Sprintf("path %q is not a symlink", path), msgAndArgs)
	}

	return true
}

func NoSymlinkExists(t *testing.T, path string, msgAndArgs ...any) bool {
	info, err := os.Lstat(path)
	if err != nil {
		if os.IsNotExist(err) {
			return true
		}
		return assert.Fail(t, fmt.Sprintf("error when running os.Lstst(%q)): %s", path, err), msgAndArgs)
	}

	if info.Mode()&os.ModeSymlink == 0 {
		return true
	}

	return assert.Fail(t, fmt.Sprintf("symlink %q exists", path), msgAndArgs)
}

func RepoWithRemotes(t *testing.T, parent string, remotes []*config.RemoteConfig) (string, *git.Repository) {
	repoDir := path.Join(parent, RepoBaseName)

	fs := osfs.New(repoDir)
	dot, _ := fs.Chroot("storage")
	st := filesystem.NewStorage(dot, cache.NewObjectLRUDefault())

	wt, _ := fs.Chroot(".")
	repo, err := git.Init(st, wt)
	require.NoError(t, err)

	file, err := wt.Create("README.md")
	require.NoError(t, err)
	defer file.Close()

	_, err = file.Write([]byte("sapmle repo for testing"))
	require.NoError(t, err)

	for _, remote := range remotes {
		_, err := repo.CreateRemote(remote)
		require.NoError(t, err)
	}

	return repoDir, repo
}

func TestGetRepoPaths(t *testing.T) {
	defaultRemotes := map[string]*git.Remote{
		"origin": git.NewRemote(nil, &config.RemoteConfig{
			Name: "origin",
			URLs: []string{"https://github.com/joshmeranda/MyJournal.git"},
		}),
		"upstream": git.NewRemote(nil, &config.RemoteConfig{
			Name: "upstream",
			URLs: []string{"https://github.com/some-org/MyJournal.git"},
		}),
	}

	t.Run("NoRemotes", func(t *testing.T) {
		config := Config{
			Destination: "/tmp",
		}
		source, links, err := getRepoPaths(config, "realName", map[string]*git.Remote{})
		assert.Error(t, err)
		assert.Empty(t, source)
		assert.Nil(t, links)
	})

	t.Run("StrategyOrigin", func(t *testing.T) {
		config := Config{
			Destination: "/tmp",
		}
		source, links, err := getRepoPaths(config, "realName", map[string]*git.Remote{})
		assert.Error(t, err)
		assert.Empty(t, source)
		assert.Nil(t, links)
	})

	t.Run("StrategySymlink", func(t *testing.T) {
		cfg := Config{
			Destination:    "/tmp",
			RemoteStrategy: StrategySymlink,
		}
		source, links, err := getRepoPaths(cfg, "realName", defaultRemotes)
		require.NoError(t, err)
		assert.Equal(t, "/tmp/joshmeranda/MyJournal", source)
		assert.Equal(t, []string{"/tmp/some-org/MyJournal"}, links)
	})

	t.Run("StrategyQuarantine", func(t *testing.T) {
		cfg := Config{
			Destination:    "/tmp",
			Quarantine:     "/tmp/quarantine",
			RemoteStrategy: StrategyQuarantine,
		}
		source, links, err := getRepoPaths(cfg, "realName", defaultRemotes)
		require.NoError(t, err)
		assert.Equal(t, "/tmp/quarantine/realName", source)
		assert.Nil(t, links)
	})
}

func TestOrganizeRepo(t *testing.T) {
	setup := func(t *testing.T) (func(), string) {
		tempDir, err := os.MkdirTemp("", "")
		require.NoError(t, err)

		tempDir = path.Join(tempDir, t.Name())
		require.NoError(t, os.MkdirAll(tempDir, 0755))

		return func() {
			if t.Failed() {
				require.NoError(t, copy.Copy(tempDir, t.Name()))
			}
		}, tempDir
	}

	t.Run("TestSimpleOrganizing", func(t *testing.T) {
		cleanup, tempDir := setup(t)
		defer cleanup()

		repoDir, repo := RepoWithRemotes(t, tempDir, []*config.RemoteConfig{remoteOrigin})

		config := NewDefaultConfig()
		config.Destination = path.Join(tempDir, "destination")

		require.NoError(t, OrganizeRepo(config, repoDir, repo))
		assert.DirExists(t, path.Join(config.Destination, "originuser", "origin"))
		assert.FileExists(t, path.Join(config.Destination, "originuser", "origin", ".git"))
		assert.FileExists(t, path.Join(config.Destination, "originuser", "origin", "README.md"))
	})

	t.Run("TestMultipleRemotesExcludeAllButOne", func(t *testing.T) {
		cleanup, tempDir := setup(t)
		defer cleanup()

		repoDir, repo := RepoWithRemotes(t, tempDir, []*config.RemoteConfig{remoteOrigin, remoteMirror, remoteUpstream})

		config := NewDefaultConfig()
		config.Destination = path.Join(tempDir, "destination")
		config.ExcludeRemotes = []string{"upstream", "mirror"}

		require.NoError(t, OrganizeRepo(config, repoDir, repo))
		assert.DirExists(t, path.Join(config.Destination, "originuser", "origin"))
		assert.FileExists(t, path.Join(config.Destination, "originuser", "origin", ".git"))
		assert.FileExists(t, path.Join(config.Destination, "originuser", "origin", "README.md"))
	})

	t.Run("TestMultipleRemotesIncludeOne", func(t *testing.T) {
		cleanup, tempDir := setup(t)
		defer cleanup()

		repoDir, repo := RepoWithRemotes(t, tempDir, []*config.RemoteConfig{remoteOrigin, remoteMirror, remoteUpstream})

		config := NewDefaultConfig()
		config.Destination = path.Join(tempDir, "destination")
		config.IncludeRemotes = []string{"origin"}

		require.NoError(t, OrganizeRepo(config, repoDir, repo))
		assert.DirExists(t, path.Join(config.Destination, "originuser", "origin"))
		assert.FileExists(t, path.Join(config.Destination, "originuser", "origin", ".git"))
		assert.FileExists(t, path.Join(config.Destination, "originuser", "origin", "README.md"))
	})

	t.Run("TestMultipleRemotesStrategyOrigin", func(t *testing.T) {
		cleanup, tempDir := setup(t)
		defer cleanup()

		repoDir, repo := RepoWithRemotes(t, tempDir, []*config.RemoteConfig{remoteOrigin, remoteMirror, remoteUpstream})

		config := NewDefaultConfig()
		config.Destination = path.Join(tempDir, "destination")
		config.RemoteStrategy = StrategyOrigin

		require.NoError(t, OrganizeRepo(config, repoDir, repo))
		assert.DirExists(t, path.Join(config.Destination, "originuser", "origin"))
		assert.FileExists(t, path.Join(config.Destination, "originuser", "origin", ".git"))
		assert.FileExists(t, path.Join(config.Destination, "originuser", "origin", "README.md"))
	})

	t.Run("TestMultipleRemotesStrategySymlink", func(t *testing.T) {
		cleanup, tempDir := setup(t)
		defer cleanup()

		repoDir, repo := RepoWithRemotes(t, tempDir, []*config.RemoteConfig{remoteOrigin, remoteMirror, remoteUpstream})

		config := NewDefaultConfig()
		config.Destination = path.Join(tempDir, "destination")
		config.RemoteStrategy = StrategySymlink

		require.NoError(t, OrganizeRepo(config, repoDir, repo))

		assert.DirExists(t, path.Join(config.Destination, "originuser", "origin"))
		assert.FileExists(t, path.Join(config.Destination, "originuser", "origin", ".git"))
		assert.FileExists(t, path.Join(config.Destination, "originuser", "origin", "README.md"))

		symlinkExists(t, path.Join(config.Destination, "upstreamuser", "upstream"))
		assert.FileExists(t, path.Join(config.Destination, "upstreamuser", "upstream", ".git"))
		assert.FileExists(t, path.Join(config.Destination, "upstreamuser", "upstream", "README.md"))

		symlinkExists(t, path.Join(config.Destination, "mirroruser", "mirror"))
		assert.FileExists(t, path.Join(config.Destination, "mirroruser", "mirror", ".git"))
		assert.FileExists(t, path.Join(config.Destination, "mirroruser", "mirror", "README.md"))
	})

	t.Run("TestMultipleRemotesStrategyQuarantine", func(t *testing.T) {
		cleanup, tempDir := setup(t)
		defer cleanup()

		repoDir, repo := RepoWithRemotes(t, tempDir, []*config.RemoteConfig{remoteOrigin, remoteMirror, remoteUpstream})

		config := NewDefaultConfig()
		config.Destination = path.Join(tempDir, "destination")
		config.RemoteStrategy = StrategyQuarantine

		require.NoError(t, OrganizeRepo(config, repoDir, repo))

		assert.NoDirExists(t, path.Join(config.Destination, "originuser", "origin"))
		assert.NoFileExists(t, path.Join(config.Destination, "originuser", "origin", ".git"))
		assert.NoFileExists(t, path.Join(config.Destination, "originuser", "origin", "README.md"))

		NoSymlinkExists(t, path.Join(config.Destination, "mirroruser", "mirror"))
		assert.NoFileExists(t, path.Join(config.Destination, "mirroruser", "mirror", ".git"))
		assert.NoFileExists(t, path.Join(config.Destination, "mirroruser", "mirror", "README.md"))

		NoSymlinkExists(t, path.Join(config.Destination, "upstreamuser", "upstream"))
		assert.NoFileExists(t, path.Join(config.Destination, "upstreamuser", "upstream", ".git"))
		assert.NoFileExists(t, path.Join(config.Destination, "upstreamuser", "upstream", "README.md"))

		assert.DirExists(t, path.Join(config.Destination, config.Quarantine, RepoBaseName))
		assert.FileExists(t, path.Join(config.Destination, config.Quarantine, RepoBaseName, ".git"))
		assert.FileExists(t, path.Join(config.Destination, config.Quarantine, RepoBaseName, "README.md"))
	})

	t.Run("TestBadRemote", func(t *testing.T) {
		cleanup, tempDir := setup(t)
		defer cleanup()

		repoDir, repo := RepoWithRemotes(t, tempDir, []*config.RemoteConfig{remoteBad})

		config := NewDefaultConfig()
		config.Destination = path.Join(tempDir, "destination")

		require.Error(t, OrganizeRepo(config, repoDir, repo))
		assert.DirExists(t, path.Join(config.Destination, ".stage", RepoBaseName))
		assert.NoDirExists(t, path.Join(config.Destination, "badRemote"))
	})
}
