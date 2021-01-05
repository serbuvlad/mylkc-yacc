CC=gcc
CFLAGS=-O0 -g -Wall -Wextra -std=c11 -Wfatal-errors

LD=gcc
LFLAGS=-O0 -g

FILES=main.o y.tab.o lex.yy.o
HEADERS=ast.h

YSRC=mylk.y
YFILE=y.tab.c

LSRC=mylk.l
LFILE=lex.yy.c

.PHONY: all
all: $(FILES)
	$(LD) $(LFLAGS) $(FILES)

$(YFILE): $(YSRC)
	yacc -d $(YSRC)

$(LFILE): $(LSRC) $(YFILE)
	lex $(LSRC)

%.o: %.c
	$(CC) $(CFLAGS) -c $<

.PHONY: clean
clean:
	@rm *.o $(YFILE) y.tab.h $(LFILE)

.PHONY: unmake
unmake: clean
	@rm a.out
