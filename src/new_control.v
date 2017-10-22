`include "def_funct_field.v"
`include "def_mips_isa.v"
`include "def_instr_fields.v"

`define CONTROL_SIZE `LAST_PROPERTY_BIT:0
`define ALU_OPCODE_SIZE 5:0

`define SET_ALU_OPCODE(ALU_OPCODE) alu_opcode_int <= ALU_OPCODE
`define SET_CONTROLS(CONTROLS) control_int <= CONTROLS

`define SET_DEFAULT_NOOP \
				default: \
				begin \
					`SET_ALU_OPCODE(`FUNCT_NOOP); \
					`SET_CONTROLS(`CONTROL_NOOP); \
				end

`define START_REGISTERING_OPERATIONS case (opcode_i)
`define STOP_REGISTERING_OPERATIONS endcase
`define REGISTER_OPERATION(OPCODE, ALU_OPCODE, CONTROLS) \
				OPCODE: \
				begin \
					`SET_ALU_OPCODE(ALU_OPCODE); \
					`SET_CONTROLS(CONTROLS); \
				end

`define START_REGISTERING_RTYPE case (funct_i)
`define STOP_REGISTERING_RTYPE endcase
`define START_REGISTERING_BRANCH case (branch_type_i)
`define STOP_REGISTERING_BRANCH endcase
`define REGISTER_RTYPE(FUNCT, CONTROLS) \
				FUNCT: \
				begin \
					`SET_ALU_OPCODE(funct_i); \
					`SET_CONTROLS(CONTROLS); \
				end

module mips_control(
	input	wire						clk_i,
	input	wire	[`OPCODE_SIZE]		opcode_i,
	input	wire	[`FUNCT_SIZE]		funct_i,
	input	wire	[`RT_SIZE]			branch_type_i,
	output	wire	[`CONTROL_SIZE]		control_o,
	output	wire	[`ALU_OPCODE_SIZE]	alu_opcode_o,
	input wire reset_i
	);

	reg [`CONTROL_SIZE] control_int;
	reg [`ALU_OPCODE_SIZE]   alu_opcode_int;
	assign control_o = control_int;
	assign alu_opcode_o = alu_opcode_int;

	// TODO: check that
	//always @ ( posedge clk_i )
	always @ ( * )
	begin
		if ( !reset_i )
		begin
			// R-Type instructions require different register step
			//	since they share same opcode 0x00, funct field is their ID
			if (opcode_i == `R_TYPE_OPCODE)	// R-type
			begin
				// Unfolds into switch case
				`START_REGISTERING_RTYPE
					`REGISTER_RTYPE(`FUNCT_JMP,	`JR_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_JALR,`JALR_CONTROL_FLAGS)
					
					`REGISTER_RTYPE(`FUNCT_ADD,	`ADD_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_ADDu,`ADDU_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_SUB,	`SUB_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_SUBu,`SUBU_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_AND,	`AND_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_OR,	`OR_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_XOR,	`XOR_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_NOR,	`NOR_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_SLT,	`SLT_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_SLTu,`SLTU_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_SLL,	`SLL_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_SRL,	`SRL_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_SRA,	`SRA_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_SLLv,`SLLV_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_SRLv,`SRLV_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_SRAv,`SRAV_CONTROL_FLAGS)
					
					`REGISTER_RTYPE(`FUNCT_MUL,	`MULT_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_MULu,`MULTU_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_DIV,	`DIV_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_DIVu,`DIVU_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_MFLO,`MFLO_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_MFHI,`MFHI_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_MTLO,`MTLO_CONTROL_FLAGS)
					`REGISTER_RTYPE(`FUNCT_MTHI,`MTHI_CONTROL_FLAGS)
					`SET_DEFAULT_NOOP
				`STOP_REGISTERING_RTYPE
			end
			else if (opcode_i == `BRANCH_COMP_OPCODE)
			begin
				// Unfolds into switch case
				`START_REGISTERING_BRANCH
					`REGISTER_OPERATION(`BGEZ_BRN_FIELD,	`BGEZ_ALUOP,	`BGEZ_CONTROL_FLAGS)
					`REGISTER_OPERATION(`BGEZAL_BRN_FIELD,	`BGEZAL_ALUOP,	`BGEZAL_CONTROL_FLAGS)
					`REGISTER_OPERATION(`BLTZ_BRN_FIELD,	`BLTZ_ALUOP,	`BLTZ_CONTROL_FLAGS)
					`REGISTER_OPERATION(`BLTZAL_BRN_FIELD,	`BLTZAL_ALUOP,	`BLTZAL_CONTROL_FLAGS)
					`SET_DEFAULT_NOOP
				`STOP_REGISTERING_BRANCH
			end		
			else if (opcode_i == `BLEZ_OPCODE)
			begin
				// Unfolds into switch case
				`START_REGISTERING_BRANCH
					`REGISTER_OPERATION(`BLEZ_BRN_FIELD,	`BLEZ_ALUOP,	`BLEZ_CONTROL_FLAGS)
					`SET_DEFAULT_NOOP
				`STOP_REGISTERING_BRANCH
			end
			else if (opcode_i == `BGTZ_OPCODE)
			begin
				// Unfolds into switch case
				`START_REGISTERING_BRANCH
					`REGISTER_OPERATION(`BGTZ_BRN_FIELD,	`BGTZ_ALUOP,	`BGTZ_CONTROL_FLAGS)
					`SET_DEFAULT_NOOP
				`STOP_REGISTERING_BRANCH
			end
			else
			begin	
				// Unfolds into switch case
				//	NB: JR instruction is R-Type
				`START_REGISTERING_OPERATIONS
					`REGISTER_OPERATION(`ADDI_OPCODE,	`ADDI_ALUOP,	`ADDI_CONTROL_FLAGS)
					`REGISTER_OPERATION(`ADDIU_OPCODE,	`ADDIU_ALUOP,	`ADDIU_CONTROL_FLAGS)
					`REGISTER_OPERATION(`ANDI_OPCODE, 	`ANDI_ALUOP,	`ANDI_CONTROL_FLAGS)
					`REGISTER_OPERATION(`ORI_OPCODE,	`ORI_ALUOP,		`ORI_CONTROL_FLAGS)
					`REGISTER_OPERATION(`XORI_OPCODE,	`XORI_ALUOP,	`XORI_CONTROL_FLAGS)
					`REGISTER_OPERATION(`SLTI_OPCODE,	`SLTI_ALUOP,	`SLTI_CONTROL_FLAGS)
					`REGISTER_OPERATION(`SLTIU_OPCODE,	`SLTIU_ALUOP,	`SLTI_CONTROL_FLAGS)
					`REGISTER_OPERATION(`BEQ_OPCODE,	`BEQ_ALUOP,		`BEQ_CONTROL_FLAGS)
					`REGISTER_OPERATION(`BNE_OPCODE,	`BNE_ALUOP,		`BNE_CONTROL_FLAGS)
					`REGISTER_OPERATION(`J_OPCODE,		`J_ALUOP,		`J_CONTROL_FLAGS)
					`REGISTER_OPERATION(`JAL_OPCODE,	`JAL_ALUOP,		`JAL_CONTROL_FLAGS)
					`REGISTER_OPERATION(`LBU_OPCODE,	`LBU_ALUOP,		`LBU_CONTROL_FLAGS)
					`REGISTER_OPERATION(`LHU_OPCODE,	`LHU_ALUOP,		`LHU_CONTROL_FLAGS)
					`REGISTER_OPERATION(`LB_OPCODE,		`LB_ALUOP,		`LB_CONTROL_FLAGS)
					`REGISTER_OPERATION(`LH_OPCODE,		`LH_ALUOP,		`LH_CONTROL_FLAGS)
					`REGISTER_OPERATION(`LUI_OPCODE,	`LUI_ALUOP,		`LUI_CONTROL_FLAGS)
					`REGISTER_OPERATION(`LW_OPCODE,		`LW_ALUOP,		`LW_CONTROL_FLAGS)
					`REGISTER_OPERATION(`SB_OPCODE,		`SB_ALUOP,		`SB_CONTROL_FLAGS)
					`REGISTER_OPERATION(`SH_OPCODE,		`SH_ALUOP,		`SH_CONTROL_FLAGS)
					`REGISTER_OPERATION(`SW_OPCODE,		`SW_ALUOP,		`SW_CONTROL_FLAGS)
					`SET_DEFAULT_NOOP
				`STOP_REGISTERING_OPERATIONS
			end
		end
		else
		begin
			control_int <= 0;
			alu_opcode_int <= 0;
		end
	end
	
endmodule