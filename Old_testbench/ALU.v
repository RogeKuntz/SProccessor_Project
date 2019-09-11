/******************************************************
* Name of Program: ALU
* Author:          Roge' Kuntz
* Date Created:    11 / 4 / 2018
* Date Modified:   11 / 6 / 2018
* Function:        Arithmtic Logic Unit
*******************************************************/

module ALU(input [31:0] A, input [31:0] B, input [2:0] F, output wire [31:0] Y);

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

endmodule



module mux2to1(input select, input [31:0] w0, input [31:0] w1, output reg [31:0] y);

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
