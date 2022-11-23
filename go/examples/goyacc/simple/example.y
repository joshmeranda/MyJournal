%{
package main

import (
	"strconv"
)
%}
%union {
	Number int
}

%type<Number> expr number

%token<Number> DIGIT

%left '-' '+'

%%

expr : '(' expr ')' { $$ = $2 }
	| expr '+' expr { $$ = $1 + $3 }
	| expr '-' expr { $$ = $1 - $3 }
	| number
	;

number : DIGIT { $1 }

%%
