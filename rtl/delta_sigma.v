module delta_sigma( 
   output    reg             DACout,   //Average Output feeding analog lowpass 
   input          [MSB-1:0]    DACin,   //DAC input (excess 2**MSBI) 
   input                  CLK, 
   input                   RESET 
); 

parameter MSB = 16;

reg [MSB+1:0] DeltaAdder;   //Output of Delta Adder 
reg [MSB+1:0] SigmaAdder;   //Output of Sigma Adder 
reg [MSB+1:0] SigmaLatch;   //Latches output of Sigma Adder 
reg [MSB+1:0] DeltaB;      //B input of Delta Adder 

always @ (*) 
   DeltaB = {SigmaLatch[MSB+1], SigmaLatch[MSB+1]} << MSB; 

always @(*) 
   DeltaAdder = DACin + DeltaB; 
    
always @(*) 
   SigmaAdder = DeltaAdder + SigmaLatch; 
    
always @(posedge CLK or posedge RESET) 
   if(RESET) begin 
      SigmaLatch <= 1'b1 << (MSB); 
      DACout <= 1'b0; 
   end else begin 
      SigmaLatch <= SigmaAdder; 
      DACout <= SigmaLatch[MSB+1]; 
   end 
endmodule 