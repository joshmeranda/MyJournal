%{
package main

var yySlice []string
%}

%union{
	slice []string
	str string
}

%token<str> ITEM
%token SINGLE LIST

%right single list

%type<slice> slice

%%

start: slice {
	yylex.(*Lexer).result = $1
}

slice:    { $$ = []string{ } }
	| slice ITEM {
		$$ = append($$, $2)
	}
	;

%%
