package main

import (
	"ctv/pkg"
	"fmt"
)

// An example program for setting values at compile time using `go build -ldflags "-X <importpath>=<value>".You can get
//the value for <importpath> using `go tool nm <binary> | grep <variable_name>`
func main() {
	fmt.Printf("String : \"%s\"\n", pkg.String)
}
