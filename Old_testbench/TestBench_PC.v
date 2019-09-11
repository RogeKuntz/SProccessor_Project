


module TestBench_PC(output reg error);
	
	/*reg carryIn;
	
	reg [31:0] operandA;
	reg [31:0] operandB;
	wire [31:0] result;
	reg [31:0] expectedResult;
	
	//wire carryOut;
	reg ExpectedCarryOut;
	
	reg [97:0] testVectors[31:0];
	reg [4:0] vectorNum;
	reg clk;*/
	
	
	reg [31:0] In;
	wire [31:0] result;
	reg [31:0] expectedResult;
	
	reg [63:0] testVectors[31:0];
	reg [4:0] vectorNum;
	reg clk1, clk2;
	
	//CLA_32(input [31:0] A, input [31:0] B, input Cin, output [31:0] F, output Coutput);
	//CLA_32 DUT(operandA, operandB, carryIn, result, carryOut);
	Program_Counter DUT(clk1, In, result);
	
	initial	// read in data
	begin
		$readmemb("testvector_PC.txt", testVectors);
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
		{In, expectedResult} = testVectors[vectorNum];
	end
	
	always@(negedge clk2)	// compare module output to expected output
	begin
		error = 1'b0;
		if ((result !== expectedResult))
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
