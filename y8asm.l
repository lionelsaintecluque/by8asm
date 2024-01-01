%{
/*
 *	PROJECT : Bison - Flex - Y8 assembler
 *	File : y8asm.l
 *	Author : Lionel SAINTE CLUQUE
 *	Licence : GPL V3
 *
 *	Lexer for Y8 assembly language parsing.
 */
    #include <stdio.h>
    #include <limits.h>
    #include "immediates.h"
    #include "instruction_nodes.h"
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
";".*{NL}	{ return NL;}
{NL}		{ return NL;}
"$"		{ return DOLLAR; }
":"		{ return COLON; }

"("		{ return OPENING_BRACE; }
")"		{ return CLOSING_BRACE; }

"~"		{ yylval.value =  BOOLEAN_NOT; return UNARY_OP;}

"+"		{ yylval.value =  ARITHMETIC_ADD; return BINARY_OP;}
"-"		{ yylval.value =  ARITHMETIC_SUB; return BINARY_OP;}
"*"		{ yylval.value =  ARITHMETIC_MUL; return BINARY_OP;}
"/"		{ yylval.value =  ARITHMETIC_DIV; return BINARY_OP;}
"%"		{ yylval.value =  ARITHMETIC_MOD; return BINARY_OP;}
"^"		{ yylval.value =  BOOLEAN_XOR; return BINARY_OP;}
"|"		{ yylval.value =  BOOLEAN_OR; return BINARY_OP;}
"&"		{ yylval.value =  BOOLEAN_AND; return BINARY_OP;}
">>"		{ yylval.value =  BOOLEAN_SRG; return BINARY_OP;}
"<<"		{ yylval.value =  BOOLEAN_SLF; return BINARY_OP;}
">>>"		{ yylval.value =  ARITHMETIC_SRG; return BINARY_OP;}
"UMIN"		{ yylval.value =  ARITHMETIC_MIN; return BINARY_OP;}
"UMAX"		{ yylval.value =  ARITHMETIC_MAX; return BINARY_OP;}
"SMIN"		{ yylval.value =  ARITHMETIC_SMI; return BINARY_OP;}
"SMAX"		{ yylval.value =  ARITHMETIC_SMA; return BINARY_OP;}


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
"NOP"		{ yylval.value = 0x0000; return NOP_ALIAS;}
"XOR"		{ yylval.value = 0x1000; return INST8;}
"AND"		{ yylval.value = 0x2000; return INST8;}
"ANDN"		{ yylval.value = 0x3000; return INST8;}
"CMPU"		{ yylval.value = 0x4000; return INST8;}
"CMPS"		{ yylval.value = 0x5000; return INST8;}
"SUB"		{ yylval.value = 0x6000; return INST8;}
"ADD"		{ yylval.value = 0x7000; return INST8;}
"SET"		{ yylval.value = 0x8000; return INST8;}
"CALL"		{ yylval.value = 0x9000; return INST8;}
"OVL"		{ yylval.value = 0x9000; return OVL_ALIAS;}
"HLT"		{ yylval.value = 0x9000; return HLT_ALIAS;}

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

[+-]?[0-1]+"b"	{ char* str_i = yytext;
		  int val = 0;
		  char i = 0;
		  char sign = 0; // 0 : Positive number, 1 : negative number

		  if ( *str_i == '+' || *str_i == '-'){
			sign = ( *str_i == '-' ) ? 1 : 0;
			str_i++;
			} 

		  while (*str_i) {
			if (*str_i == 'b' || *str_i == 'B') break;


			if ( 
				//( sign == 0 && (val & (1<<31) ) != 0 ) ||
				( val & (1<<30) ) != 0 
			) printf ("Number overflow : %s\n", yytext);
			

			i = (*str_i >= '0' && *str_i <= '1') ? (*str_i - '0') : i;
			val = (val<<1) | i;
        		str_i++;
		  }
		
		  val = (sign == 0) ? val : -1 * val; 

		  yylval.value = val;
		  return NUMBER;}


[+-]?[0-9a-f]+"h" { char* str_i = yytext;
		  int val = 0;
		  char i = 0;
		  char sign = 0;

		  if ( *str_i == '+' || *str_i == '-'){
			sign = ( *str_i == '-' ) ? 1 : 0;
			str_i++;
			} 

		  while (*str_i) {
			if (*str_i == 'h' || *str_i == 'H') break;

			if ( 
				//( sign == 0 && (val & 0xF0000000) != 0 ) ||
				( val & 0xF8000000 ) != 0 
			) {
				printf ("Number overflow : %s\n", yytext);
			}

			i = (*str_i >= '0' && *str_i <= '9') ? (*str_i - '0') : i;
			i = (*str_i >= 'a' && *str_i <= 'f') ? 10 + (*str_i - 'a') : i;
			i = (*str_i >= 'A' && *str_i <= 'F') ? 10 + (*str_i - 'A') : i;
			val = (val<<4) | i;

        		str_i++;
		  }

		  val = (sign == 0) ? val : -1 * val; 

		  yylval.value = val;
		  return NUMBER;}


[+-]?[0-9]+	{ char* str_i = yytext;
		  int val = 0;
		  char i = 0;
		  char sign = 0;

		  if ( *str_i == '+' || *str_i == '-'){
			sign = ( *str_i == '-' ) ? 1 : 0;
			str_i++;
			} 

		  while (*str_i) {
			if (*str_i == 0 ) break;

			i = (*str_i >= '0' && *str_i <= '9') ? (*str_i - '0') : i;
			val = 10 * val ;
			if ( 
				//( (sign == 0) && 0xFFFFFFFF - val < i ) ||
				0x7FFFFFFF - val < i 
			) {
				printf ("Number overflow : %s\n", yytext);
			}

			val = val + i;

        		str_i++;
		  }

		  val = (sign == 0) ? val : -1 * val; 

		  yylval.value = val;
		  return NUMBER;}

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
