Super early mylkc parser prototype
==================================

###Usage:

Write a series of statements on standard in, then set a breakpoint at
`main.c:13` and look at the pretty AST in the global variable `file`:
type `AST_Test_Stmts *`, see `ast.h` for details.

###Supported statements:

* expression statement

###Supported expressions:

* addition
* function call
* identifier
* integer literal (positivive decimal)
* string literal (no `\"` handling)
