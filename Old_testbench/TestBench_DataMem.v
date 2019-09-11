
module TestBench_DataMem(output reg error);
	
	reg WE;
	reg [31:0] A;
	reg [31:0] WD;
	wire [31:0] RD;
	
	reg [31:0] expectedRD;
	
	reg [96:0] testVectors[31:0];
	reg [4:0] vectorNum;
	reg clk1;
	reg clk2;
	
	//CLA_32(input [31:0] A, input [31:0] B, input Cin, output [31:0] F, output Coutput);
	//CLA_32 DUT(operandA, operandB, carryIn, result, carryOut);
	//Program_Counter DUT(clk1, In, result);
	//Instruction_Memory DUT(RegAddress, result);
	//Register_File DUT(clk1, WE3, A1, A2, A3, WD3, RD1, RD2);
	Data_Memory DUT(clk1, WE, A, WD, RD);	//input WE, input [31:0] A, input [31:0] WD, output reg [31:0] RD
	
	initial	// read in data
	begin
		$readmemb("testvector_DataMem.txt", testVectors);
		//RegAddress = 32'b00000000000000000000000000000000;
		
		vectorNum = 5'd0;
		error = 1'b0;
	end
	
	always	// clock
	begin
		#5;
		clk2 = 1'b1;
		#5;
		clk1 = 1'b1;
		#5;
		clk1 = 1'b0;
		clk2 = 1'b0;
		#5;
	end
	
	always @ (posedge clk2)	// put inputs into module
	begin
		#1;
		{WE, A, WD, expectedRD} = testVectors[vectorNum];
	end
	
	always@(negedge clk2)	// compare module output to expected output
	begin
		error = 1'b0;
		if ((RD !== expectedRD))
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
