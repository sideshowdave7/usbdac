module usbdac_top(
    input bck,
	 input data,
	 input ws,
	 output right,
	 output left,
	 input sck,
	 input rst_n
	 );

wire rst = ~rst_n; // make reset active high

wire [15:0] data_right;
wire [15:0] data_left;

delta_sigma siggit_right(
.CLK(sck),
.RESET(~rst_n),
.DACin({~data_right[15], data_right[14:0]}),
.DACout(right)
);

delta_sigma siggit_left(
.CLK(sck),
.RESET(~rst_n),
.DACin({~data_left[15], data_left[14:0]}),
.DACout(left)
);

//delta_sigma_2 siggit_right(
//.CLK(sck),
//.RESET(rst),
//.INVAL({data_right[15], data_right[14:0]}),
//.BITSTREAM(right)
//);
//
//delta_sigma_2 siggit_left(
//.CLK(sck),
//.RESET(rst),
//.INVAL({data_left[15], data_left[14:0]}),
//.BITSTREAM(left)
//);

i2s_rx rx(
   .sck(bck),
	.ws(ws),
	.sd(data),
	.data_right(data_right),
	.data_left(data_left)
);

endmodule