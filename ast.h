#ifndef MYLK_AST_H
#define MYLK_AST_H

#include <stdbool.h>
#include <stddef.h>

typedef struct AST_Expression AST_Expression;
typedef struct AST_Statement AST_Statement;

typedef struct AST_IntLit AST_IntLit;
struct AST_IntLit {
	unsigned long long value;
	bool               negative;
};

enum {
	AST_LT_INT,
	AST_LT_STR,
};

typedef struct AST_Literal AST_Literal;
struct AST_Literal {
	int kind;
	union {
		AST_IntLit intl;
		char      *str;
	};
};

enum {
	AST_TY_INT,
};

typedef struct AST_Type AST_Type;
struct AST_Type {
	int kind;
};

enum {
	AST_BN_ADD,
};

typedef struct AST_Binary AST_Binary;
struct AST_Binary {
	int             kind;
	AST_Expression *left;
	AST_Expression *right;
};

typedef struct AST_FnCall AST_FnCall;
struct AST_FnCall {
	AST_Expression  *fn;
	AST_Expression **args;
	size_t           nargs;
};

enum {
	AST_EX_LIT,
	AST_EX_IDT,
	AST_EX_BIN,
	AST_EX_FCL,
};

struct AST_Expression {
	int kind;
	union {
		char        *ident;
		AST_Literal *lit;
		AST_Binary  *bin;
		AST_FnCall  *fncall;
	};
};

typedef struct AST_Declaration AST_Declaration;
struct AST_Declaration {
	char           *var;
	AST_Type       *type;
	AST_Expression *rvalue;
};

enum {
	AST_AS_EQ,
};

typedef struct AST_Assignment AST_Assignment;
struct AST_Assignment {
	int             kind;
	AST_Expression *lvalue;
	AST_Expression *rvalue;
};

typedef struct AST_ForStmt AST_ForStmt;
struct AST_ForStmt {
	AST_Declaration *decl;
	AST_Expression  *cond;
	AST_Statement   *incr;
};

enum {
	AST_ST_FOR,
	AST_ST_ASG,
	AST_ST_EXP,
};

struct AST_Statement {
	int kind;
	union {
		AST_ForStmt    *forstmt;
		AST_Assignment *asign;
		AST_Expression *expr;
	};
};

typedef struct AST_Block AST_Block;
struct AST_Block {
	AST_Statement  *stmt;
	size_t          nstmt;
	AST_Expression *expr;
};

typedef struct AST_FunctionParam AST_FunctionParam;
struct AST_FunctionParam {
	char     *param;
	size_t    nparam;
	AST_Type *type;
};

typedef struct AST_Function AST_Function;
struct AST_Function {
	char              *name;
	AST_FunctionParam *params;
	size_t             nparams;
	AST_Type          *type;
	AST_Block          block;
};

enum {
	AST_TL_FN,
};

typedef struct AST_TopLevel AST_TopLevel;
struct AST_TopLevel {
	int kind;
	union {
		AST_Function *fn;
	};
};

typedef struct AST_Program AST_Program;
struct AST_Program {
	AST_TopLevel *children;
	size_t        nchildren;
};

typedef struct AST_Test_Stmts AST_Test_Stmts;
struct AST_Test_Stmts {
	AST_Statement **stmts;
	size_t          nstmts;
};

#endif /* MYLK_AST_H */
