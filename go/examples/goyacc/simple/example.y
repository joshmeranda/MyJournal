%{
package main
%}
%union {
	Number int
}

%type<Number> expr start

%token<Number> NUMBER

%left '-' '+'

%%

start: expr { setResult(yylex, $$) }

expr : '(' expr ')' { $$ = $2 }
	| expr '+' expr { $$ = $1 + $3 }
	| expr '-' expr { $$ = $1 - $3 }
	| NUMBER
	;

%%
