package organize

import (
	"path"

	"golang.org/x/exp/slices"
)

// MultipleRemoteStrategy defines how to organize repos that have multiple remotes.
type MultipleRemoteStrategy string

const (
	// StrategyDefault will organize the repository using the default strategy.
	StrategyDefault MultipleRemoteStrategy = ""

	// StrategyOrigin will organize the repository using only the fetch remote.
	// todo: move towards a default remote rather than hardcoding the origin remote
	StrategyOrigin MultipleRemoteStrategy = "origin"

	// StrategySymlink will organize the repository using symbolic links to the fetch remote.
	StrategySymlink MultipleRemoteStrategy = "symlink"

	// StrategyQuarantine will organize the repository by placing it in the quarantine director if multiple remotes are found.
	StrategyQuarantine MultipleRemoteStrategy = "quarantine"
)

type Config struct {
	Destination string

	// Stage is the directory where the repos will be staged before being organized into Destination. If
	// if Stage is relative, it will be relative to Destination. If no error is encountered when
	// organinzing a repo, the staging dir will be removed. Otherwise, it will be left in place.
	Stage string

	// Quarantine is the directory where repos that could not be organized will be placed. If Quarantine
	// is relative, it will be relative to Destination.
	Quarantine string

	// IncludeRemotes specifies which remotes to include. If IncludeRemotes is empty, all remotes are included. IncludeRemotes
	// takes precedence over Exclude, so any remote in both will be included.
	IncludeRemotes []string

	// ExcludeRemotes specifies which remotes to exclude. If ExcludeRemotes is empty, no remotes are excluded.
	ExcludeRemotes []string

	RemoteStrategy MultipleRemoteStrategy
}

func NewDefaultConfig() Config {
	return Config{
		Destination:    ".",
		Stage:          ".stage",
		Quarantine:     "quarantine",
		IncludeRemotes: []string{},
		ExcludeRemotes: []string{},
		RemoteStrategy: StrategyDefault,
	}
}

func (config Config) IsRemoteAllowed(remote string) bool {
	if len(config.IncludeRemotes) != 0 {
		return slices.Contains(config.IncludeRemotes, remote)
	}
	return !slices.Contains(config.ExcludeRemotes, remote)
}

func (config Config) QuarantinePath() string {
	if path.IsAbs(config.Quarantine) {
		return config.Quarantine
	}

	return path.Clean(path.Join(config.Destination, config.Quarantine))
}
