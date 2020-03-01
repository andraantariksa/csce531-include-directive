pascal-tokens : lex.yy.c
	gcc lex.yy.c -o pascal-tokens -lfl

lex.yy.c : pascal-tokens.lex
	flex pascal-tokens.lex

clean :
	rm pascal-tokens lex.yy.c