
module TestBench_RegFile(output reg error);
	
	reg WE3;
	reg [4:0] A1;
	reg [4:0] A2;
	reg [4:0] A3;
	reg [31:0] WD3;
	wire [31:0] RD1;
	wire [31:0] RD2;
	
	reg [31:0] expectedOut1;
	reg [31:0] expectedOut2;
	
	reg [111:0] testVectors[31:0];
	reg [4:0] vectorNum;
	reg clk1;
	reg clk2;
	
	//CLA_32(input [31:0] A, input [31:0] B, input Cin, output [31:0] F, output Coutput);
	//CLA_32 DUT(operandA, operandB, carryIn, result, carryOut);
	//Program_Counter DUT(clk1, In, result);
	//Instruction_Memory DUT(RegAddress, result);
	Register_File DUT(clk1, WE3, A1, A2, A3, WD3, RD1, RD2);
	
	initial	// read in data
	begin
		$readmemb("testvector_RegFile.txt", testVectors);
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
		{WE3, A1, A2, A3, WD3, expectedOut1, expectedOut2} = testVectors[vectorNum];
	end
	
	always@(negedge clk2)	// compare module output to expected output
	begin
		error = 1'b0;
		if ((RD1 !== expectedOut1) | (RD2 !== expectedOut2))
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
