package main

//go:generate go run ./codegen/main.go Bilbo Gandalf

func main() {
	greetBilbo()
	greetGandalf()
}
