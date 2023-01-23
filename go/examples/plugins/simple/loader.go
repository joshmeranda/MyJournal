package main

import (
	"fmt"
	"plugin"
)

const (
	PluginPath        = "./plugin.so"
	SymbolDoSomething = "DoSomething"
)

func main() {
	p, err := plugin.Open(PluginPath)
	if err != nil {
		fmt.Printf("couldn't load plugin at '%s': %s\n", PluginPath, err)
	}

	s, err := p.Lookup(SymbolDoSomething)
	if err != nil {
		fmt.Printf("could not find symbol '%s': %s\n", SymbolDoSomething, err)
	}

	doSomething, ok := s.(func())
	if !ok {
		fmt.Printf("symbol '%s' was of the wrong type: %T\n", SymbolDoSomething, s)
	}
	doSomething()
}
