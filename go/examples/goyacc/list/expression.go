package main

import (
	"fmt"
	"strings"
)

type Expression interface {
	Evaluate() string
}

type SingleExpression struct {
	s string
}

func (expr SingleExpression) Evaluate() string {
	return "I want a " + expr.s
}

type ListExpression struct {
	l []string
}

func (expr ListExpression) Evaluate() string {
	message := strings.Builder{}

	message.WriteString("I want a ")
	switch len(expr.l) {
	case 0:
		return "I want nothing"
	case 1:
		message.WriteString(expr.l[0])
	case 2:
		message.WriteString(expr.l[0] + " and " + expr.l[1])
	default:
		message.WriteString(strings.Join(expr.l[:len(expr.l)-1], ", "))
		message.WriteString(", and " + expr.l[len(expr.l)-1])
	}

	return message.String()
}

func setResult(lexer yyLexer, slice []string) {
	fmt.Printf("[setResult] 000 %v\n", slice)
	copy(lexer.(*Lexer).result, slice)
	fmt.Printf("[setResult] 001 %v\n", lexer.(*Lexer).result)
}
