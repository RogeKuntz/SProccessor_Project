/******************************************************
* Name of Program: TestBench_Processor_Final
* Author:          Roge' Kuntz
* Date Created:    12 / 13 / 2018
* Date Modified:   12 / 13 / 2018
* Function:        Test processor
*******************************************************/

///////USE THIS TESTBENCH FOR FINAL TESTING////////////////////////////////////////////////////
/////// Uses tier3test.txt, with n = 5

module TestBench_Processor_Final(output reg error);
	
	
	wire [31:0] PC_Value;
	wire [31:0] Instruction;
	wire Jump;
	wire PC_Scr;
	wire [31:0] Result;
	
	reg [31:0] Expected_PC_Value;
	reg [31:0] Expected_Instruction;
	reg Expected_Jump;
	reg Expected_PC_Scr;
	reg [31:0] Expected_Result;
	
	reg [97:0] testVectors[63:0];
	reg [5:0] vectorNum;
	reg clk;
	

	CS3421_RRK_Processor DUT(clk, PC_Value, Instruction, 
									Jump, PC_Scr, Result);
	
	
	initial	// read in data
	begin
		$readmemb("testvector_Processor_Final.txt", testVectors);
		
		vectorNum = 5'd0;
		error = 1'b0;
	end
	
	always	// clock
	begin
		clk = 1'b1;
		#30;
		clk = 1'b0;
		#30;
	end
	
	
	always @ (posedge clk)	// put inputs into module
	begin
		#1;
		{Expected_PC_Value, Expected_Instruction, Expected_Jump, Expected_PC_Scr, Expected_Result} = testVectors[vectorNum];
	end
	
	always@(negedge clk)	// compare module output to expected output
	begin
		error = 1'b0;
		if ((PC_Value !== Expected_PC_Value) | (Result !== Expected_Result))
		begin
			error = 1'b1;	//error
		end
		
		vectorNum = vectorNum + 5'd1;
		if (vectorNum == 6'd19)
		begin
			#20;
			$finish;
		end
	end
	
endmodule
