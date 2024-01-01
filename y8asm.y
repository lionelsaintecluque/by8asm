%{  
/*
 *	PROJECT : Bison - Flex - Y8 assembler
 *	File : y8asm.y
 *	Author : Lionel SAINTE CLUQUE
 *	Licence : GPL V3
 *
 *	Grammar for Y8 assembly language parsing.
 *	Designed with bison 3.8.2
 *	Converts assembly code to chained lists : 
 *		Instructions : List of instruction to be assembled in a program. 
 *		Symbols : list of keywords defined by the author of the assembly code to refer to numerical values. 
 */
    #include <stdio.h>
    #include <string.h>
    #include "instruction_nodes.h"
    #include "immediates.h"
    #include "symbols.h"
    
    int PC = 0;
    int LINE = 1;

    struct symbole* table_sym = NULL;

    void push_inst(struct instruction *newinst);
    struct instruction *table_instructions = NULL;
    struct instruction *last_instruction = NULL;

    void yyerror(const char *s);
    int yylex();
    int yywrap();


    void update_immediates(struct instruction *program, struct symbole *symbols);
%}

%union {
	/* Update y8asm.l when changing SYM_LEN*/
	#define SYM_LEN 24
	char name[SYM_LEN+1];
	
	int value;
	struct immediate *imm;
}

%token <value> 	NUMBER CND3 CND4 REG OVL_ALIAS HLT_ALIAS NOP_ALIAS INST9 INST8 INST4 INST_INV INST_PF
%token 		OPENING_BRACE CLOSING_BRACE DOLLAR COLON ORG END DW EQU  FWD NL 
%token	<value>	BINARY_OP UNARY_OP
%token <name> 	IDENTIFIER
%type  <value>	NUMBER_
%type  <imm>	IMM

%%

FILE : PRG END { printf("End of program reached.\n"); YYACCEPT;}

PRG : %empty
     | PRG NL 			{ LINE++; } 
     | PRG SYMB_V NL		{ LINE++; } 
     | PRG INST_V NL 		{ LINE++; PC++;}
     | PRG ORG NUMBER NL	{ 
	PC = $3; 
	push_inst(mkinst_label(NULL, PC, LINE));
	LINE++;} 
     ;

INST_V : NOP_ALIAS { 
	push_inst(mkinst_reg(OR_t, D1_t, D1_t, NEVR, 3, PC, LINE));
	printf("NOP : INST8 REG REG CND3, %X, %X, %X, %X\n", OR_t, D1_t, D1_t, NEVR); }
     | HLT_ALIAS {
	push_inst(mkinst_imm($1, mkimm( NULL, 255), 8, PC_t, 8, PC, LINE));
	printf("HLT : INST8 NUMBER REG, %X, %X, %X\n", $1, 255, PC_t); } 
     | OVL_ALIAS IMM {
	push_inst(mkinst_imm($1, $2, 8, PC_t, 8, PC, LINE));
	printf("OVL : INST8 NUMBER REG, %X, %X, %X\n", $1, $2, PC_t); } 
     | OVL_ALIAS IMM CND3 	{ 
	push_inst(mkinst_imm($1, $2, 4, PC_t, $3, PC, LINE));
	printf("OVL : INST8 NUMBER REG CND3, %X, %X, %X, %X\n", $1, $2, PC_t, $3); }
     | OVL_ALIAS REG     	{ 
	push_inst(mkinst_reg($1, $2, PC_t, 8, 3, PC, LINE));
	printf("OVL : INST8 REG REG, %X, %X, %X\n", $1, $2, PC_t); }
     | OVL_ALIAS REG CND3 	{ 
	push_inst(mkinst_reg($1, $2, PC_t, $3, 3, PC, LINE));
	printf("OVL : INST8 REG REG CND3, %X, %X, %X, %X\n", $1, $2, PC_t, $3); }
     | OVL_ALIAS REG CND4 	{ 
	push_inst(mkinst_reg($1, $2, PC_t, $3, 4, PC, LINE));
	printf("OVL : INST8 REG REG CND4, %X, %X, %X, %X\n", $1, $2, PC_t, $3); }
	
     | INST9 IMM REG 		{ 
	push_inst(mkinst_imm($1, $2, 9, $3, 8, PC, LINE)); 
	if ($2->name == NULL) {
		printf("INST9 NUMBER REG,  %X, %X,%X\n", $1, $2->value, $3); 
	} else {
		printf("INST9 NUMBER REG,  %X, (%s),%X\n", $1, $2->name, $3); 
	} }

     | INST8 IMM REG 		{ 
	push_inst(mkinst_imm($1, $2, 8, $3, 8, PC, LINE));
	printf("INST8 NUMBER REG, %X, %X, %X\n", $1, $2, $3); } 
     | INST8 IMM REG CND3 	{ 
	push_inst(mkinst_imm($1, $2, 4, $3, $4, PC, LINE));
	printf("INST8 NUMBER REG CND3, %X, %X, %X, %X\n", $1, $2, $3, $4); }
     | INST8 REG REG     	{ 
	push_inst(mkinst_reg($1, $2, $3, 8, 3, PC, LINE));
	printf("INST8 REG REG, %X, %X, %X\n", $1, $2, $3); }
     | INST8 REG REG CND3 	{ 
	push_inst(mkinst_reg($1, $2, $3, $4, 3, PC, LINE));
	printf("INST8 REG REG CND3, %X, %X, %X, %X\n", $1, $2, $3, $4); }
     | INST8 REG REG CND4 	{ 
	push_inst(mkinst_reg($1, $2, $3, $4, 4, PC, LINE));
	printf("INST8 REG REG CND4, %X, %X, %X, %X\n", $1, $2, $3, $4); }

     | INST4 IMM REG     	{ 
	push_inst(mkinst_imm($1, $2, 4, $3, 8, PC, LINE));
	printf("INST4 NUMBER REG, %X, %X, %X\n", $1, $2, $3); }
     | INST4 IMM REG CND3 	{ 
	push_inst(mkinst_imm($1, $2, 4, $3, $4, PC, LINE));
	printf("INST4 NUMBER REG CND3, %X, %X, %X, %X\n", $1, $2, $3, $4); }
     | INST4 REG REG     	{ 
	push_inst(mkinst_reg($1, $2, $3, 8, 3, PC, LINE));
	printf("INST4 REG REG, %X, %X, %X\n", $1, $2, $3); }
     | INST4 REG REG CND3 	{ 
	push_inst(mkinst_reg($1, $2, $3, $4, 3, PC, LINE));
	printf("INST4 REG REG CND3, %X, %X, %X, %X\n", $1, $2, $3, $4); }
     | INST4 REG REG CND4 	{ 
	push_inst(mkinst_reg($1, $2, $3, $4, 4, PC, LINE));
	printf("INST4 REG REG CND4, %X, %X, %X, %X\n", $1, $2, $3, $4); }

     | INST_INV 		{ 
	push_inst(mkinst_reg($1, 0, 0, 0, 0, PC, LINE));
	printf("Instruction INVALID, %X\n", $1); }
     | INST_PF REG		{ 
	push_inst(mkinst_reg($1, 0, $2, 8, 4, PC, LINE));
	printf("INST PF REG , %X, %X\n", $1, $2); }
     | INST_PF REG CND3		{ 
	push_inst(mkinst_reg($1, 0, $2, $3, 3, PC, LINE));
	printf("INST PF REG CND3, %X, %X, %X\n", $1, $2, $3); }
     | INST_PF REG CND4		{ 
	push_inst(mkinst_reg($1, 0, $2, $3, 4, PC, LINE));
	printf("INST PF REG CND4, %X, %X, %X\n", $1, $2, $3); }

     | DW NUMBER_		{
	push_inst(mkinst_dw($2, PC, LINE));
	printf("DW : %X \n",$2);}
     ;

SYMB_V : IDENTIFIER COLON	{ 
	push_inst(mkinst_label($1, PC, LINE));
	mksym($1, PC, 1, LINE, &table_sym);}
     //| EQU IDENTIFIER NUMBER_ 	{ mksym($2, $3, 1, LINE, &table_sym);}
     | EQU IDENTIFIER IMM 	{ mksym($2, $3->value, 1, LINE, &table_sym);}
     | FWD IDENTIFIER 		{ mksym($2, 0,  0, LINE, &table_sym);}
     ;

IMM : IDENTIFIER		{ $$ = mkimm( $1, 0);}
     | NUMBER_			{ $$ = mkimm( NULL, $1);}
     | OPENING_BRACE IMM BINARY_OP IMM CLOSING_BRACE	{
	$$ = immediate_binary_compute($2, $4, $3, table_sym);
	if ($$ == NULL) {
		YYABORT;
		};
	};

NUMBER_ : DOLLAR		{ $$ = PC;}
     | NUMBER			{ $$ = $1;}
     ;

%%


int main(){
    yyparse();

    update_immediates(table_instructions, table_sym);

    // Print the listing
    printf( "Instruction Listing :\n" );

    // Sort instructions based on PC address
    struct instruction *current = table_instructions;
    struct instruction *last = NULL;
    while ( current != NULL ){
	if (last != NULL && current->pc < last->pc) {
		last->next = current->next;
    		struct instruction *i = table_instructions;
		while (i->next->pc <= current->pc) {
			i = i->next;
		}
		current->next = i->next;
		i->next = current;
	} else last = current;
	current = last->next;
    }
    last_instruction = last;

    current = table_instructions;
    last = NULL;
    while ( current != NULL ){
	if (current->next != NULL && current->pc == current->next->pc) {
	//Si BL et BH les inverser 
	//approuver la forme, sinon générer une erreur.
		if (current->type != ORG_t && current->next->type != ORG_t) {
			printf("Error : instruction at address %X redefined : \n", current->pc);
        		print_instruction(current);
        		print_instruction(current->next);
		} else if (current->type != ORG_t) {
			last = current;
		} else if (last != NULL && last->pc == current->next->pc) {
			printf("Error : instruction at address %X redefined : \n", current->pc);
        		print_instruction(last);
        		print_instruction(current->next);
		}
	}
	current = current->next;
    }

    struct instruction *inst_i = table_instructions;

    while ( inst_i != NULL ){
        inst_i = print_instruction(inst_i);
    }
    // Print the Symbol Table
    printf( "Symbol Table :\n" );

    struct symbole *sym = table_sym;
    while ( sym != NULL) {
	printf( "%s, line %d\t: ", sym->name , sym->line);
	if ( sym->initialized ) {
		printf( "%d (%Xh), count : %d\n", sym->value, sym->value, sym->count );
	} else {
		printf( "not initialized\n" );
	}
	sym = sym->next;
	}

    return 0;

}



void update_immediates(struct instruction *program, struct symbole *symbols) {
	struct instruction* inst_i = program;

	while ( inst_i != NULL ){
		if (inst_i->immediate != NULL) {
			if (inst_i->immediate->name != NULL)
				inst_i->immediate->value = get_symbole(inst_i->immediate->name, symbols); 
			add_immediate(inst_i);
		}
		inst_i = inst_i->next;
	}
}

void push_inst( struct instruction* newinst){
	if ( table_instructions == NULL ){
		table_instructions = newinst;
	}  else {
		last_instruction->next = newinst;
	}
	last_instruction = newinst; 
}

void yyerror(const char* msg) {
    fprintf(stderr, "Line %d : %s\n", LINE, msg);
}
