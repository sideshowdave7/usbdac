`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:04:31 05/21/2017
// Design Name:   siggit
// Module Name:   C:/Users/david/Desktop/FPGA Projects/USBDAC/siggit_test.v
// Project Name:  USBDAC
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: siggit
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module siggit_test;

	// Inputs
	reg [15:0] INVAL;
	reg CLK;
	reg RESET;

	// Outputs
	wire BITSTREAM;

	// Instantiate the Unit Under Test (UUT)
	siggit uut (
		.INVAL(INVAL), 
		.CLK(CLK), 
		.RESET(RESET), 
		.BITSTREAM(BITSTREAM)
	);

	initial begin
		// Initialize Inputs
		INVAL = 0;
		CLK = 0;
		RESET = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

