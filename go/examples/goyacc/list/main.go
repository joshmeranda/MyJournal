package main

import (
	"fmt"
	"strings"
)

const EOF = 0

type Lexer struct {
	things []string

	head int

	result []string
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

	switch head {
	case "single":
		return SINGLE
	case "list":
		return LIST
	default:
		lval.str = head
		return ITEM
	}
}

func Parse(s string) ([]string, error) {
	lexer := NewLexer(s)

	if n := yyParse(&lexer); n != 0 {
		return nil, fmt.Errorf("could not parse '%s': %w", s, lexer.err)
	}

	return lexer.result, nil
}

func main() {
	yyErrorVerbose = true

	if expr, err := Parse("abcd e f g hi"); err != nil {
		fmt.Println(err.Error())
	} else {
		fmt.Printf("slice: %v\n", expr)

		_ = expr
	}
}
