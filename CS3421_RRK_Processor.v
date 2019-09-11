/******************************************************
* Name of Program: CS3421_RRK_Processor
* Author:          Roge' Kuntz
* Date Created:    12 / 7 / 2018
* Date Modified:   12 / 13 / 2018
* Function:        Arithmtic Logic Unit
*******************************************************/

module CS3421_RRK_Processor(input clk, 
	output [31:0] PC_Value, output [31:0] Instruction, 
	output Jump, output PC_Scr, 
	output [31:0] Result);
	
	
	wire clk2;
	wire clk3;
	
	
	wire [31:0] PC_Mux;	// PC Mux stuff
	wire [31:0] PC_Next;	//Next value of PC
	//wire [31:0] PC_Value;	// value of PC
	
	wire [31:0] PC_Plus4;	// PC increment
	wire PC_Plus4_CarryOut;
	
	
	
	//wire [31:0] Instruction;	//InstMem output
	wire [5:0] Instr_Op_Code;	//Instruction[31:26]
	wire [4:0] Instr_A1_Adr;	//Instruction[25:21]
	wire [4:0] Instr_A2_Adr;	//Instruction[20:16]
	wire [4:0] Instr_A3_Adr;	//Instruction[15:11]
	wire [5:0] Instr_Funct_Code; //Instruction[5:0]
	wire [15:0] Instr_Imm_Value; //Instruction[15:0]
	wire [25:0] Instr_Jump_Imm; //Instruction[25:0]
	
	
	wire [31:0] PC_Jump;
	
	wire [4:0] WriteReg;	// RegFile input
	
	wire [31:0] RD1; // RegFile output
	wire [31:0] RD2; 
	
	wire [31:0] SignImm; // SignExtend output
	
	wire [31:0] PC_Branch;	
	wire PC_Branch_CarryOut;	
	
	wire [31:0] ScrB;	// ALU input
	
	wire [31:0] ALU_Result;	// ALU output
	wire ALU_Zero;
	
	//wire PC_Scr; // Branch signal
	
	wire [31:0] ReadData; // DataMem output
	
	//wire [31:0] Result;	// ALU/DataMem out /////////////////////////
	
	
	wire Memto_Reg;	// control signals
	wire Mem_Write;
	wire BranchEq;
	wire BranchNE;
	wire [2:0] ALU_Control;
	wire ALU_Src;
	wire Reg_Dst;
	wire Reg_Write;
	//wire Jump;
	wire Zero_Extend;
	
	
	
	
	DataClock DC_1(clk, clk2);
	DataClock DC_2(clk2, clk3);
	
	mux2to1 PC_Mux_1(PC_Scr, PC_Plus4, PC_Branch, PC_Mux);	//input select, input [31:0] w0, input [31:0] w1, output reg [31:0] y
	mux2to1 PC_Mux_2(Jump, PC_Mux, PC_Jump, PC_Next);
	
	Program_Counter PC(clk, PC_Next, PC_Value);	//input clk, input [31:0] dataIn, output reg [31:0] dataOut
	
	adder32 PCPlus4_Mux(PC_Value, /*32'd4*/ 32'd1, 1'b0, PC_Plus4, PC_Plus4_CarryOut);	//input [31:0] A, input [31:0] B, input carryIn, output [31:0] sum, output carryOut
	
	Instruction_Memory InstMem(PC_Value, Instruction);	//input [31:0] A, output reg [31:0] RD
	
	assign Instr_Op_Code = Instruction[31:26];
	assign Instr_A1_Adr = Instruction[25:21];
	assign Instr_A2_Adr = Instruction[20:16];
	assign Instr_A3_Adr = Instruction[15:11];
	assign Instr_Funct_Code = Instruction[5:0];
	assign Instr_Imm_Value = Instruction[15:0];
	assign Instr_Jump_Imm = Instruction[25:0];
	
	Jump_Shift Jump_Shift_1(Instr_Jump_Imm, PC_Plus4[31:26], PC_Jump);	//input [25:0] Adr, input [3:0] Adr_Rmdr, output [31:0] Out
	
	mux2to1_5 WriteReg_Mux(Reg_Dst, Instr_A2_Adr, Instr_A3_Adr, WriteReg);	//input select, input [4:0] w0, input [4:0] w1, output reg [4:0] y
	
	Register_File RegFile(clk2, Reg_Write, Instr_A1_Adr, Instr_A2_Adr, WriteReg, Result, RD1, RD2);	
																	//input clk2, input WE3, 
																	//input [4:0] A1, input [4:0] A2, input [4:0] A3, 
																	//input [31:0] WD3, 
																	//output reg [31:0] RD1, output reg [31:0] RD2
	
	Sign_Extend Sign_Extend_1(Zero_Extend, Instr_Imm_Value, SignImm);	//input Zero_Extend, input [15:0] In, output [31:0] Out
	
	adder32 PCBranch(SignImm, PC_Plus4, 1'b0, PC_Branch, PC_Branch_CarryOut);	//input [31:0] A, input [31:0] B, input carryIn, output [31:0] sum, output carryOut
	
	mux2to1 ALU_SrcB_Mux(ALU_Src, RD2, SignImm, ScrB);
	
	ALU ArithLogUnit(RD1, ScrB, ALU_Control, ALU_Result, ALU_Zero);	//input [31:0] A, input [31:0] B, input [2:0] F, output wire [31:0] Y, output Zero
	
	assign PC_Scr = ((ALU_Zero & BranchEq) | (~ALU_Zero & BranchNE));	// ProgramCounter Source
	
	Data_Memory DataMem(clk3, Mem_Write, ALU_Result, RD2, ReadData);	//input clk3, input WE, input [31:0] A, input [31:0] WD, output reg [31:0] RD
	
	mux2to1 Result_Mux(Memto_Reg, ALU_Result, ReadData, Result);
	
	Control_Unit CLU(Instr_Op_Code, Instr_Funct_Code, Memto_Reg, Mem_Write, BranchEq, BranchNE, ALU_Control, ALU_Src, Reg_Dst, Reg_Write, Jump, Zero_Extend);
							//input [5:0] Op_Code, input [5:0] Funct, 
							//output reg Memto_Reg, 
							//output reg Mem_Write, 
							//output reg BranchEq, 
							//output reg BranchNE, 
							//output reg [2:0] ALU_Control, 
							//output reg ALU_Src, 
							//output reg Reg_Dst, 
							//output reg Reg_Write, 
							//output reg Jump, 
							//output reg Zero_Extend);
	
endmodule


module Program_Counter(input clk, input [31:0] dataIn, output reg [31:0] dataOut);
	reg [31:0] pcReg;
	
	always @ (posedge clk)
	begin
		pcReg = dataIn;
		//pcReg <= dataIn;	//????????????????? Causes issues?
		dataOut = pcReg;
	end
endmodule


module Instruction_Memory(input [31:0] A, output reg [31:0] RD);
	reg [31:0] insructionMemory [0:1023];
	
	//initial $readmemb("testdata_InstMem_5.txt", insructionMemory);/////////////////////////////////////////////////////////////////////////
	initial $readmemh("tier3test_mod.out", insructionMemory);
	
	always @ (A)
	begin
		RD <= insructionMemory[A];
	end
endmodule


module Register_File(input clk, input WE3, input [4:0] A1, input [4:0] A2, input [4:0] A3, input [31:0] WD3, output reg [31:0] RD1, output reg [31:0] RD2);
	reg [31:0] gpReg [0:31];
	
	//initial $readmemb("testdata_RegFile_5.txt", gpReg); ////////////////////////////////////////////////////////////////////////
	initial 
	begin
		gpReg[0] <= 32'd0;
		//gpReg[1] <= 32'd3;
	end
	
	
	always @ (negedge clk)
	begin
		if (WE3 == 1'b1)
		begin
			gpReg[A3] <= WD3;
		end
	end
	
	always @ (posedge clk)
	begin
		RD1 <= gpReg[A1];
		RD2 <= gpReg[A2];
	end
endmodule


module Data_Memory(input clk, input WE, input [31:0] A, input [31:0] WD, output reg [31:0] RD);
	reg [31:0] dataMemory [0:1023];
	
	//initial $readmemb("testdata_DataMem_5.txt", dataMemory); ////////////////////////////////////////////////////////////////////////
	/*initial
	begin
		dataMemory[6] <= 32'd42;
	end*/
	
	always @ (posedge clk)
	begin
		if (WE == 1'b1)
		begin
			dataMemory[A] <= WD;
		end
		
		RD <= dataMemory[A];
	end
endmodule


module Control_Unit(input [5:0] Op_Code, input [5:0] Funct, 
							output reg Memto_Reg, 
							output reg Mem_Write, 
							output reg BranchEq, 
							output reg BranchNE, 
							output reg [2:0] ALU_Control, 
							output reg ALU_Src, 
							output reg Reg_Dst, 
							output reg Reg_Write, 
							output reg Jump, 
							output reg Zero_Extend);
	
	always @ (Op_Code, Funct)
	begin
		Memto_Reg = 	1'b0;
		Mem_Write = 	1'b0;
		BranchEq = 		1'b0;
		BranchNE = 		1'b0;
		ALU_Control = 3'b000;
		ALU_Src = 		1'b0;
		Reg_Dst = 		1'b0;
		Reg_Write = 	1'b0;
		Jump =			1'b0;
		Zero_Extend = 	1'b0;
	
		case(Op_Code)
			6'b000000:	// R-type
				begin
					//Memto_Reg = 	1'b1;
					//Mem_Write = 	1'b1;
					//BranchEq = 		1'b1;
					//BranchNE = 		1'b1;
					//ALU_Src = 		1'b1;
					Reg_Dst = 		1'b1;
					Reg_Write = 	1'b1;
					//Jump =			1'b1;
					//Zero_Extend = 	1'b1;
					
					case(Funct)
						6'b100000: ALU_Control = 3'b010;	// add
						6'b100010: ALU_Control = 3'b110;	// subtract
						6'b100100: ALU_Control = 3'b000;	// AND
						6'b100101: ALU_Control = 3'b001;	// OR
						6'b101010: ALU_Control = 3'b111;	// SLT
						default: ;
					endcase
				end
			6'b100011:	// lw
				begin
					Memto_Reg = 	1'b1;
					//Mem_Write = 	1'b1;
					//BranchEq = 		1'b1;
					//BranchNE = 		1'b1;
					ALU_Control = 3'b010;
					ALU_Src = 		1'b1;
					//Reg_Dst = 		1'b1;
					Reg_Write = 	1'b1;
					//Jump =			1'b1;
					//Zero_Extend = 	1'b1;
				end
			6'b101011:	//sw
				begin
					//Memto_Reg = 	1'b1;
					Mem_Write = 	1'b1;
					//BranchEq = 		1'b1;
					//BranchNE = 		1'b1;
					ALU_Control = 3'b010;
					ALU_Src = 		1'b1;
					//Reg_Dst = 		1'b1;
					//Reg_Write = 	1'b1;
					//Jump =			1'b1;
					//Zero_Extend = 	1'b1;
				end
			6'b000100:	// beq
				begin
					//Memto_Reg = 	1'b1;
					//Mem_Write = 	1'b1;
					BranchEq = 		1'b1;
					//BranchNE = 		1'b1;
					ALU_Control = 3'b110;
					//ALU_Src = 		1'b1;
					//Reg_Dst = 		1'b1;
					//Reg_Write = 	1'b1;
					//Jump =			1'b1;
					//Zero_Extend = 	1'b1;
				end
				
				
				
			6'b001000:	// addi	///////////////////// Tier 2	//////////////////////////////
				begin
					//Memto_Reg = 	1'b1;
					//Mem_Write = 	1'b1;
					//BranchEq = 		1'b1;
					//BranchNE = 		1'b1;
					ALU_Control = 3'b010;
					ALU_Src = 		1'b1;
					//Reg_Dst = 		1'b1;
					Reg_Write = 	1'b1;
					//Jump =			1'b1;
					//Zero_Extend = 	1'b1;
				end
			6'b000010:	// j	
				begin
					//Memto_Reg = 	1'b1;
					//Mem_Write = 	1'b1;
					//BranchEq = 		1'b1;
					//BranchNE = 		1'b1;
					//ALU_Control = 3'b010;
					//ALU_Src = 		1'b1;
					//Reg_Dst = 		1'b1;
					//Reg_Write = 	1'b1;
					Jump =	1'b1;
					//Zero_Extend = 	1'b1;
				end
			
			
			
			////////////////////////////////////////// Tier 3 : addiu, andi, bne, ori, slti
			6'b001001:	// addiu
				begin
					//Memto_Reg = 	1'b1;
					//Mem_Write = 	1'b1;
					//BranchEq = 		1'b1;
					//BranchNE = 		1'b1;
					ALU_Control = 3'b010;
					ALU_Src = 		1'b1;
					//Reg_Dst = 		1'b1;
					Reg_Write = 	1'b1;
					//Jump =			1'b1;
					Zero_Extend = 	1'b1;
				end
			6'b001100:	// andi
				begin
					//Memto_Reg = 	1'b1;
					//Mem_Write = 	1'b1;
					//BranchEq = 		1'b1;
					//BranchNE = 		1'b1;
					ALU_Control = 3'b000;
					ALU_Src = 		1'b1;
					//Reg_Dst = 		1'b1;
					Reg_Write = 	1'b1;
					//Jump =			1'b1;
					Zero_Extend = 	1'b1;
				end
			6'b000101:	// bne
				begin
					//Memto_Reg = 	1'b1;
					//Mem_Write = 	1'b1;
					//BranchEq = 		1'b1;
					BranchNE = 		1'b1;
					ALU_Control = 3'b110;
					//ALU_Src = 		1'b1;
					//Reg_Dst = 		1'b1;
					//Reg_Write = 	1'b1;
					//Jump =			1'b1;
					//Zero_Extend = 	1'b1;
				end
			6'b001101:	// ori
				begin
					//Memto_Reg = 	1'b1;
					//Mem_Write = 	1'b1;
					//BranchEq = 		1'b1;
					//BranchNE = 		1'b1;
					ALU_Control = 3'b001;
					ALU_Src = 		1'b1;
					//Reg_Dst = 		1'b1;
					Reg_Write = 	1'b1;
					//Jump =			1'b1;
					Zero_Extend = 	1'b1;
				end
			6'b001010:	// slti
				begin
					//Memto_Reg = 	1'b1;
					//Mem_Write = 	1'b1;
					//BranchEq = 		1'b1;
					//BranchNE = 		1'b1;
					ALU_Control = 3'b111;
					ALU_Src = 		1'b1;
					//Reg_Dst = 		1'b1;
					Reg_Write = 	1'b1;
					//Jump =			1'b1;
					//Zero_Extend = 	1'b1;
				end
				
			default: ;
		endcase
	end
endmodule


module Sign_Extend(input Zero_Extend, input [15:0] In, output [31:0] Out);
	reg [15:0] extend;
	
	always @ (In, Zero_Extend)
	begin
		if ((In[15] == 1'b1) & (Zero_Extend == 1'b0))
		begin
			extend = 16'b1111111111111111;
		end
		else
		begin
			extend = 16'b0000000000000000;
		end
	end
	
	assign Out = {extend, In};
endmodule


module Jump_Shift(input [25:0] Adr, input [5:0] Adr_Rmdr, output [31:0] Out);
	//(NOT USED)assign Out = {Adr_Rmdr, Adr, 2'b00};
	assign Out = {Adr_Rmdr, Adr};
endmodule


module mux2to1_5(input select, input [4:0] w0, input [4:0] w1, output reg [4:0] y);

	always@ (*)
	begin
		case(select)
		1'b0: y = w0;
		1'b1: y = w1;
		endcase
	end

endmodule

module DataClock(input clk, output reg DataClk);
	always@ (clk)
	begin
		#10;
		DataClk <= clk;
	end
endmodule


/******************************************************
* Name of Program: ALU
* Author:          Roge' Kuntz
* Date Created:    11 / 4 / 2018
* Date Modified:   12 / 12 / 2018
* Function:        Arithmtic Logic Unit
*******************************************************/

module ALU(input [31:0] A, input [31:0] B, input [2:0] F, output wire [31:0] Y, output Zero);

	wire [31:0] B_mux_wire;
	
	wire [31:0] and_wire;
	wire [31:0] or_wire;
	wire [31:0] add_wire;
	wire [31:0] zeroExtend_wire;
	
	wire carryOut;
	

	mux2to1 mux2to1_1(F[2], B, ~B, B_mux_wire);
	
	assign and_wire = A & B_mux_wire;
	
	assign or_wire = A | B_mux_wire;
	
	adder32 adder32_1(A, B_mux_wire, F[2], add_wire, carryOut);
	
	zeroExtender zeroExtender_1(add_wire[31], zeroExtend_wire);
	
	mux4to1 mux4to1_1(F[1:0], and_wire, or_wire, add_wire, zeroExtend_wire, Y);
	
	equalToZero equalToZero_1(add_wire, Zero);

endmodule


module equalToZero(input [31:0] In, output reg Zero);
	
	always @ (In)
	begin
		if (In == 32'd0)
		begin
			Zero = 1'b1;
		end
		else
		begin
			Zero = 1'b0;
		end
	end
endmodule


module mux2to1(input select, input [31:0] w0, input [31:0] w1, output reg [31:0] y);

	initial
	begin
		y = 32'd0;
	end
	
	always@ (*)
	begin
		case(select)
		1'b0: y = w0;
		1'b1: y = w1;
		endcase
	end

endmodule



module mux4to1(input [1:0] select, input [31:0] w0, input [31:0] w1, input [31:0] w2, input [31:0] w3, output reg [31:0] y);

	always@ (*)
	begin
		case(select)
		2'b00: y = w0;
		2'b01: y = w1;
		2'b10: y = w2;
		2'b11: y = w3;
		endcase
	end

endmodule



module adder32(input [31:0] A, input [31:0] B, input carryIn, output [31:0] sum, output carryOut);
	wire [6:0] Cbetween;
	
	adder4 adder4_0(	  carryIn, A[ 3: 0], B[ 3: 0], sum[ 3: 0], Cbetween[0]);
	adder4 adder4_1(Cbetween[0], A[ 7: 4], B[ 7: 4], sum[ 7: 4], Cbetween[1]);
	adder4 adder4_2(Cbetween[1], A[11: 8], B[11: 8], sum[11: 8], Cbetween[2]);
	adder4 adder4_3(Cbetween[2], A[15:12], B[15:12], sum[15:12], Cbetween[3]);
	adder4 adder4_4(Cbetween[3], A[19:16], B[19:16], sum[19:16], Cbetween[4]);
	adder4 adder4_5(Cbetween[4], A[23:20], B[23:20], sum[23:20], Cbetween[5]);
	adder4 adder4_6(Cbetween[5], A[27:24], B[27:24], sum[27:24], Cbetween[6]);
	adder4 adder4_7(Cbetween[6], A[31:28], B[31:28], sum[31:28], carryOut);

endmodule


module adder4(input Cin, input [3:0] A, input [3:0] B, output [3:0] F, output Cout);
	
	assign F[0] = A[0] ^ B[0] ^ Cin;
	
	assign F[1] = A[1] ^ B[1] ^ ((A[0] & B[0]) | ((A[0] | B[0]) & Cin));
	
	assign F[2] = A[2] ^ B[2] ^ ((A[1] & B[1]) | ((A[1] | B[1]) & ((A[0] & B[0]) | ((A[0] | B[0]) & Cin))));
	
	assign F[3] = A[3] ^ B[3] ^ ((A[2] & B[2]) | ((A[2] | B[2]) & ((A[1] & B[1]) | ((A[1] | B[1]) & ((A[0] & B[0]) | ((A[0] | B[0]) & Cin))))));
	
	assign Cout = (A[3] & B[3]) | ((A[3] | B[3]) & ((A[2] & B[2]) | ((A[2] | B[2]) & ((A[1] & B[1]) | ((A[1] | B[1]) & ((A[0] & B[0]) | ((A[0] | B[0]) & Cin)))))));
	
endmodule


module zeroExtender(input singleBit, output reg [31:0] dataOut);

	always@ (*)
	begin
		case(singleBit)
		1'b0: dataOut = 32'b00000000000000000000000000000000;
		1'b1: dataOut = 32'b00000000000000000000000000000001;
		endcase
	end

endmodule
