#include <stdlib.h>
#include <string.h>
#include "instruction_nodes.h"

struct immediate* mkimm(char *name, int value) {
	struct immediate *newimm = (struct immediate *)malloc(sizeof(struct immediate));

	if (name == NULL) {
		newimm->name = NULL;
	} else {
		char *newstr = (char *)malloc(strlen(name)+1);
		strcpy(newstr, name);
		newimm->name = newstr;
	}
	newimm->value = value;
	return (newimm);
}

struct instruction* mkinst_label(char *label, int pc, int line) {
	struct instruction *newinst = (struct instruction *)malloc(sizeof(struct instruction));

	if ( label == NULL ) {
		newinst->label = NULL;
	} else { char *newstr = (char *)malloc(strlen(label)+1);
		strcpy(newstr, label);
		newinst->label = newstr;
	}
	newinst->pc = pc;
	newinst->line = line;
	newinst->opcode = 0;
	newinst->immediate = NULL;
	newinst->next = NULL;
	return (newinst);
}

struct instruction* mkinst_instr(int opcode, struct immediate* immediate, int pc, int line) {
	struct instruction *newinst = (struct instruction *)malloc(sizeof(struct instruction));

	newinst->label = NULL;
	newinst->pc = pc;
	newinst->line = line;
	newinst->opcode = opcode;
	newinst->immediate = immediate;
	newinst->next = NULL;
	return (newinst);
}

struct instruction* mkinst_imm(int instruction, struct immediate* imm, char imm_s, int snd, int cnd, int pc, int line) {

	int opcode = instruction & 0xF000 + snd & 0X0007;

	if (imm_s == 8) { 
		opcode |= 0X0800;
	} else if ( imm_s == 4) {
		opcode |= 0X0C00;
		opcode += cnd & 0x038;
	} else if (imm_s != 9) { return NULL; }

	struct instruction* newinst = mkinst_instr(opcode, imm, pc, line);
	return newinst;
}

struct instruction* mkinst_reg(int instruction, int sri, int snd, int cnd, char cnd_s, int pc, int line) {

	int opcode = instruction & 0xF000 + snd & 0X0007;

	if (cnd_s == 3) { 
		opcode |= 0X0C00;
		opcode += cnd & 0x038;
	} else if ( cnd_s == 4) {
		opcode |= 0X0C00;
		opcode += cnd & 0x03C;
	} else  return NULL;

	opcode += (sri & 0X0003 )<< 3;
	struct instruction* newinst = mkinst_instr(opcode, NULL, pc, line);
	return newinst;

}


