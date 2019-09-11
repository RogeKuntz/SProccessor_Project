
module TestBench_InstMem(output reg error);
	
	reg [31:0] RegAddress;
	wire [31:0] result;
	reg [31:0] expectedResult;
	
	reg [63:0] testVectors[31:0];
	reg [4:0] vectorNum;
	reg clk;
	
	//CLA_32(input [31:0] A, input [31:0] B, input Cin, output [31:0] F, output Coutput);
	//CLA_32 DUT(operandA, operandB, carryIn, result, carryOut);
	//Program_Counter DUT(clk1, In, result);
	Instruction_Memory DUT(RegAddress, result);
	
	initial	// read in data
	begin
		$readmemb("testvector_InstMem.txt", testVectors);
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
		{expectedResult, RegAddress} = testVectors[vectorNum];
	end
	
	always@(negedge clk)	// compare module output to expected output
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
