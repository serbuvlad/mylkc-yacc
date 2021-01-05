%{
#include "ast.h"
#include "y.tab.h"

void yyerror(char *err);
extern int line;
%}

%%

#.*\n                                { ; }
(utf8|utf16|utf32)?\"([^\\"]|\\.)*\" { return stringl_t; }

fn                                   { return fn_k; }
type                                 { return type_k; }
sum                                  { return sum_k; }
enum                                 { return enum_k; }
struct                               { return struct_k; }
alias                                { return alias_k; }

int                                  { return int_k; }

[0-9_]+                              { return intl_t; }
0x[0-9a-fA-F]+                       { return intl_t; }
0b[01]+                              { return intl_t; }
[A-Za-z_][A-Za-z_0-9]*               { return ident_t; }
[ \t]                                { ; }
[\n]                                 { line++; }
[+\-*/=()\[\]{};:,]                  { return yytext[0]; }
.                                    { char buf[1000];
                                       sprintf(buf, "unexpected %s at %d\n", yytext, line);
                                       yyerror(buf); }

%%

int yywrap(void) { return 1; }
