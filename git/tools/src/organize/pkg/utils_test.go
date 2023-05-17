package organize

import (
	"testing"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/config"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestIsRemoteAllowed(t *testing.T) {
	t.Run("Include", func(t *testing.T) {
		config := Config{
			IncludeRemotes: []string{"origin", "upstream"},
		}
		// assert.True(t, config.IsRemoteAllowed("origin"))
		// assert.True(t, config.IsRemoteAllowed("upstream"))
		assert.False(t, config.IsRemoteAllowed("something-else"))
	})

	t.Run("Exclude", func(t *testing.T) {
		config := Config{
			ExcludeRemotes: []string{"origin", "upstream"},
		}
		assert.False(t, config.IsRemoteAllowed("origin"))
		assert.False(t, config.IsRemoteAllowed("upstream"))
		assert.True(t, config.IsRemoteAllowed("something-else"))
	})

	t.Run("IncludeAndExclude", func(t *testing.T) {
		config := Config{
			IncludeRemotes: []string{"origin"},
			ExcludeRemotes: []string{"origin", "origin"},
		}
		assert.True(t, config.IsRemoteAllowed("origin"))
		assert.False(t, config.IsRemoteAllowed("upstream"))
	})
}

func TestGetRemoteOwnereAndName(t *testing.T) {
	t.Run("SSH", func(t *testing.T) {
		t.Run("OK", func(t *testing.T) {
			remote := git.NewRemote(nil, &config.RemoteConfig{
				Name: "origin",
				URLs: []string{"git@github.com:joshmeranda/MyJournal.git"},
			})
			owner, name, err := getRemoteOwnerAndName(remote)
			require.NoError(t, err)
			assert.Equal(t, "joshmeranda", owner)
			assert.Equal(t, "MyJournal", name)
		})

		t.Run("MissingUserName", func(t *testing.T) {
			remote := git.NewRemote(nil, &config.RemoteConfig{
				Name: "origin",
				URLs: []string{"git@github.com:MyJournal.git"},
			})
			owner, name, err := getRemoteOwnerAndName(remote)
			require.Error(t, err)
			assert.Equal(t, "", owner)
			assert.Equal(t, "", name)
		})

		t.Run("MissingName", func(t *testing.T) {
			remote := git.NewRemote(nil, &config.RemoteConfig{
				Name: "origin",
				URLs: []string{"git@github.com:joshmeranda"},
			})
			owner, name, err := getRemoteOwnerAndName(remote)
			require.Error(t, err)
			assert.Equal(t, "", owner)
			assert.Equal(t, "", name)
		})
	})

	t.Run("HTTP", func(t *testing.T) {
		t.Run("OK", func(t *testing.T) {
			remote := git.NewRemote(nil, &config.RemoteConfig{
				Name: "origin",
				URLs: []string{"https://github.com/joshmeranda/MyJournal.git"},
			})
			owner, name, err := getRemoteOwnerAndName(remote)
			require.NoError(t, err)
			assert.Equal(t, "joshmeranda", owner)
			assert.Equal(t, "MyJournal", name)
		})

		t.Run("MissingUserName", func(t *testing.T) {
			remote := git.NewRemote(nil, &config.RemoteConfig{
				Name: "origin",
				URLs: []string{"https://github.com/MyJournal.git"},
			})
			owner, name, err := getRemoteOwnerAndName(remote)
			assert.Error(t, err)
			assert.Equal(t, "", owner)
			assert.Equal(t, "", name)
		})

		t.Run("MissingName", func(t *testing.T) {
			remote := git.NewRemote(nil, &config.RemoteConfig{
				Name: "origin",
				URLs: []string{"https://github.com/joshmeranda"},
			})
			owner, name, err := getRemoteOwnerAndName(remote)
			assert.Error(t, err)
			assert.Equal(t, "", owner)
			assert.Equal(t, "", name)
		})

		t.Run("BadUrl", func(t *testing.T) {
			remote := git.NewRemote(nil, &config.RemoteConfig{
				Name: "origin",
				URLs: []string{"github.com/joshmeranda"},
			})
			owner, name, err := getRemoteOwnerAndName(remote)
			assert.Error(t, err)
			assert.Equal(t, "", owner)
			assert.Equal(t, "", name)
		})
	})
}
