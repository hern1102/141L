module JUMP_LUT (
  input       [ 7:0] index,	   // target 4 values
  output logic[7:0] jump_addr);

  always_comb case(jump_addr)
	0: jump_addr = 00001111;   // go back 5 spaces
	1: jump_addr = 00001110;   // go ahead 20 spaces
	2: jump_addr = 00001100;  // go back 1 space   1111_1111_1111
	default: jump_addr = 'b0;  // hold PC  
  endcase

endmodule