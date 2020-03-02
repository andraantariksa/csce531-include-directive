digit           [0-9]
int_const       [+-]?{digit}+
exponent	    [Ee][+-]?{int_const}
real_const	    {int_const}"."{int_const}{exponent}?
alpha           [a-zA-Z]
alphanum        ({alpha}|{digit})+
identifier      {alpha}({alphanum}|_)*
str_const       "\""[^"]*"\""
whitespace      [ \t]+

%{
    int line_no = 0;
    char *preproc_key = NULL, *preproc_value = NULL;
    #include "dictionary.h"
%}

%x COMMENT_MULTILINE
%x PREPROC
%x PREPROC_DEFINE_KEY
%x PREPROC_DEFINE_DEFINITION
%x PREPROC_DEFINE_END

%%
    /* PREPROC */
<INITIAL>[^#\n]*"#"    {
    //printf("Begin preproc\n");
    BEGIN(PREPROC);
}
<PREPROC>"define"{whitespace}   {
    BEGIN(PREPROC_DEFINE_KEY);
}
<PREPROC>"include"{whitespace}?({str_const}|"<"[^>]*">")   {
    printf("#%s", yytext);
    BEGIN(INITIAL);
}
<PREPROC>.   {
    printf("#%s", yytext);
    BEGIN(INITIAL);
}
<PREPROC>\n  {
    //printf("End preproc. Unrecognized\n");
    BEGIN(INITIAL);
}
<PREPROC_DEFINE_KEY>{identifier}    {
    preproc_key = strdup(yytext);
    //printf("Preproc key=%s\n", yytext);
    BEGIN(PREPROC_DEFINE_DEFINITION);
}
<PREPROC_DEFINE_DEFINITION>{whitespace}
<PREPROC_DEFINE_DEFINITION>{identifier}  {
    preproc_value = strdup(yytext);
    add_id_to_dict(preproc_key, preproc_value);

    preproc_key = NULL;
    preproc_value = NULL;
    //printf("Preproc value=%s\n", yytext);
    BEGIN(PREPROC_DEFINE_END);
}
<PREPROC_DEFINE_DEFINITION>{int_const}  {
    add_int_to_dict(preproc_key, atol(yytext));

    preproc_key = NULL;
    preproc_value = NULL;
    //printf("Preproc value=%s\n", yytext);
    BEGIN(PREPROC_DEFINE_END);
}
<PREPROC_DEFINE_DEFINITION>{str_const}  {
    preproc_value = strdup(yytext);
    add_str_to_dict(preproc_key, preproc_value);

    preproc_key = NULL;
    preproc_value = NULL;
    //printf("Preproc value=%s\n", yytext);
    BEGIN(PREPROC_DEFINE_END);
}
<PREPROC_DEFINE_END>[^\n]
<PREPROC_DEFINE_END>[\n]    {
    //printf("End preproc define\n");
    BEGIN(INITIAL);
}
    /* END PREPROC */

    /*
    "pp" {
        print_contents();
    }
    */

"int"       |
"float"     |
"double"    |
"char"      {
    printf("%s", yytext);
    //printf("Data type=%s\n", yytext);
}
"if"        |
"else"      |
"while"     |
"return"    |
"for"       {
    printf("%s", yytext);
    //printf("Keyword=%s\n", yytext);
}

    /* VALUE */
{int_const}   {
    printf("%s", yytext);
    //printf("Integer=%s\n", yytext);
}
{real_const}   {
    printf("%s", yytext);
    //printf("Real=%s\n", yytext);
}
{identifier}    {
    if (!output_substitution(stdout, yytext))
        printf("%s", yytext);
    //printf("Identifier=%s\n", yytext);
}
{str_const}   {
    printf("%s", yytext);
    //printf("String=%s\n", yytext);
}
    /* END OF VALUE */

    /* ONE LINE COMMENT */
"//"[^\n]*  {
    //printf("One line comment\n");
    printf("%s", yytext);
}

    /* START MULTIPLE LINE COMMENT */
<INITIAL>"/*"   {
    //printf("Start multiple line comment\n");
    printf("%s", yytext);
    BEGIN(COMMENT_MULTILINE);
}
<COMMENT_MULTILINE>"*/" {
    //printf("End multiple line comment\n");
    printf("%s", yytext);
    BEGIN(INITIAL);
}
<COMMENT_MULTILINE>[^*\n]+  {
    printf("%s", yytext);
}
<COMMENT_MULTILINE>"*"  {
    printf("%s", yytext);
}
<COMMENT_MULTILINE>[\n] {
    printf("%s", yytext);
}
    /* END MULTIPLE LINE COMMENT */

[\n]  {
    printf("%s", yytext);
    ++line_no;
}
[ \t]+  {
    printf("%s", yytext);
}
.   {
    printf("%s", yytext);
}
%%

int yywrap()
{
    return 1;
}

int main(int argc, char **argv)
{
    if (argc > 1)
    {
        FILE *input = fopen(argv[1], "r");
        if (input != NULL)
        {
            yyin = input;
        }
    }
    
    init_dict();

    yylex();

    if (DEBUG)
    {
        print_contents();
    }

    return 0;
}
