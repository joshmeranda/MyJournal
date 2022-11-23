package main

import (
	"fmt"
)

type Expression interface {
	Evaluate() int
}

type IntExpression struct{ n int }

func (expr IntExpression) Evaluate() int {
	return expr.n
}

type OperatorExpression struct {
	left     Expression
	operator string
	right    Expression
}

func (expr OperatorExpression) Evaluate() int {
	switch expr.operator {
	case "+":
		return expr.left.Evaluate() + expr.right.Evaluate()
	case "-":
		return expr.left.Evaluate() - expr.right.Evaluate()
	default:
		panic(fmt.Sprintf("unsupported operator '%s'", expr.operator))
	}
}

func setResult(lexer yyLexer, expr Expression) {
	//fmt.Printf("=== [setResult] %v \n", expr)
	lexer.(*Lexer).expr = expr
}
