module siggit( 
   input   signed [15:0]  INVAL,   //16-bit signed number, -1 to 1 
   input               CLK, 
   input               RESET, 
   output   reg            BITSTREAM 
); 

   reg [24:0] inval_x;       //25-bit signed number, S8.16 
   reg [24:0] SigmaAdder1; 
   reg [25:0] SigmaAdder1_x; 
   reg [24:0] SigmaAdder2; 
   reg [25:0] SigmaAdder2_x; 
   reg [24:0] SigmaLatch1; 
   reg [24:0] SigmaLatch2; 
   reg [24:0] Limit_FB;      //Feedback signal with protection 
   reg [24:0] Limit_FB_neg;   //Negative protected feedback 
   reg [24:0] Limit_FB_2x;      //Negative protected feedback x2 
   reg [25:0] FB;            //Feedback, SigmaLatch2 - Quant 
   reg [24:0] Quant;         //Quantizer Output: -1 or +1 
   reg [24:0] Quant_neg; 
    
   always @(*) Quant_neg <= (~Quant) + 1; 
   //Quantizer output * -1 
   always @(*) Quant <= SigmaLatch2[24] ? {{10{1'b1}}, 15'b0} : {1'b1, 15'b0}; 
   //The Quantizer outputs either +1 or -1 
   always @(*) FB <= {Quant_neg[24], Quant_neg} + {SigmaLatch2[24], SigmaLatch2}; 
   //Feedback is second sigma latch minus Quantizer output 
   always @(*) Limit_FB <= {FB[25]&FB[24], FB[23:0]}; 
   //No actual limiting at the moment, just reducing the bit width by one 
   always @(*) Limit_FB_2x <= {Limit_FB[24], Limit_FB[22:0], 1'b0}; 
   //Signed multiply by 2 
   always @(*) inval_x <= {{9{INVAL[15]}}, INVAL}; 
   //Sign extend input value 9 bits to go from 16 to 25 
   always @(*) Limit_FB_neg <= (~Limit_FB) + 1; 
   //Limited feedback value * -1 
   always @(*) SigmaAdder1_x <= {inval_x[24], inval_x} + {Limit_FB_neg[24], Limit_FB_neg}; 
   //Signed addition 
   always @(*) SigmaAdder1 <= {SigmaAdder1_x[25]&SigmaAdder1_x[24], SigmaAdder1_x[23:0]}; 
   //Shrink result one bit 
   always @(*) SigmaAdder2_x <= {SigmaLatch1[24], SigmaLatch1} + {Limit_FB_2x[24], Limit_FB_2x}; 
   //Signed addition 
   always @(*) SigmaAdder2 <= {SigmaAdder2_x[25]&SigmaAdder2_x[24], SigmaAdder2_x[23:0]}; 
   //Shrink result one bit 
    
   always @(posedge CLK or posedge RESET) 
      if(RESET) begin 
         SigmaLatch1 <= {14{1'b1}};   //Initial values... anything special? 
         SigmaLatch2 <= {14{1'b1}};   //Testing...    
         BITSTREAM <= 1'b0; 
      end else begin 
         //Each sigma sum is cut back to 24-bit when latched 
         SigmaLatch1 <= SigmaAdder1; 
         SigmaLatch2 <= SigmaAdder2; 
         BITSTREAM <= !Quant[24]; 
      end 
endmodule