package main

import (
	"fmt"
	loader "loader/pkg"
	"plugin"
)

const SymbolNewPlugin = "NewPlugin"

var pluginPaths = []string{"plugins/simple/plugin.so"}

func loadPlugin(pluginPath string) (loader.Plugin, error) {
	pl, err := plugin.Open(pluginPath)
	if err != nil {
		return nil, err
	}

	s, err := pl.Lookup(SymbolNewPlugin)
	if err != nil {
		fmt.Printf("could not find symbol '%s': %s\n", SymbolNewPlugin, err)
	}

	newPlugin, ok := s.(func() (loader.Plugin, error))
	if !ok {
		fmt.Printf("symbol '%s' was of the wrong type: %T\n", SymbolNewPlugin, s)
	}

	return newPlugin()
}

func main() {
	for _, path := range pluginPaths {
		if pl, err := loadPlugin(path); err != nil {
			fmt.Printf("error loading plugin: %s\n", err)
		} else {
			pl.DoSomething()
		}
	}
}
