#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "immediates.h"
#include "instruction_nodes.h"

const char* REG_l[] = {"D1", "A1", "D2", "A2", "R1", "R2", "R3", "PC"};
//const char* CND_l[] = { "NEVR", "IFNC", "IFNS", "IFNZ", "ALWS", "IFC", "IFS", "IFZ", "B0Z",
//"B1Z", "B2Z", "B3Z", "B0NZ", "B1NZ", "B2NZ", "B3NZ" };
const char* CND_l[] = { "NEVR", "IFN0", "IFNC", "IFN1", "IFNS", "IFN2", "IFNZ", "IFN3", 
"ALWS", "IF0", "IFC", "IF1", "IFS", "IF2", "IFZ", "IF3" };

struct instruction* mkinst_instr(int opcode, struct immediate* immediate, int pc, int line) {
	struct instruction *newinst = (struct instruction *)malloc(sizeof(struct instruction));

	newinst->type = INS_t;
	newinst->label = NULL;
	newinst->pc = pc;
	newinst->line = line;
	newinst->opcode = opcode;
	newinst->immediate = immediate;
	newinst->next = NULL;
	newinst->tuple = NULL;
	return (newinst);
}

struct instruction* mkinst_imm(int instruction, struct immediate* imm, char imm_s, int snd, int cnd, int pc, int line) {

	int opcode = 0;
	if ( (instruction & 0xF000) == 0xA000 )
		opcode = (instruction & 0xFF80) | 0x0C00 | (snd & 0X0007);
	else {
		opcode = (instruction & 0xF000) | (snd & 0X0007);
		if (imm_s == 8) { 
			opcode |= 0X0800;
		} else if ( imm_s == 4) {
			opcode |= 0X0400;
			opcode |= (cnd << 6) & 0x0380;
		} else if (imm_s != 9) { return NULL; }
	}

	struct instruction* newinst = mkinst_instr(opcode, imm, pc, line);
	return newinst;
}

struct instruction* mkinst_reg(int instruction, int sri, int snd, int cnd, char cnd_s, int pc, int line) {

	int opcode = 0;
	if ( (instruction & 0xF000) == 0xA000 )
		opcode = (instruction & 0xFF80) | (snd & 0X0007);
	else {
		opcode = (instruction & 0xF000) | (snd & 0X0007);
		if (cnd_s == 3) { 
			opcode |= (cnd << 6) & 0x0380;
		} else if ( cnd_s == 4) {
			opcode |= (cnd << 6) & 0x03C0;
		}
	}

	if ( 
		(instruction & 0xF000) != INV_t 
	   //&&	(instruction & 0xF000) != PF_t 
	   ) {
		opcode |= (sri & 0X0007 ) << 3;
	}
	struct instruction* newinst = mkinst_instr(opcode, NULL, pc, line);
	return newinst;

}

void add_immediate (struct instruction* inst) {
	if ( inst->type != INS_t) return;
	inst->tuple = mk_tuple(inst->opcode);

	if ( inst->immediate == NULL ) return;

	if ( inst->tuple->form == IMM_REG | inst->tuple->form == IMM_REG_CND ) {
		int value = inst->immediate->value;
		char size = inst->tuple->imm_size;
		int mask = 0;
		switch (size) {
			case 4 : mask = 0XF; break;
			case 8 : mask = 0XFF; break;
			case 9 : mask = 0x1FFF; break;
		}
		if ( value > mask ) 
			if ( inst->immediate->name == NULL) 
				printf ("Symbol %x exceeds immediate size %d bits.\n", inst->immediate->value, size);
			else
				printf ("Symbol %x<%s> exceeds immediate size %d bits.\n", inst->immediate->value, inst->immediate->name, size);
		value = value & mask;
		inst->tuple->immediate = value;
		inst->opcode += value << 3;
	}
	
}

struct instruction* mkinst_label(char *label, int pc, int line) {
	struct instruction *newinst = (struct instruction *)malloc(sizeof(struct instruction));

	if ( label == NULL ) {
		newinst->label = NULL;
	} else { char *newstr = (char *)malloc(strlen(label)+1);
		strcpy(newstr, label);
		newinst->label = newstr;
	}
	newinst->type = ORG_t;
	newinst->pc = pc;
	newinst->line = line;
	newinst->opcode = 0;
	newinst->immediate = NULL;
	newinst->next = NULL;
	newinst->tuple = NULL;
	return (newinst);
}

struct instruction* mkinst_dw(int dw, int pc, int line) {
	struct instruction *newinst = (struct instruction *)malloc(sizeof(struct instruction));

	newinst->type = DW_t;
	newinst->label = NULL;
	newinst->pc = pc;
	newinst->line = line;
	newinst->opcode = dw; 
	newinst->immediate = NULL;
	newinst->next = NULL;
	newinst->tuple = NULL;
	return (newinst);
}


/******************************************************************************/
// Disassemble
/******************************************************************************/
struct instruction_tuple* mk_tuple(int opcode) {
	enum instruction_type type;
	enum instruction_form form;
	enum mnemonic_type mnemonic;
	int immediate = 0;
	char imm_size = 0;
	char sri = 0;
	char cnd = 0;
	char snd = 0;

	// Mnemonic
	mnemonic = opcode & 0xF000;
	if (mnemonic < 0xA000) {
		type = IMM8_t;
	} else if (mnemonic == 0xA000) {
		type = IMM4_t;
		mnemonic = opcode & 0xF380;
	} else if (mnemonic == 0xB000) {
		type = RESERVED_t; // Reserved for 1R1W
	} else if (mnemonic == 0xC000) {
		type = IMM9_t;
	} else if (mnemonic == 0xD000) {
		type = IMM9_t;
	} else if (mnemonic == 0xE000) {
		type = INSTPF_t;
	} else if (mnemonic == 0xF000) {
		type = INSTINV_t;
	}

	// IMM or REG
	if ( type == INSTINV_t ) { 
		form = NO_ARGS;
	} else if ( type == INSTPF_t ) { 
		form = REG_CND;
	} else if ( type == IMM9_t ){ 
		imm_size = 9;
		immediate = (opcode & 0xFF8)>>3;
		form = IMM_REG; 
	} else if (opcode & 0x0800) {
		imm_size = 8;
		immediate = (opcode & 0x07F8)>>3;
		form = IMM_REG;
	} else if (opcode & 0x0400) {
		imm_size = 4;
		immediate = (opcode & 0x0078)>>3;
		form = IMM_REG_CND;
		if ( type == IMM4_t ) {form = IMM_REG;}
	} else {
		sri = (opcode & 0x0038)>>3;
		form = REG_REG_CND;
		if ( type == IMM4_t ) {form = REG_REG;}
	}

	// CND
	if ( form == IMM_REG_CND ) {
		cnd = (opcode & 0x0380) >> 6;
	} else if ( form == REG_REG_CND | form == REG_CND ) {
		cnd = (opcode & 0x03C0) >> 6;
	}

	// SND
	snd = opcode & 0x0007;

	struct instruction_tuple *newtuple = (struct instruction_tuple *)malloc(sizeof(struct instruction_tuple));
	newtuple->type = type;
	newtuple->form = form;
	newtuple->mnemonic = mnemonic;
	newtuple->sri = sri;
	newtuple->snd = snd;
	newtuple->cnd = cnd;
	newtuple->immediate = immediate;
	newtuple->imm_size = imm_size;

	return newtuple;

}

void print_tuple (struct instruction_tuple* tuple, struct immediate* imm){

	//print instruction
	switch (tuple->mnemonic) {
		case OR_t : 	printf("OR "); break;
		case XOR_t :	printf("XOR "); break;
		case AND_t :	printf("AND "); break;
		case ANDN_t :	printf("ANDN "); break;
		case CMPU_t :	printf("CMPU "); break;
		case CMPS_t :	printf("CMPS "); break;
		case SUB_t :	printf("SUB "); break;
		case ADD_t :	printf("ADD "); break;
		case SET_t :	printf("SET "); break;
		case CALL_t :	printf("CALL "); break;
		case SH_t :	printf("SH "); break;
		case SA_t :	printf("SA "); break;
		case RO_t :	printf("RO "); break;
		case RC_t :	printf("RC "); break;
		case LDCL_t :	printf("LDCL "); break;
		case LDCH_t :	printf("LDCH "); break;
		case IN_t :	printf("IN "); break;
		case OUT_t :	printf("OUT "); break;
		case PF_t :	printf("PF "); break;
		case INV_t :	printf("INV "); break;
		default : printf("Unknown instruction "); 
	} 

	// According to the form print arguments
	//if immediate give the xx <label> value
	switch (tuple->form) {
		case REG_REG: 
			printf("%s %s ",REG_l[tuple->sri], REG_l[tuple->snd]); break;
		case REG_REG_CND :
			printf("%s %s ",REG_l[tuple->sri], REG_l[tuple->snd]); 
			if ( tuple->cnd == ALWS) break; 
			printf("%s ", CND_l[tuple->cnd]); break;
		case IMM_REG :
			if ( imm == NULL ) printf ("Missing immediate! ");
			else if (imm->name == NULL)
				printf("%d ", tuple->immediate); 
			else
				printf("%d<%s> ", tuple->immediate, imm->name); 
			printf("%s ", REG_l[tuple->snd]); 
			break;
		case IMM_REG_CND : 
			if ( imm == NULL ) printf ("Missing immediate! ");
			else if (imm->name == NULL)
				printf("%d ", tuple->immediate); 
			else
				printf("%d<%s> ", tuple->immediate, imm->name); 
			printf("%s ", REG_l[tuple->snd]); 
			if ( tuple->cnd == ALWS) break; 
			printf("%s ", CND_l[tuple->cnd]); break;
		case REG_CND : 
			printf("%s ", REG_l[tuple->snd]); 
			if ( tuple->cnd == ALWS) break; 
			printf("%s ", CND_l[tuple->cnd]); break;
		case NO_ARGS : break; // Nothing to print
		default : 
			printf ("Unknown form "); 
	}

}


/******************************************************************************/
// Print
/******************************************************************************/
struct instruction* print_instruction (struct instruction* instruction){
	if ( instruction == NULL ) {
		printf ("NULL INSTRUCTION POINTER \n");
		return NULL;
	} else if ( instruction->type == DW_t) {
		printf("0x%04X:\t%04X\n", instruction->pc, instruction->opcode);
	} else if ( instruction->type == ORG_t) {
		if (instruction->label != NULL) {
			printf("\n0x%04X <%s>,\n", instruction->pc, instruction->label);
		} else {
			printf("\n0x%04X,\n", instruction->pc);
		}
	} else {
		if (instruction->tuple == NULL) {
			instruction->tuple = mk_tuple(instruction->opcode);
		}
		printf("0x%04X:\t0x%04X\t", instruction->pc, instruction->opcode);
		print_tuple (instruction->tuple, instruction->immediate);
		printf("\n");
	}
	
	return instruction->next;
}
