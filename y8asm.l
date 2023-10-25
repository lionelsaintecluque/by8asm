%{
    #include "y8.tab.h"
%}

NL [\n\r\l]
CND3 "NEVR"|"IFNC"|"IFNS"|"IFNZ"|"ALWS"|"IFC"|"IFS"|"IFZ"
CND4 "B0Z"|"B1Z"|"B2Z"|"B3Z"|"B0NZ"|"B1NZ"|"B2NZ"|"B3NZ"
G "D1"|"A1"|"D2"|"A2"|"R1"|"R2"|"R3"|"PC";
INST9 "IN"|"OUT"
INST8 "ADD"|"AND"|"ANDN"|"CALL"|"CMPS"|"CMPU"|"OR"|"SET"|"SUB"|"XOR"
INST4 "LDCH"|"LDCL"|"RC"|"RO"|"SA"|"SH" 
INST0  "INV"
%%

[ \t]*          { ; }
{NL}		{ return NL;}
"$"		{ return DOLLAR; }
":"		{ return COLON; }

[0-9]+		{ yylval.value = atoi(yytext); return NUMBER;}
[a-z_]+		{ strcpy(yylval.name,(yytext)); return IDENTIFIER;}


"NEVR"		{ yylval.value = 0; return CND3;}
"IFNC"		{ yylval.value = 1; return CND3;}
"IFNS"		{ yylval.value = 2; return CND3;}
"IFNZ"		{ yylval.value = 3; return CND3;}
"ALWS"		{ yylval.value = 4; return CND3;}
"IFC"		{ yylval.value = 5; return CND3;}
"IFS"		{ yylval.value = 6; return CND3;}
"IFZ"		{ yylval.value = 7; return CND3;}
"B0Z"		{ yylval.value = 0; return CND4;}
"B1Z"		{ yylval.value = 0; return CND4;}
"B2Z"		{ yylval.value = 0; return CND4;}
"B3Z"		{ yylval.value = 0; return CND4;}
"B0NZ"		{ yylval.value = 0; return CND4;}
"B1NZ"		{ yylval.value = 0; return CND4;}
"B2NZ"		{ yylval.value = 0; return CND4;}
"B3NZ"		{ yylval.value = 0; return CND4;}

"D1"		{ yylval.value = 2; return REG;}
"A1"		{ yylval.value = 2; return REG;}
"D2"		{ yylval.value = 2; return REG;}
"A2"		{ yylval.value = 2; return REG;}
"R1"		{ yylval.value = 2; return REG;}
"R2"		{ yylval.value = 2; return REG;}
"R3"		{ yylval.value = 2; return REG;}
"PC"		{ yylval.value = 2; return REG;}

"IN"		{ yylval.value = 12 * 2^12; return INST9;}
"OUT"		{ yylval.value = 13 * 2^12; return INST9;}
"PF"		{ yylval.value = 14 * 2^12; return INST_PF;}

"OR"		{ yylval.value = 0 * 2^12; return INST8;}
"XOR"		{ yylval.value = 1 * 2^12; return INST8;}
"AND"		{ yylval.value = 2 * 2^12; return INST8;}
"ANDN"		{ yylval.value = 3 * 2^12; return INST8;}
"CMPU"		{ yylval.value = 4 * 2^12; return INST8;}
"CMPS"		{ yylval.value = 5 * 2^12; return INST8;}
"SUB"		{ yylval.value = 6 * 2^12; return INST8;}
"ADD"		{ yylval.value = 7 * 2^12; return INST8;}
"SET"		{ yylval.value = 8 * 2^12; return INST8;}
"CALL"		{ yylval.value = 9 * 2^12; return INST8;}

"SH" 		{ yylval.value = 320 * 2^7; return INST4;}
"SA"		{ yylval.value = 321 * 2^7; return INST4;}
"RO"		{ yylval.value = 322 * 2^7; return INST4;}
"RC"		{ yylval.value = 323 * 2^7; return INST4;}
"LDCH"		{ yylval.value = 324 * 2^7; return INST4;}
"LDCL"		{ yylval.value = 325 * 2^7; return INST4;}

"INV"		{ yylval.value = 0; return INST0;}

".ORG"		{ return ORG;}
".END"		{ return END;}
".DW"		{ return DW;}
".EQU"		{ return EQU;}
".FWD"		{ return FWD;}


%%


int yywrap() {
    return 1;
}
