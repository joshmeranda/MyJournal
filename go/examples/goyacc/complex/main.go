package main

import (
	"fmt"
	"strings"
)

const EOF = 0

type Lexer struct {
	things []string

	head int

	expr Expression
	err  error
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

	lval.String = lexer.things[lexer.head]

	fmt.Printf("=== [Lex] 001 '%s' ===\n", lval.String)

	lexer.head++

	switch lval.String {
	case "+", "-":
		return lexer.Lex(lval)
	default:
		return NUMBER
	}
}

func Parse(s string) (Expression, error) {
	lexer := NewLexer(s)

	if n := yyParse(&lexer); n != 0 {
		return nil, fmt.Errorf("could not parse '%s': %w", s, lexer.err)
	}

	return lexer.expr, nil
}

func main() {
	yyErrorVerbose = true

	if expr, err := Parse("5 + 6"); err != nil {
		fmt.Println(err.Error())
	} else {
		fmt.Printf("%s\n", expr)
	}
}
