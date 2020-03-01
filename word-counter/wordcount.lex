%{
    int total_char = 0;
    int total_word = 0;
    int total_line = 0;
%}

%%
\n          {
                ++total_line;
            }
[ \t\n]     {
                ++total_char;
            }
[^ \t\n]+   {
                ++total_word;
                total_char += yyleng;
            }
%%

int main()
{
    yylex();
    printf("%d lines, %d words, %d characters", total_line, total_word, total_char);
    return 0;
}
