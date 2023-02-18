module JUMP_LUT #(parameter D=8)(
  input       [ 7:0] index,	   // target 4 values
  output logic[D-1:0] addr);

  always_comb case(addr)
    0: target = -5;   // go back 5 spaces
	1: target = 20;   // go ahead 20 spaces
	2: target = '1;   // go back 1 space   1111_1111_1111
	default: target = 'b0;  // hold PC  
  endcase

endmodule