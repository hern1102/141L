// lookup table
// deep 
// 9 bits wide; as deep as you wish
module instr_ROM (
  input       [9:0] prog_ctr,    // prog_ctr	  address pointer
  output logic[ 8:0] mach_code);

  logic[9:0] core[2**10];
  initial							    // load the program
    $readmemb("mach_code.txt",core);

  always_comb  mach_code = core[prog_ctr];

endmodule

