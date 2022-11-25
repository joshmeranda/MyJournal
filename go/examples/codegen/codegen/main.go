package main

import (
	"fmt"
	"os"
	"strings"
)

const template = `func greet<NAME>() {
	println("Hello <NAME>")
}`

func cleanup() {
	if err := os.RemoveAll("namer.go"); err != nil {
		fmt.Printf("could not delete file: %s\n", err)
	}
}

func main() {
	cleanup()

	s := strings.Builder{}

	s.WriteString(`// Code in this file is generated as an example
package main

`)

	for _, arg := range os.Args[1:] {
		s.WriteString(strings.ReplaceAll(template, "<NAME>", arg) + "\n\n")
	}

	if err := os.WriteFile("namer.go", []byte(s.String()), 0644); err != nil {
		fmt.Printf("Failed to write generated file: %s\n", err)
		os.Exit(1)
	}
}
