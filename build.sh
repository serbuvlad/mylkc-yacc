#!/bin/sh

yacc -d mylk.y &&
	lex mylk.l &&
	gcc -g -O0 *.c
