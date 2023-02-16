// control decoder
module Control #(parameter opwidth = 3, mcodebits = 3)(
  input [mcodebits-1:0] instr,    // subset of machine code (any width you need)
  output logic RegDst, Swap, Branch, 
     MemtoReg, MemWrite, ALUSrc, RegWrite,
  output logic[opwidth-1:0] ALUOp);	   // for up to 8 ALU operations

always_comb begin
// defaults
  RegDst 	=   'b0;   // 1: not in place  just leave 0
  Branch 	=   'b0;   // 1: branch ()
  Swap =  'b0;   // 1: swap if swapping 
  Jump =  'b0;   // 1: jump if jumping 
  MemtoReg  =	'b0;   // 1: load -- route memory instead of ALU to reg_file data in
  MemWrite  =	'b0;   // 1: store to memory
  ALUSrc 	=	'b0;   // 1: immediate  0: second reg file output
  ALUOp	    =   'b111; // y = a+0;
  RegWrite  =	'b1;   // 0: for store or no op  1: most other operations 
// sample values only -- use what you need
case(instr)    // override defaults with exceptions
  'b0000:  begin					// store operation
               MemWrite = 'b1;      // write to data mem
               RegWrite = 'b0;      // typically don't also load reg_file
			 end
  'b00001:  ALUOp      = 'b000;  // add:  y = a+b
  'b00010:  begin				  // load
			   MemtoReg = 'b1;    // 
             end
// ...
endcase

end
	
endmodule