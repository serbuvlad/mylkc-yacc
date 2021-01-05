Super early mylkc parser prototype
==================================

###Usage:

Write a program standard in, then set a breakpoint at
`main.c:13` and look at the pretty AST in the global variable `file`:
type `AST_Program *`, see `ast.h` for details.

###Support

All top level constructs are supported. The only supported statement is the expression statement.
The only supported expressions are addition and function call. The only supported type is "int".

Normal comments are supported, but multiline comments are not supported (impossible to support recursively with lex).
Without recursion they wouldn't be difficult to support but maintaining the line counter would require more code than
none so that's why I didn't bother with them yet.
