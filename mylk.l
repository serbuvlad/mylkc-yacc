%{
#include "ast.h"
#include "y.tab.h"

void yyerror(char *err);
%}

%%

\"[^"]*\"	{ yylval.str = strdup(yytext); return stringl_r; }
[0-9]+	{ yylval.i.value = atoi(yytext); return intl_r; }
[A-Za-z_][A-Za-z_0-9]*	{ yylval.str = strdup(yytext); return ident_r; }
[ \t\n] { ; }
[+();,]	{ return yytext[0]; }
.	{ char buf[1000]; sprintf(buf, "unexpected %s", yytext); yyerror(buf); }

%%

int yywrap(void) { return 1; }
