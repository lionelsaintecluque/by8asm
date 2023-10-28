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


"NEVR"		{ yylval.value = 0x0000; return CND3;}
"IFNC"		{ yylval.value = 0x0100; return CND3;}
"IFNS"		{ yylval.value = 0x0200; return CND3;}
"IFNZ"		{ yylval.value = 0x0300; return CND3;}
"ALWS"		{ yylval.value = 0x0400; return CND3;}
"IFC"		{ yylval.value = 0x0500; return CND3;}
"IFS"		{ yylval.value = 0x0600; return CND3;}
"IFZ"		{ yylval.value = 0x0700; return CND3;}
"B0Z"		{ yylval.value = 0x00F0; return CND4;}
"B1Z"		{ yylval.value = 0x01F0; return CND4;}
"B2Z"		{ yylval.value = 0x02F0; return CND4;}
"B3Z"		{ yylval.value = 0x03F0; return CND4;}
"B0NZ"		{ yylval.value = 0x04F0; return CND4;}
"B1NZ"		{ yylval.value = 0x05F0; return CND4;}
"B2NZ"		{ yylval.value = 0x06F0; return CND4;}
"B3NZ"		{ yylval.value = 0x07F0; return CND4;}

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
"PF"		{ yylval.value = 0xE000; return INST_PF;}

"OR"		{ yylval.value = 0x0000; return INST8;}
"XOR"		{ yylval.value = 0x1000; return INST8;}
"AND"		{ yylval.value = 0x2000; return INST8;}
"ANDN"		{ yylval.value = 0x3000; return INST8;}
"CMPU"		{ yylval.value = 0x4000; return INST8;}
"CMPS"		{ yylval.value = 0x5000; return INST8;}
"SUB"		{ yylval.value = 006000; return INST8;}
"ADD"		{ yylval.value = 0x7000; return INST8;}
"SET"		{ yylval.value = 0x8000; return INST8;}
"CALL"		{ yylval.value = 0x9000; return INST8;}

"SH" 		{ yylval.value = 0xA000; return INST4;}
"SA"		{ yylval.value = 0xA0F0; return INST4;}
"RO"		{ yylval.value = 0xA100; return INST4;}
"RC"		{ yylval.value = 0xA1F0; return INST4;}
"LDCH"		{ yylval.value = 0xA200; return INST4;}
"LDCL"		{ yylval.value = 0xA2F0; return INST4;}

"INV"		{ yylval.value = 0xF000; return INST0;}

".ORG"		{ return ORG;}
".END"		{ return END;}
".DW"		{ return DW;}
".EQU"		{ return EQU;}
".FWD"		{ return FWD;}


%%


int yywrap() {
    return 1;
}
