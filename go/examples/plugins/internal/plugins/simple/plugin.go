package main

import (
	"fmt"
	loader "loader/pkg"
)

type Plugin struct{}

func (plugin Plugin) DoSomething() {
	fmt.Println("doing something")
}

func NewPlugin() (loader.Plugin, error) {
	return &Plugin{}, nil
}
