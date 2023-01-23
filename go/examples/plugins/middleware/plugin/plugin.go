package main

import (
	"fmt"
	"middleware"
)

type Plugin struct{}

func (plugin Plugin) DoSomething() {
	fmt.Println("doing something")
}

func NewPlugin() (middleware.Plugin, error) {
	return &Plugin{}, nil
}
