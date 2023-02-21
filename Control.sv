// control decoder
module Control #(parameter opwidth = 3, mcodebits = 3)(
  input [mcodebits-1:0] instr,    // subset of machine code (any width you need)
  input [1:0] func, //to help get swap
  output logic RegDst, LS, iSig, Swap, Branch, 
     MemtoReg, MemWrite, ALUSrc, RegWrite, Jump,
  output logic[opwidth-1:0] ALUOp);	   // for up to 8 ALU operations

always_comb begin
// defaults
  RegDst 	  = 'b0;   // 1: not in place  just leave 0
  LS = 'b0;
  iSig = 'b0;
  Branch 	  = 'b0;   // 1: branch ()
  Swap      = 'b0;   // 1: swap if swapping 
  Jump      = 'b0;   // 1: jump if jumping 
  MemtoReg  =	'b0;   // 1: load -- route memory instead of ALU to reg_file data in
  MemWrite  =	'b0;   // 1: store to memory
  ALUSrc 	  =	'b0;   // 1: immediate  0: second reg file output
  ALUOp = 3'b111;
  RegWrite  =	'b1;   // 0: for store or no op  1: most other operations 
// sample values only -- use what you need
case(instr)    // override defaults with exceptions
  3'b000:  begin					// R type operations (add, xor, xor_reduce, and)
      RegDst = 1'b1;
      ALUOp = 3'b000;
	end
  3'b001:  begin					// BEQ 
    Branch = 'b1;
    ALUSrc = 'b1;
    RegWrite = 'b0;
    ALUOp = 3'b001;
	end
  3'b010:  begin					// SRL
    RegDst = 'b1;
    ALUOp = 3'b010;
	end
  3'b011:  begin					// SLL
    RegDst = 'b1;
    ALUOp = 3'b011;
	end
  3'b100:  begin					// LOAD
    MemtoReg  =	'b1; 
	LS = 'b1;
    ALUSrc = 'b1;
    ALUOp = 3'b100;
	end
  3'b101:  begin					// STORE
    MemWrite = 'b1; 
    ALUSrc = 'b1;
    ALUOp = 3'b101;
    RegWrite = 'b0;
	end
  3'b110:  begin					// JUMP
    Jump = 'b1;
    ALUOp = 3'b110;
    RegWrite = 'b0;
	end
  3'b111:  begin					// I-Type
    if(func == 2'b10) begin 
            Swap = 'b1;
			RegDst = 'b1;
			ALUOp = 3'b111;
    end 
	else begin
		RegDst = 'b1;
		ALUOp = 3'b111;
		iSig = 'b1;
	end
    
	end
      
endcase

end
	
endmodule