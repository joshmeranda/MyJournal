package main

import (
	"fmt"
	"middleware"
	"plugin"
)

const (
	PluginPath      = "../plugin/plugin.so"
	SymbolNewPlugin = "NewPlugin"
)

func main() {
	p, err := plugin.Open(PluginPath)
	if err != nil {
		fmt.Printf("couldn't load plugin at '%s': %s\n", PluginPath, err)
	}

	s, err := p.Lookup(SymbolNewPlugin)
	if err != nil {
		fmt.Printf("could not find symbol '%s': %s\n", SymbolNewPlugin, err)
	}

	newPlugin, ok := s.(func() (middleware.Plugin, error))
	if !ok {
		fmt.Printf("symbol '%s' was of the wrong type: %T\n", SymbolNewPlugin, s)
	}

	pl, err := newPlugin()

	pl.DoSomething()
}
