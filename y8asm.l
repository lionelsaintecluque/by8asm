%{
    #include<stdio.h>
    #include <limits.h>
    #include "y8.tab.h"
%}

NL "\r\n"|"\n"|"\r"
CND3 "NEVR"|"IFNC"|"IFNS"|"IFNZ"|"ALWS"|"IFC"|"IFS"|"IFZ"
CND4 "B0Z"|"B1Z"|"B2Z"|"B3Z"|"B0NZ"|"B1NZ"|"B2NZ"|"B3NZ"
REG "D1"|"A1"|"D2"|"A2"|"R1"|"R2"|"R3"|"PC"
INST9 "IN"|"OUT"
INST8 "ADD"|"AND"|"ANDN"|"CALL"|"CMPS"|"CMPU"|"OR"|"SET"|"SUB"|"XOR"
INST4 "LDCH"|"LDCL"|"RC"|"RO"|"SA"|"SH" 
%%

[ \t,]*          { ; }
{NL}		{ return NL;}
"$"		{ return DOLLAR; }
":"		{ return COLON; }


"NEVR"		{ yylval.value = 0x00; return CND3;}
"IFNC"		{ yylval.value = 0x02; return CND3;}
"IFNS"		{ yylval.value = 0x04; return CND3;}
"IFNZ"		{ yylval.value = 0x06; return CND3;}
"ALWS"		{ yylval.value = 0x08; return CND3;}
"IFC"		{ yylval.value = 0x0A; return CND3;}
"IFS"		{ yylval.value = 0x0C; return CND3;}
"IFZ"		{ yylval.value = 0x0E; return CND3;}
"IFN0"		{ yylval.value = 0x01; return CND4;}
"IFN1"		{ yylval.value = 0x03; return CND4;}
"IFN2"		{ yylval.value = 0x05; return CND4;}
"IFN3"		{ yylval.value = 0x07; return CND4;}
"IF0"		{ yylval.value = 0x09; return CND4;}
"IF1"		{ yylval.value = 0x0B; return CND4;}
"IF2"		{ yylval.value = 0x0D; return CND4;}
"IF3"		{ yylval.value = 0x0F; return CND4;}

"D1"		{ yylval.value = 0; return REG;}
"A1"		{ yylval.value = 1; return REG;}
"D2"		{ yylval.value = 2; return REG;}
"A2"		{ yylval.value = 3; return REG;}
"R1"		{ yylval.value = 4; return REG;}
"R2"		{ yylval.value = 5; return REG;}
"R3"		{ yylval.value = 6; return REG;}
"PC"		{ yylval.value = 7; return REG;}

"IN"		{ yylval.value = 0xC000; return INST9;}
"OUT"		{ yylval.value = 0xD000; return INST9;}

"OR"		{ yylval.value = 0x0000; return INST8;}
"XOR"		{ yylval.value = 0x1000; return INST8;}
"AND"		{ yylval.value = 0x2000; return INST8;}
"ANDN"		{ yylval.value = 0x3000; return INST8;}
"CMPU"		{ yylval.value = 0x4000; return INST8;}
"CMPS"		{ yylval.value = 0x5000; return INST8;}
"SUB"		{ yylval.value = 0x6000; return INST8;}
"ADD"		{ yylval.value = 0x7000; return INST8;}
"SET"		{ yylval.value = 0x8000; return INST8;}
"CALL"		{ yylval.value = 0x9000; return INST8;}

"SH" 		{ yylval.value = 0xA000; return INST4;}
"SA"		{ yylval.value = 0xA080; return INST4;}
"RO"		{ yylval.value = 0xA100; return INST4;}
"RC"		{ yylval.value = 0xA180; return INST4;}
"LDCL"		{ yylval.value = 0xA200; return INST4;}
"LDCH"		{ yylval.value = 0xA280; return INST4;}

"PF"		{ yylval.value = 0xE000; return INST_PF;}
"INV"		{ yylval.value = 0xF000; return INST_INV;}

".ORG"		{ return ORG;}
".END"		{ return END;}
".DW"		{ return DW;}
".EQU"		{ return EQU;}
".FWD"		{ return FWD;}

[0-1]+"b"	{ char* str_i = yytext;
		  int val = 0;
		  int i = 0;
		  while (*str_i) {
			if (*str_i == 'b' || *str_i == 'B') break;

			i = (*str_i >= '0' && *str_i <= '1') ? (*str_i - '0') : i;

			if ( (val & (INT_MIN)) != 0 ) {
				printf ("Number overflow : %s\n", yytext);
			}

        		str_i++;
			val = (val<<1) | i;
		  }	
		  yylval.value = val;
		  return NUMBER;}


[0-9a-f]+"h"	{ char* str_i = yytext;
		  int val = 0;
		  int i = 0;
		  while (*str_i) {
			if (*str_i == 'h' || *str_i == 'H') break;

			i = (*str_i >= '0' && *str_i <= '9') ? (*str_i - '0') : i;
			i = (*str_i >= 'a' && *str_i <= 'f') ? 10 + (*str_i - 'a') : i;
			i = (*str_i >= 'A' && *str_i <= 'F') ? 10 + (*str_i - 'A') : i;


			if ( (val & (INT_MIN | INT_MIN >> 1 | INT_MIN >> 2 | INT_MIN >> 3)) != 0 ) {
				printf ("Number overflow : %s\n", yytext);
			}

        		str_i++;
			val = (val<<4) | i;
		  }	
		  yylval.value = val;
		  return NUMBER;}


[0-9]+		{ yylval.value = atoi(yytext); return NUMBER;}

[a-z_][a-z0-9_]* { char* str_i = yytext;
		  while (*str_i) {
			*str_i = (*str_i >= 'a' && *str_i <= 'z') ? *str_i -= ('a' - 'A') : *str_i;
        		str_i++;
			}
		  if (strlen(yytext) > SYM_LEN ) {
			printf ("Warning: IDENTIFIER length exceeds limit of %u caracters : %s (%u). Truncated :", SYM_LEN, yytext, strlen(yytext));
			yytext[SYM_LEN] = 0;
			printf ("%s\n", yytext);
		  }
		  strcpy(yylval.name,yytext); 
		  return IDENTIFIER;}


%%


int yywrap() {
    return 1;
}
