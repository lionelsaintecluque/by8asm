%{  
    #include <stdio.h>
    #include <string.h>
    #include "instruction_nodes.h"
    int PC = 0;
    int LINE = 1;

    void push_inst(struct instruction *newinst);
    struct instruction *table_instructions = NULL;
    struct instruction *last_instruction = NULL;

    void yyerror(const char *s);
    int yylex();
    int yywrap();

    struct symbole* mksym(char *name, int value, char initialized);
    struct symbole *table_sym = NULL;
    struct symbole {
    	char *name;
    	int value;
	char initialized;
	char line;
    	int count;
	struct symbole *next;
    };
%}

%union {
	char name[20];
	int value;
	struct immediate *imm;
}

%token <value> 	NUMBER CND3 CND4 REG INST9 INST8 INST4 INST0 INST_PF
%token 		DOLLAR COLON ORG END DW EQU  FWD NL 
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

INST_V : INST9 IMM REG 		{ 
	push_inst(mkinst_imm($1, $2, 9, $3, 0, PC, LINE)); 
	if ($2->name == NULL) {
		printf("INST9 NUMBER REG,  %X, %X,%X\n", $1, $2->value, $3); 
	} else {
		printf("INST9 NUMBER REG,  %X, (%s),%X\n", $1, $2->name, $3); 
	} }

     | INST8 IMM REG 		{ 
	push_inst(mkinst_imm($1, $2, 8, $3, 0, PC, LINE));
	printf("INST8 NUMBER REG, %X, %X, %X\n", $1, $2, $3); } 
     | INST8 IMM REG CND3 	{ 
	push_inst(mkinst_imm($1, $2, 8, $3, $4, PC, LINE));
	printf("INST8 NUMBER REG CND3, %X, %X, %X, %X\n", $1, $2, $3, $4); }
     | INST8 REG REG     	{ 
	push_inst(mkinst_reg($1, $2, $3, 0, 3, PC, LINE));
	printf("INST8 REG REG, %X, %X, %X\n", $1, $2, $3); }
     | INST8 REG REG CND3 	{ printf("INST8 REG REG CND3, %X, %X, %X, %X\n", $1, $2, $3, $4); }
     | INST8 REG REG CND4 	{ printf("INST8 REG REG CND4, %X, %X, %X, %X\n", $1, $2, $3, $4); }

     | INST4 IMM REG     	{ 
	push_inst(mkinst_imm($1, $2, 4, $3, 0, PC, LINE));
	printf("INST4 NUMBER REG, %X, %X, %X\n", $1, $2, $3); }
     | INST4 IMM REG CND3 	{ 
	push_inst(mkinst_imm($1, $2, 4, $3, $4, PC, LINE));
	printf("INST4 NUMBER REG CND3, %X, %X, %X, %X\n", $1, $2, $3, $4); }
     | INST4 REG REG     	{ 
	push_inst(mkinst_reg($1, $2, $3, 0, 3, PC, LINE));
	printf("INST4 REG REG, %X, %X, %X\n", $1, $2, $3); }
     | INST4 REG REG CND3 	{ printf("INST4 REG REG CND3, %X, %X, %X, %X\n", $1, $2, $3, $4); }
     | INST4 REG REG CND4 	{ printf("INST4 REG REG CND4, %X, %X, %X, %X\n", $1, $2, $3, $4); }

     | INST0 			{ printf("INST0, %X\n", $1); }

     | DW NUMBER_		{
	push_inst(mkinst_dw($2, PC, LINE));
	printf("DW : %X \n",$2);}
     ;

SYMB_V : IDENTIFIER COLON	{ 
	push_inst(mkinst_label($1, PC, LINE));
	mksym($1, PC, 1);}
     | EQU IDENTIFIER NUMBER_ 	{ mksym($2, $3, 1);}
     | FWD IDENTIFIER 		{ mksym($2, 0,  0);}
     ;

IMM : IDENTIFIER		{ $$ = mkimm( $1, 0);}
     | NUMBER_			{ $$ = mkimm( NULL, $1);}
     ;

NUMBER_ : DOLLAR		{ $$ = PC;}
     | NUMBER			{ $$ = $1;}
     ;

%%


int main(){
    yyparse();


    // Print the listing
    printf( "Instruction Listing :\n" );

    struct insturction *inst_i = table_instructions;
    while ( inst_i != NULL ){
        inst_i = print_instruction(inst_i);
    }
    // Print the Symbol Table
    printf( "Symbol Table :\n" );

    struct symbole *sym = table_sym;
    while ( sym != NULL) {
	printf( "%s, line %d\t: ", sym->name , sym->line);
	if ( sym->initialized ) {
		printf( "%d\n", sym->value, sym->count );
	} else {
		printf( "not initialized\n" );
	}
	sym = sym->next;
	}

    return 0;

}

struct symbole* mksym(char *name, int value, char initialized) {
	struct symbole *newsym = (struct symbole *)malloc(sizeof(struct symbole));
	char *newstr = (char *)malloc(strlen(name)+1);
	
	struct symbole *sym_i = table_sym;
	struct symbole *lastsym = table_sym;

	while (sym_i != NULL) {
		if ( !strcmp(name, sym_i->name) ) {
			printf ("Warning : symbol redefined : %s\n", name) ;
			sym_i->value = value;
			return (sym_i);
		}
		lastsym = sym_i;
		sym_i = sym_i->next;
		
	}
	
	strcpy(newstr, name);
	newsym->name = newstr;
	newsym->value = value;
	newsym->initialized = initialized;
	newsym->count = 0;
	newsym->line = LINE;
	newsym->next = NULL;
	if (lastsym == NULL) {
		table_sym = newsym;
	} else {
		lastsym->next = newsym;
	}
	return (newsym);
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
    fprintf(stderr, "%s\n", msg);
}
