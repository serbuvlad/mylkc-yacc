%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ast.h"

extern AST_Test_Stmts *file;

void yyerror(char *err);
int  yylex(void);

#define NEW(T) ((T *) calloc(1, sizeof(T)))
#define NEW_ARRAY(T, ARR, N, FIRST) { (ARR) = NEW(T *); (ARR)[(N)++] = FIRST; }
#define APPEND_ARRAY(T, ARR, N, NEXT) { (ARR) = realloc((ARR), ((N) + 1) * sizeof(T *)); \
                                        (ARR)[(N)++] = NEXT; }
%}

%union {
	AST_IntLit i;
	char *str;

	AST_Test_Stmts *stmts;
	AST_Statement  *stmt;
	AST_Assignment *assign;
	AST_Expression *expr;
	AST_FnCall     *fncall;
	AST_Binary     *binary;
}

%start file_r
%token ident_r
%token intl_r
%token stringl_r
%type <str> ident_r stringl_r
%type <i> intl_r
%type <stmts> stmts_r
%type <stmt> stmt_r
%type <assign> assign_r
%type <expr> expr_r
%type <fncall> fncall_r argslst_r args_r
%type <binary> binary_r

%%

file_r	: stmts_r { file = $1; }

stmts_r	: stmt_r { $$ = NEW(AST_Test_Stmts);
                   NEW_ARRAY(AST_Statement, $$->stmts, $$->nstmts, $1); }

	| stmts_r stmt_r { $$ = $1;
		           APPEND_ARRAY(AST_Statement, $$->stmts, $$->nstmts, $2); }

stmt_r	: expr_r ';' { $$ = NEW(AST_Statement); $$->kind = AST_ST_EXP;
	               $$->expr = $1; }

expr_r	: binary_r { $$ = NEW(AST_Expression); $$->kind = AST_EX_BIN;
	             $$->bin = $1; }

	| fncall_r { $$ = NEW(AST_Expression); $$->kind = AST_EX_FCL;
	             $$->fncall = $1; }

	| ident_r { $$ = NEW(AST_Expression); $$->kind = AST_EX_IDT;
	           $$->ident = $1; }

	| intl_r { $$ = NEW(AST_Expression); $$->kind = AST_EX_LIT;
	           $$->lit = NEW(AST_Literal); $$->lit->kind = AST_LT_INT;
		   $$->lit->intl = $1; }

	| stringl_r { $$ = NEW(AST_Expression); $$->kind = AST_EX_LIT;
	              $$->lit = NEW(AST_Literal); $$->lit->kind = AST_LT_STR;
		      $$->lit->str = strdup($1); free($1); }

binary_r	: expr_r '+' expr_r { $$ = NEW(AST_Binary); $$->kind = AST_BN_ADD;
	                              $$->left = $1; $$->right = $3; }

fncall_r	: expr_r '(' argslst_r ')' { $$ = $3; $$->fn = $1; }

argslst_r	: /* empty */ { $$ = NEW(AST_FnCall); }
	        | args_r { $$ = $1; }

args_r	: expr_r { $$ = NEW(AST_FnCall); NEW_ARRAY(AST_Expression, $$->args, $$->nargs, $1); }
	| args_r ',' expr_r { $$ = $1; APPEND_ARRAY(AST_Expression, $$->args, $$->nargs, $3); }

%%

void yyerror(char *err)
{
	fprintf(stderr, "%s\n", err);
	exit(EXIT_FAILURE);
}
