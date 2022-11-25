%{
package main
%}

	%union {
	String string
	Number int
	Expression Expression
}

%token<Number> NUMBER

%type<Expression> expr

%left '-' '+'

%%

entry: expr
{
	setResult(yylex, $1)
}

expr: NUMBER { $$ = IntExpression{ n: $1 } }
	| expr '+' expr { $$ = OperatorExpression { left: $1, operator: "+", right: $3 } }
	| expr '-' expr { $$ = OperatorExpression { left: $1, operator: "-", right: $3 } }
	;
%%
