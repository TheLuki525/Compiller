%{
#define INFILE_ERROR 1
#define OUTFILE_ERROR 2

#include <stdlib.h>
#include <string.h>
#include "def.tab.hh"

int yyerror(const char *,...);
extern int yylineno;
%}
%%
"int"		{return INT;} 
"float"		{return FLOAT;} 
"string"	{return STRING;} 
"if"		{return IF;} 
"else"		{return ELSE;} 
"while"		{return WHILE;} 
"print"		{return PR;}
"println"	{return PRN;}
"read"		{return RD;}
\+			{return '+';} 
\*			{return '*';}
\(			{return '(';}
\)			{return ')';}
\[			{return '[';}
\{			{return '{';}
\}			{return '}';}
\"			{return '"';}
\]			{return ']';}
\/			{return '/';}
\-			{return '-';}
\=\=		{return EQ;}
\>			{return '>';}
\>\=		{return GEQ;}
\<			{return '<';}
\<\=		{return LEQ;}
\!\=		{return NEQ;}
\=			{return '=';}
\/\/		{return KOM;}
[1-9][0-9]*|0	{
				yylval.ival = atoi(yytext);
				return LC;
			}
([1-9][0-9]*|0)\.[0-9]+ {
				yylval.fval = atof(yytext);
				return LR;
			}			
[A-Za-z][A-Za-z0-9]*	{
				yylval.text = strdup(yytext);
				return ID;
			}
\ |\t		{;}
\n			{yylineno++;}
\;			{return ';';}
.			{yyerror("Lexical error\n");}
%%
int yyerror(const char *msg,...)
{
	printf("%d: %s", yylineno, msg);
	exit(1);
}

