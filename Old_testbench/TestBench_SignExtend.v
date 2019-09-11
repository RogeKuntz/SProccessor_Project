
module TestBench_SignExtend(output reg error);
	
	reg Zero_Extend;
	reg [15:0] In;
	wire [31:0] Out;
	
	reg [31:0] expectedOut;
	
	reg [49:0] testVectors[31:0];
	reg [4:0] vectorNum;
	reg clk;
	
	//CLA_32(input [31:0] A, input [31:0] B, input Cin, output [31:0] F, output Coutput);
	//CLA_32 DUT(operandA, operandB, carryIn, result, carryOut);
	//Program_Counter DUT(clk1, In, result);
	//Instruction_Memory DUT(RegAddress, result);
	//Register_File DUT(clk1, WE3, A1, A2, A3, WD3, RD1, RD2);
	//Data_Memory DUT(clk1, WE, A, WD, RD);	//input WE, input [31:0] A, input [31:0] WD, output reg [31:0] RD
	Sign_Extend DUT(Zero_Extend, In, Out);	//input Zero_Extend, input [15:0] In, output [31:0] Out
	
	initial	// read in data
	begin
		$readmemb("testvector_SignExtend.txt", testVectors);
		//RegAddress = 32'b00000000000000000000000000000000;
		
		vectorNum = 5'd0;
		error = 1'b0;
	end
	
	always	// clock
	begin
		clk = 1'b1;
		#10;
		clk = 1'b0;
		#10;
	end
	
	always @ (posedge clk)	// put inputs into module
	begin
		#1;
		{Zero_Extend, In, expectedOut} = testVectors[vectorNum];
	end
	
	always@(negedge clk)	// compare module output to expected output
	begin
		error = 1'b0;
		if ((Out !== expectedOut))
		begin
			error = 1'b1;
		end
		
		vectorNum = vectorNum + 5'd1;
		if (vectorNum == 5'd8)
		begin
			$finish;
		end
	end
	
endmodule
