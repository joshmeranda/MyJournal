package organize

import (
	"fmt"
	"os"
	"path"
	"path/filepath"
	"testing"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/config"
	"github.com/otiai10/copy"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
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

	testRepoDir, err := filepath.Abs("../test")
	require.NoError(t, err)

	t.Run("TestSimpleOrganizing", func(t *testing.T) {
		cleanup, tempDir := setup(t)
		defer cleanup()

		config := NewDefaultConfig()
		config.Destination = path.Join(tempDir, "destination")

		require.NoError(t, OrganizeRepo(config, path.Join(testRepoDir, "simple")))
		assert.DirExists(t, path.Join(config.Destination, "joshmeranda", "simple"))
		assert.DirExists(t, path.Join(config.Destination, "joshmeranda", "simple", ".git"))
		assert.FileExists(t, path.Join(config.Destination, "joshmeranda", "simple", "README.md"))
	})

	t.Run("TestMultipleRemotesExcludeAllButOne", func(t *testing.T) {
		cleanup, tempDir := setup(t)
		defer cleanup()

		config := NewDefaultConfig()
		config.Destination = path.Join(tempDir, "destination")
		config.ExcludeRemotes = []string{"upstream", "mirror"}

		require.NoError(t, OrganizeRepo(config, path.Join(testRepoDir, "multipleRemotes")))
		assert.DirExists(t, path.Join(config.Destination, "joshmeranda", "multipleRemotes"))
		assert.DirExists(t, path.Join(config.Destination, "joshmeranda", "multipleRemotes", ".git"))
		assert.FileExists(t, path.Join(config.Destination, "joshmeranda", "multipleRemotes", "README.md"))
	})

	t.Run("TestMultipleRemotesIncludeOne", func(t *testing.T) {
		cleanup, tempDir := setup(t)
		defer cleanup()

		config := NewDefaultConfig()
		config.Destination = path.Join(tempDir, "destination")
		config.IncludeRemotes = []string{"origin"}

		require.NoError(t, OrganizeRepo(config, path.Join(testRepoDir, "multipleRemotes")))
		assert.DirExists(t, path.Join(config.Destination, "joshmeranda", "multipleRemotes"))
		assert.DirExists(t, path.Join(config.Destination, "joshmeranda", "multipleRemotes", ".git"))
		assert.FileExists(t, path.Join(config.Destination, "joshmeranda", "multipleRemotes", "README.md"))
	})

	t.Run("TestMultipleRemotesStrategyOrigin", func(t *testing.T) {
		cleanup, tempDir := setup(t)
		defer cleanup()

		config := NewDefaultConfig()
		config.Destination = path.Join(tempDir, "destination")
		config.RemoteStrategy = StrategyOrigin

		require.NoError(t, OrganizeRepo(config, path.Join(testRepoDir, "multipleRemotes")))
		assert.DirExists(t, path.Join(config.Destination, "joshmeranda", "multipleRemotes"))
		assert.DirExists(t, path.Join(config.Destination, "joshmeranda", "multipleRemotes", ".git"))
		assert.FileExists(t, path.Join(config.Destination, "joshmeranda", "multipleRemotes", "README.md"))
	})

	t.Run("TestMultipleRemotesStrategySymlink", func(t *testing.T) {
		cleanup, tempDir := setup(t)
		defer cleanup()

		config := NewDefaultConfig()
		config.Destination = path.Join(tempDir, "destination")
		config.RemoteStrategy = StrategySymlink

		require.NoError(t, OrganizeRepo(config, path.Join(testRepoDir, "multipleRemotes")))

		assert.DirExists(t, path.Join(config.Destination, "joshmeranda", "multipleRemotes"))
		assert.DirExists(t, path.Join(config.Destination, "joshmeranda", "multipleRemotes", ".git"))
		assert.FileExists(t, path.Join(config.Destination, "joshmeranda", "multipleRemotes", "README.md"))

		symlinkExists(t, path.Join(config.Destination, "mirroruser", "multipleRemotes"))
		assert.DirExists(t, path.Join(config.Destination, "mirroruser", "multipleRemotes", ".git"))
		assert.FileExists(t, path.Join(config.Destination, "mirroruser", "multipleRemotes", "README.md"))

		symlinkExists(t, path.Join(config.Destination, "someoneelse", "multipleRemotes"))
		assert.DirExists(t, path.Join(config.Destination, "someoneelse", "multipleRemotes", ".git"))
		assert.FileExists(t, path.Join(config.Destination, "someoneelse", "multipleRemotes", "README.md"))
	})

	t.Run("TestMultipleRemotesStrategyQuarantine", func(t *testing.T) {
		cleanup, tempDir := setup(t)
		defer cleanup()

		config := NewDefaultConfig()
		config.Destination = path.Join(tempDir, "destination")
		config.RemoteStrategy = StrategyQuarantine

		require.NoError(t, OrganizeRepo(config, path.Join(testRepoDir, "multipleRemotes")))

		assert.NoDirExists(t, path.Join(config.Destination, "joshmeranda", "multipleRemotes"))
		assert.NoDirExists(t, path.Join(config.Destination, "joshmeranda", "multipleRemotes", ".git"))
		assert.NoFileExists(t, path.Join(config.Destination, "joshmeranda", "multipleRemotes", "README.md"))

		NoSymlinkExists(t, path.Join(config.Destination, "mirroruser", "multipleRemotes"))
		assert.NoDirExists(t, path.Join(config.Destination, "mirroruser", "multipleRemotes", ".git"))
		assert.NoFileExists(t, path.Join(config.Destination, "mirroruser", "multipleRemotes", "README.md"))

		NoSymlinkExists(t, path.Join(config.Destination, "someoneelse", "multipleRemotes"))
		assert.NoDirExists(t, path.Join(config.Destination, "someoneelse", "multipleRemotes", ".git"))
		assert.NoFileExists(t, path.Join(config.Destination, "someoneelse", "multipleRemotes", "README.md"))

		assert.DirExists(t, path.Join(config.Destination, config.Quarantine, "multipleRemotes"))
		assert.DirExists(t, path.Join(config.Destination, config.Quarantine, "multipleRemotes", ".git"))
		assert.FileExists(t, path.Join(config.Destination, config.Quarantine, "multipleRemotes", "README.md"))
	})

	t.Run("TestBadRemote", func(t *testing.T) {
		cleanup, tempDir := setup(t)
		defer cleanup()

		config := NewDefaultConfig()
		config.Destination = path.Join(tempDir, "destination")

		require.Error(t, OrganizeRepo(config, path.Join(testRepoDir, "badRemote")))
		assert.DirExists(t, path.Join(config.Destination, ".stage", "badRemote"))
	})
}
