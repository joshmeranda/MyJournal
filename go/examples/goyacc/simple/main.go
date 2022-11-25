package main

import (
	"fmt"
	"strconv"
	"strings"
)

const EOF = 0

type Lexer struct {
	things []string

	head int

	result int
	err    error
}

func NewLexer(s string) Lexer {
	return Lexer{
		things: strings.Split(s, " "),
	}
}

func (lexer *Lexer) Error(s string) {
	lexer.err = fmt.Errorf(s)
}

func (lexer *Lexer) Lex(lval *yySymType) int {
	if lexer.head == len(lexer.things) {
		return EOF
	}

	head := lexer.things[lexer.head]

	lexer.head++

	if n, err := strconv.Atoi(head); err != nil {
		// handle other tokens
		switch head {
		case "+", "-":
			return int(head[0])
		}
	} else {
		lval.Number = n
		return NUMBER
	}

	return -1
}

func Parse(s string) (int, error) {
	lexer := NewLexer(s)

	if n := yyParse(&lexer); n != 0 {
		return 0, fmt.Errorf("could not parse '%s': %w", s, lexer.err)
	}

	return lexer.result, nil
}

func main() {
	if expr, err := Parse("5 + 6"); err != nil {
		fmt.Println(err.Error())
	} else {
		fmt.Printf("%v\n", expr)
	}
}
