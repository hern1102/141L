// control decoder
module alu_control (
  input [2:0] ALUOp,
  input [1:0] opType,    // subset of machine code (any width you need)
  output logic[2:0] ALUOpFinal);	   // for up to 8 ALU operations

always_comb begin
// defaults

ALUOpFinal = 3'b111;
  
// sample values only -- use what you need
case(ALUOp)    
  3'b000:  begin					
        case(opType)
          2'b00: begin //add
              ALUOpFinal = 3'b000;
            end 
          2'b01: begin //XOR
            ALUOpFinal = 3'b100;
            end 
          2'b10: begin //XOR reduce
            ALUOpFinal = 3'b101;
            end 
          2'b11: begin //AND
            ALUOpFinal = 3'b110;
            end 
        endcase
			 end
  3'b001:  begin  //BEQ
    ALUOpFinal = 3'b001;
  end
  3'b010:  begin  //SRL
    ALUOpFinal = 3'b010;
  end
  3'b011:  begin  //SLL
    ALUOpFinal = 3'b011;
  end
  3'b100:  begin  //LOAD
    ALUOpFinal = 3'b000;
  end
  3'b101:  begin  //STORE
    ALUOpFinal = 3'b000;
  end
  3'b110:  begin  //JUMP (DO NOTHING)
  
  end
  3'b111:  begin  //SWAP - ADDI - SUBI (I-Type)
    case(opType)
          2'b00: begin //ADDI
            ALUOpFinal = 3'b000;
            end 
          2'b01: begin //SUBI
            ALUOpFinal = 3'b001;
            end 
          2'b10: begin //SWAP
            ALUOpFinal = 3'b000;
            end 
          2'b11: begin //NOTHING
            end 
    endcase
  end
endcase
end
endmodule