package main

import (
	"log"
	organize "organize/pkg"
	"os"
	"path"

	"github.com/urfave/cli/v2"
)

var logger *log.Logger

func init() {
	logger = log.Default()
}

func newApp() *cli.App {
	return &cli.App{
		Name:        "organize",
		Usage:       "organize [arguments] dir",
		UsageText:   "organize [arguments] dir",
		HelpName:    "organize",
		Description: "organize you flat development directory into some nested subdirectorie reflecting their github owner and name",
		Flags: []cli.Flag{
			&cli.StringFlag{
				Name:    "destination",
				Usage:   "the top level directory where the repos will be organized into",
				Value:   ".",
				Aliases: []string{"d"},
			},
			&cli.StringFlag{
				Name:    "stage",
				Usage:   "the directory (absolute or relative to destination) where the repos will be staged before being organized into destination",
				Value:   ".stage",
				Aliases: []string{"s"},
			},
			&cli.StringFlag{
				Name:    "quarantine",
				Usage:   "the directory (absolute or relative to destination) where repos that could not be organized will be placed",
				Value:   "quarantine",
				Aliases: []string{"q"},
			},
			&cli.StringSliceFlag{
				Name:    "include-remotes",
				Usage:   "remotes to include when organizing repos, if not specified all are included",
				Aliases: []string{"i"},
			},
			&cli.StringSliceFlag{
				Name:    "exclude-remotes",
				Usage:   "remotes to exclude when organizing repos",
				Aliases: []string{"e"},
			},
			&cli.StringFlag{
				Name:    "remote-strategy",
				Usage:   "strategy to use when organizing repos with multiple remotes",
				Aliases: []string{"r"},
			},
		},
		Action: run,
		Authors: []*cli.Author{
			{
				Name:  "Josh Meranda",
				Email: "joshmeranda@gmail.com",
			},
		},
	}
}

func organizeDir(config organize.Config, dir string) error {
	logger.Printf("organizing dir '%s'", dir)

	items, err := os.ReadDir(dir)
	if err != nil {
		return err
	}

	for _, item := range items {
		if item.IsDir() {
			if err := organize.OrganizeRepo(config, path.Join(dir, item.Name())); err != nil {
				logger.Printf("ERROR: could not organize repo '%s': %s", item.Name(), err)
			} else {
				logger.Printf("organized repo '%s'", path.Join(dir, item.Name()))
			}
		}
	}

	return nil
}

func run(args *cli.Context) error {
	config := organize.NewDefaultConfig()
	config.Destination = args.String("destination")
	config.Stage = args.String("stage")
	config.Quarantine = args.String("quarantine")
	config.IncludeRemotes = args.StringSlice("include-remotes")
	config.ExcludeRemotes = args.StringSlice("exclude-remotes")
	config.RemoteStrategy = organize.MultipleRemoteStrategy(args.String("remote-strategy"))

	for _, dir := range args.Args().Slice() {
		organizeDir(config, dir)
	}

	return nil
}

func main() {
	app := newApp()
	if err := app.Run(os.Args); err != nil {
		panic(err)
	}
}
