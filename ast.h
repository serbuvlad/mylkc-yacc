#ifndef MYLK_AST_H
#define MYLK_AST_H

#include <stdbool.h>
#include <stddef.h>

typedef struct AST_Program AST_Program;
typedef struct AST_TopLevel AST_TopLevel;
typedef struct AST_Struct AST_Struct;
typedef struct AST_Parameters AST_StructEntry;
typedef struct AST_Enum AST_Enum;
typedef struct AST_Sum AST_Sum;
typedef struct AST_Alias AST_SumEntry;
typedef struct AST_Alias AST_Alias;
typedef struct AST_Function AST_Function;
typedef struct AST_Parameters AST_Parameters;
typedef struct AST_Declaration AST_Declaration;

typedef struct AST_Block AST_Block;

typedef struct AST_Statement AST_Statement;
typedef struct AST_Assignment AST_Assignment;

typedef struct AST_Expression AST_Expression;
typedef struct AST_FnCall AST_FnCall;
typedef struct AST_Binary AST_Binary;
typedef struct AST_Literal AST_Literal;

typedef struct AST_Type AST_Type;

typedef struct AST_IntLit AST_IntLit;
typedef struct AST_StrLit AST_StrLit;

enum {
	AST_SE_UTF8 = 0,
	AST_SE_UTF16,
	AST_SE_UTF32,
};

struct AST_StrLit {
	char  *str;
	size_t sz;
	int    enc; /* Target - str is always utf8 */
};

struct AST_IntLit {
	unsigned long long value;
	bool               negative;
};

enum {
	AST_LT_INT,
	AST_LT_STR,
};

struct AST_Literal {
	int kind;
	union {
		AST_IntLit *intl;
		AST_StrLit *str;
	};
};

enum {
	AST_TY_INT,
};

struct AST_Type {
	int kind;
};

enum {
	AST_BN_ADD,
};

struct AST_Binary {
	int             kind;
	AST_Expression *left;
	AST_Expression *right;
};

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

enum {
	AST_AS_EQ,
};

struct AST_Assignment {
	int             kind;
	AST_Expression *lvalue;
	AST_Expression *rvalue;
};

enum {
	AST_ST_FOR,
	AST_ST_ASG,
	AST_ST_EXP,
};

struct AST_Statement {
	int kind;
	union {
		AST_Assignment *asign;
		AST_Expression *expr;
	};
};

struct AST_Block {
	AST_Statement **stmt;
	size_t          nstmt;
	AST_Expression *expr;

};

struct AST_Parameters {
	char    **params;
	size_t    nparams;
	AST_Type *type;
};

struct AST_Declaration {
	char           **params;
	size_t           nparams;
	AST_Type        *type;
	AST_Expression **expr;
	size_t           nexpr;
};

struct AST_Function {
	char            *name;
	AST_Parameters **params;
	size_t           nparams;
	AST_Type        *type;
	AST_Block       *block;
};

struct AST_Alias {
	char     *name;
	AST_Type *type;
};

struct AST_Sum {
	char          *name;
	AST_SumEntry **entries;
	size_t         nentries;
	AST_Type      *type; /* WTF? */
};

struct AST_Enum {
	char     *name;
	char    **entry;
	size_t    nentry;
	AST_Type *type;
};

struct AST_Struct {
	char             *name;
	AST_StructEntry **entries;
	size_t            nentries;
};

enum {
	AST_TL_FUN,
	AST_TL_ALS,
	AST_TL_DCL,
	AST_TL_SUM,
	AST_TL_ENM,
	AST_TL_SCT,
};

struct AST_TopLevel {
	int kind;
	union {
		AST_Function    *fn;
		AST_Alias       *alias;
		AST_Declaration *decl;
		AST_Sum         *sum;
		AST_Enum        *enm;
		AST_Struct      *strct;
	};
};

struct AST_Program {
	AST_TopLevel **children;
	size_t         nchildren;
};

#endif /* MYLK_AST_H */
