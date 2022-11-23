%{
package main

import (
	"fmt"
	"strconv"
)
%}
%union {
	String string
	Number int
	Expression Expression
}

%token<String> DIGIT

%type<Expression> expr
%type<Number> number

%left '-' '+'

%%

entry: expr
{
	setResult(yylex, $1)
}

expr: number {
	n, err := strconv.Atoi($1)
	if err != nil {
		yylex.Error(fmt.Sprintf("value '%s' is not a valid int", $1))
	}

	$$ = IntExpression{ n: n }
	}
	| expr '+' expr { $$ = OperatorExpression { left: $1, operator: "+", right: $3 } }
	| expr '-' expr { $$ = OperatorExpression { left: $1, operator: "-", right: $3 } }
	;

number: DIGIT {
	n, err := strconv.Atoi($1)
	if err != nil {
		yylex.Error(fmt.Sprintf("value '%s' is not a valid int", $1))
	}

	$$ = IntExpression{ n: n }
	}
	;

%%
