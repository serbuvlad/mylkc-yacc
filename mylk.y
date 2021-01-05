%{
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ast.h"

extern AST_Program *file;
extern char *yytext;
int line = 1;

char *strdup(const char *s);

void yyerror(char *err);
int  yylex(void);

AST_IntLit *plit_int(const char *text);
AST_StrLit *plit_str(const char *text);

#define NEW(T) ((T *) calloc(1, sizeof(T)))
#define NEW_ARRAY(T, ARR, N, FIRST) { (ARR) = NEW(T *); (ARR)[(N)++] = FIRST; }
#define APPEND_ARRAY(T, ARR, N, NEXT) { (ARR) = realloc((ARR), ((N) + 1) * sizeof(T *)); \
                                        (ARR)[(N)++] = NEXT; }
%}

%union {
	AST_Program     *Program;
	AST_TopLevel    *TopLevel;
	AST_Struct      *Struct;
	AST_StructEntry *StructEntry;
	AST_Enum        *Enum;
	AST_Sum         *Sum;
	AST_SumEntry    *SumEntry;
	AST_Alias       *Alias;
	AST_Function    *Function;
	AST_Parameters  *Parameters;
	AST_Declaration *Declaration;

	AST_Block       *Block;

	AST_Statement   *Statement;

	AST_Expression  *Expression;
	AST_FnCall      *FnCall;
	AST_Binary      *Binary;
	AST_Literal     *Literal;

	AST_Type        *Type;

	AST_IntLit      *IntLit;
	AST_StrLit      *StrLit;

	char *ident;
}

%start file_r

%token ident_t
%token intl_t
%token stringl_t

%token fn_k
%token type_k
%token sum_k
%token enum_k
%token struct_k
%token alias_k

%token int_k

%type <Program> program_r
%type <TopLevel> toplevel_r
%type <Struct> struct_r structentries_r
%type <StructEntry> structentry_r
%type <Enum> enum_r enumentries_r
%type <Sum> sum_r sumentries_r
%type <SumEntry> sumentry_r
%type <Alias> alias_r
%type <Function> function_r params_r paramsorempty_r
%type <Parameters> param_r paramlist_r
%type <Declaration> decl_r

%type <Block> block_r stmts_r

%type <Statement> stmt_r

%type <Expression> expr_r exprorempty_r
%type <Binary> binary_r
%type <FnCall> fncall_r argslist_r args_r

%type <Type> type_r ctypeorempty_r typeorempty_r

%type <IntLit> intl_r
%type <StrLit> strl_r

%type <ident> ident_r

%%

/* Helpers */

opc_r : /* empty */
      | ','

ctypeorempty_r : /* empty */ { $$ = NULL; }
               | ':' type_r  { $$ = $2; }

typeorempty_r : /* empty */ { $$ = NULL; }
              | type_r      { $$ = $1; }

exprorempty_r : /* empty */ { $$ = NULL; }
              | expr_r      { $$ = $1; }

paramsorempty_r : /* empty */ { $$ = NEW(AST_Function); }
                | params_r    { $$ = $1; }

/* Top Level */

file_r : program_r { file = $1; }

program_r : toplevel_r { $$ = NEW(AST_Program);
                         NEW_ARRAY(AST_TopLevel, $$->children, $$->nchildren, $1); }

          | program_r toplevel_r { $$ = $1;
                                   APPEND_ARRAY(AST_TopLevel, $$->children, $$->nchildren, $2); }

toplevel_r : function_r { $$ = NEW(AST_TopLevel); $$->kind = AST_TL_FUN;
                          $$->fn = $1; }

           | alias_r { $$ = NEW(AST_TopLevel); $$->kind = AST_TL_ALS;
                       $$->alias = $1; }

           | decl_r { $$ = NEW(AST_TopLevel); $$->kind = AST_TL_DCL;
                      $$->decl = $1; }

           | sum_r { $$ = NEW(AST_TopLevel); $$->kind = AST_TL_SUM;
                     $$->sum = $1; }

           | enum_r { $$ = NEW(AST_TopLevel); $$->kind = AST_TL_ENM;
                      $$->enm = $1; }

           | struct_r { $$ = NEW(AST_TopLevel); $$->kind = AST_TL_SCT;
                        $$->strct = $1; }

alias_r : type_k ident_r ':' type_r ';' { $$ = NEW(AST_Alias); $$->name = $2; $$->type = $4; }

/* Hack. Should probably do better */

decl_r : param_r ';' { $$ = NEW(AST_Declaration);
                       $$->params = $1->params; $$->nparams = $1->nparams;
                       $$->type = $1->type; free($1); }

       | param_r '=' args_r ';' { $$ = NEW(AST_Declaration);
                                  $$->params = $1->params;
                                  $$->nparams = $1->nparams;
                                  $$->type = $1->type;
                                  $$->expr = $3->args;
                                  $$->nexpr = $3->nargs;
                                  free($1); free($3); }

enum_r : enum_k ident_r ctypeorempty_r '{' enumentries_r opc_r '}' { $$ = $5;
                                                                     $$->name = $2;
                                                                     $$->type = $3; }

enumentries_r : ident_r { $$ = NEW(AST_Enum);
                          NEW_ARRAY(char, $$->entry, $$->nentry, $1); }

              | enumentries_r ',' ident_r { APPEND_ARRAY(char, $$->entry, $$->nentry, $3); }

sum_r : sum_k ident_r ctypeorempty_r '{' sumentries_r opc_r '}' { $$ = $5;
                                                                    $$->name = $2;
                                                                    $$->type = $3; }

sumentries_r : sumentry_r { $$ = NEW(AST_Sum);
                            NEW_ARRAY(AST_SumEntry, $$->entries, $$->nentries, $1); }

             | sumentries_r ',' sumentry_r { APPEND_ARRAY(AST_SumEntry, $$->entries, $$->nentries, $3); }

sumentry_r : ident_r '(' type_r ')' { $$ = NEW(AST_SumEntry);
                                      $$->name = $1; $$->type = $3; }

struct_r : struct_k ident_r '{' structentries_r opc_r '}' { $$ = $4; $$->name = $2; }

structentries_r : structentry_r { $$ = NEW(AST_Struct);
                                  NEW_ARRAY(AST_StructEntry, $$->entries, $$->nentries, $1); }

                | structentries_r ',' structentry_r { APPEND_ARRAY(AST_StructEntry, $$->entries, $$->nentries, $3); }

structentry_r : param_r { $$ = (AST_StructEntry *) $1; }

function_r : fn_k ident_r '(' paramsorempty_r ')' typeorempty_r block_r { $$ = $4;
                                                                          $$->name = $2;
                                                                          $$->type = $6;
                                                                          $$->block = $7; }

params_r : param_r { $$ = NEW(AST_Function);
                     NEW_ARRAY(AST_Parameters, $$->params, $$->nparams, $1); }

         | params_r param_r { $$ = $1;
                              APPEND_ARRAY(AST_Parameters, $$->params, $$->nparams, $2); }

param_r : paramlist_r ':' type_r { $$ = $1; $$->type = $3; }

paramlist_r : ident_r { $$ = NEW(AST_Parameters);
                        NEW_ARRAY(char, $$->params, $$->nparams, $1); }

            | paramlist_r ',' ident_r { $$ = $1;
                                        APPEND_ARRAY(char, $$->params, $$->nparams, $3); }

/* Block */

block_r : '{' stmts_r exprorempty_r '}' { $$ = $2; $$->expr = $3; }

stmts_r : stmt_r { $$ = NEW(AST_Block);
                   NEW_ARRAY(AST_Statement, $$->stmt, $$->nstmt, $1); }

        | stmts_r stmt_r { $$ = $1;
                           APPEND_ARRAY(AST_Statement, $$->stmt, $$->nstmt, $2); }

/* Statements */

stmt_r : expr_r ';' { $$ = NEW(AST_Statement); $$->kind = AST_ST_EXP;
                      $$->expr = $1; }

/* Expressions */

expr_r : binary_r { $$ = NEW(AST_Expression); $$->kind = AST_EX_BIN;
                    $$->bin = $1; }

       | fncall_r { $$ = NEW(AST_Expression); $$->kind = AST_EX_FCL;
                    $$->fncall = $1; }

       | ident_t { $$ = NEW(AST_Expression); $$->kind = AST_EX_IDT;
                   $$->ident = strdup(yytext); }

       | intl_r { $$ = NEW(AST_Expression); $$->kind = AST_EX_LIT;
                  $$->lit = NEW(AST_Literal); $$->lit->kind = AST_LT_INT;
                  $$->lit->intl = $1; }

       | strl_r { $$ = NEW(AST_Expression); $$->kind = AST_EX_LIT;
	             $$->lit = NEW(AST_Literal); $$->lit->kind = AST_LT_STR;
		     $$->lit->str = $1; }

binary_r : expr_r '+' expr_r { $$ = NEW(AST_Binary); $$->kind = AST_BN_ADD;
                               $$->left = $1; $$->right = $3; }

fncall_r : expr_r '(' argslist_r ')' { $$ = $3; $$->fn = $1; }

argslist_r : /* empty */ { $$ = NEW(AST_FnCall); }
           | args_r { $$ = $1; }

args_r : expr_r { $$ = NEW(AST_FnCall); NEW_ARRAY(AST_Expression, $$->args, $$->nargs, $1); }
       | args_r ',' expr_r { $$ = $1; APPEND_ARRAY(AST_Expression, $$->args, $$->nargs, $3); }

/* Types */

type_r : int_k { $$ = NEW(AST_Type); $$->kind = AST_TY_INT; }

/* Literals */

ident_r : ident_t { $$ = strdup(yytext); }

intl_r : intl_t { $$ = plit_int(yytext); }

strl_r : stringl_t { $$ = plit_str(yytext); }

%%

void yyerror(char *err)
{
	fprintf(stderr, "line %d: %s\n", line, err);
	exit(EXIT_FAILURE);
}

static
const char alphabet[] = "0123456789abcdef";

AST_IntLit *plit_int(const char *text)
{
	AST_IntLit *i = calloc(1, sizeof(AST_IntLit));
	int base = 10;

	if (strlen(text) > 2 && strncmp(text, "0x", 2) == 0) {
		base = 16;
		text += 2;
	} else if (strlen(text) > 2 && strncmp(text, "0b", 2) == 0) {
		base = 2;
		text += 2;
	}

	while (*text != '\0') {
		if (*text == '_')
			continue;

		i->value *= base;
		i->value += strchr(alphabet, tolower(*text)) - alphabet;

		text++;
	}

	return i;
}

static
const char UE_ERRFMT[] = "unrecognized escape sequence '\\%c'";

static
char unescape(char c)
{
	/* TODO: \x, \u */

	switch (c) {
	case 'n': return '\n'; break;
	case 't': return '\t'; break;
	case 'r': return '\r'; break;
	case 'v': return '\v'; break;
	case 'f': return '\f'; break;
	case 'b': return '\b'; break;
	case '"': return '"'; break;
	case '\'': return '\''; break;
	case '\\': return '\\'; break;
	default:
		{
			char *errmsg = malloc(sizeof(UE_ERRFMT));
			sprintf(errmsg, UE_ERRFMT, c);
			yyerror(errmsg);
		}
	}

	return 0; /* unreachable - to satisfy gcc */
}

AST_StrLit *plit_str(const char *text)
{
	AST_StrLit *str = calloc(1, sizeof(AST_StrLit));
	size_t i, len = strlen(text);

	if (text[0] == 'u') {
		switch (text[3]) {
		case '8': /* UTF-8 */
			str->enc = AST_SE_UTF8;
			text += 4;
			break;
		case '1': /* UTF-16 */
			str->enc = AST_SE_UTF16;
			text += 5;
			break;
		case '3': /* UTF-32 */
			str->enc = AST_SE_UTF32;
			text += 5;
		}
	}

	/* Eliminate delimitating "s */
	text++;
	len -= 2;

	str->str = calloc(len + 1, 1);

	for (i = 0; i < len; i++) {
		switch (text[i]) {
		default:
			str->str[str->sz++] = text[i];
			break;
		case '\\':
			str->str[str->sz++] = unescape(text[++i]);
		}
	}

	str->str[str->sz] = '\0';

	return str;
}