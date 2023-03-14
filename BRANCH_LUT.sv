module BRANCH_LUT (
  input       [ 7:0] index,	   // target 4 values
  output logic[9:0] branch_addr);
  
  logic[9:0] core[2**8];
  assign branch_addr = core[index];

endmodule
