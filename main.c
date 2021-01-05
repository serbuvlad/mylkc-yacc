#include <stdio.h>

#include "ast.h"

extern int yyparse(void);

AST_Program *file;

int main()
{
	yyparse();

	return 0;
}
