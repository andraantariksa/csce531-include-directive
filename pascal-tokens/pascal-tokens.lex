%{
    #include <math.h>
%}

number      [0-9]
integer     {number}+
real        {integer}.{integer}([eE][+-]?{integer})?
identifier  [a-zA-Z][a-zA-Z0-9]*
comment     "{"[^}]*"}"

%%
{comment}   {
                printf("Comment:\n---start of comment---\n%s\n--end of comment--\n", yytext);
            }
integer|real    {
                    printf("A data type, %s\n", yytext);
                }
if|then|else|begin|end|procedure|function   {
                                                printf("A Keyword, %s\n", yytext);
                                            }
{identifier}    {
                    printf("An identifier, %s\n", yytext);
                }
{integer}   {
                printf("An integer, %d\n", atoi(yytext));
            }
{real}      {
                printf("A real number, %f\n", atoi(yytext));
            }
"+"|"-"|"*"|"/"|"=" {
                    printf("An operator, %c\n", yytext[0]);
                    }
[ \t\n]+    /* Whitespace */
.   /* Unrecognized character */
%%

int main(int argc, char **argv)
{
    ++argv, --argc;
    if (argc > 0)
    {
        yyin = fopen(argv[0], "r");
    }
    else
    {
        yyin = stdin();
    }
    yylex();
    return 0;
}
