#include <stdio.h>

#include "ast.h"

extern int yyparse(void);

AST_Test_Stmts *file;

int main()
{
	yyparse();

	return 0;
}
