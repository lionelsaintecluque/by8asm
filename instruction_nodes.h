struct immediate* mkimm(char *name, int value);
struct immediate {
	char *name;
	int value;
};

#define ORG_t 0
#define INS_t 1
#define DW_t 2
#define BL_t 3
#define BH_t 4
struct instruction* mkinst_instr(int opcode, struct immediate* immediate, int pc, int line);
struct instruction {
	char *label;
	int opcode;
	int line;
	char type;
	int pc;
	struct immediate *immediate;
	struct instruction_tuple *tuple;
	struct instruction* next;
};

struct instruction* mkinst_imm(int instruction, struct immediate* imm, char imm_s, int snd, int cnd, int PC, int line);
void add_immediate (struct instruction* inst);
struct instruction* mkinst_reg(int instruction, int sri, int snd, int cnd, char cnd_s, int PC, int line);
struct instruction* mkinst_label(char *label, int pc, int line);
struct instruction* mkinst_dw(int dw, int pc, int line);

struct instruction* print_instruction (struct instruction* instruction);

enum instruction_type { IMM9_t, IMM8_t, IMM4_t, INSTPF_t, INSTINV_t, RESERVED_t };
enum instruction_form {IMM_REG, IMM_REG_CND, REG_REG, REG_REG_CND, REG_CND, NO_ARGS};
enum mnemonic_type {
	OR_t	= 0x0000,
	XOR_t	= 0x1000,
	AND_t	= 0x2000,
	ANDN_t	= 0x3000,
	CMPU_t	= 0x4000,
	CMPS_t	= 0x5000,
	SUB_t	= 0x6000,
	ADD_t	= 0x7000,
	SET_t	= 0x8000,
	CALL_t	= 0x9000,
	SH_t	= 0xA000,
	SA_t	= 0xA080,
	RO_t	= 0xA100,
	RC_t	= 0xA180,
	LDCL_t	= 0xA200,
	LDCH_t	= 0xA280,
	IN_t	= 0xC000,
	OUT_t	= 0xD000,
	PF_t	= 0xE000,
	INV_t	= 0xF000
	};
enum REG_t { D1_t = 0, A1_t = 1, D2_t = 2, A2_t = 3, R1_t = 4, R2_t = 5, R3_t = 6, PC_t = 7 };
enum CND_t {
	NEVR	= 0x00,
	IFNC	= 0x02,
	IFNS	= 0x03,
	IFNZ	= 0x06,
	ALWS	= 0x08,
	IFC	= 0x0A,
	IFS	= 0x0C,
	IFZ	= 0x0E,
	B0Z	= 0x01,
	B1Z	= 0x03,
	B2Z	= 0x05,
	B3Z	= 0x07,
	B0NZ	= 0x09,
	B1NZ	= 0x0B,
	B2NZ	= 0x0D,
	B3NZ	= 0x0F,
	};

struct instruction_tuple {
	enum instruction_type type;
	enum instruction_form form;
	enum mnemonic_type mnemonic;
	enum REG_t	sri;
	enum REG_t	snd;
	enum CND_t	cnd;
	char imm_size;
	int immediate;
};

struct instruction_tuple* mk_tuple(int opcode);
