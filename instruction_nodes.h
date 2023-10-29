struct immediate* mkimm(char *name, int value);
struct immediate {
	char *name;
	int value;
};

#define ORG_t 0
#define INS_t 1
#define DW_t 2
struct instruction* mkinst_instr(int opcode, struct immediate* immediate, int pc, int line);
struct instruction {
	char *label;
	int opcode;
	int line;
	char type;
	int pc;
	char imm_resolved;
	struct immediate *immediate;
	struct instruction* next;
};

struct instruction* mkinst_imm(int instruction, struct immediate* imm, char imm_s, int snd, int cnd, int PC, int line);
struct instruction* mkinst_reg(int instruction, int sri, int snd, int cnd, char cnd_s, int PC, int line);
struct instruction* mkinst_label(char *label, int pc, int line);
struct instruction* mkinst_dw(int dw, int pc, int line);

struct instruction* print_instruction (struct instruction* instruction);
