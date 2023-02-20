// sample top level design
module top_level(
  input        clk, reset, req, 
  output logic done);
  parameter D = 12,             // program counter width
            A = 3;             		  // ALU command bit width
  wire[D-1:0] target, 			  // jump 
              prog_ctr;
  wire        RegWrite;
  wire[7:0]   datA,datB,		  // from RegFile
			        rslt,               // alu output
              immed,
              jump_addr,
              branch_addr;

  wire[2:0] alu_op;

  wire[1:0] operation_type;
              
  wire[7:0]   mux1,
              mux2,
              mux3,
              inputmux4,
              mux4,
              muxALU2In,
              muxALU1,
              muxALU2,
              muxALU3,
              jumpIdx,
              branchIdx,
              mux_j_b,
              muxPC,
              mux_mem_reg;
  wire AND_output,
       OR_output;

  logic sc_in,   				  // shift/carry out from/to ALU
   		  pariQ,            // registered parity flag from ALU
		    zeroQ;            // registered zero flag from ALU 
  wire  jump;             // from control to PC; relative jump enable
  wire  pari,
        zero,
		    sc_clr,
		    sc_en,
        MemWrite,
        ALUSrc;		              // immediate switch
  wire[2:0] alu_cmd;
  wire[8:0]   mach_code;          // machine code
  wire[2:0] rd_addrA, rd_addrB;    // address pointers to reg_file
// fetch subassembly
  PC #(.D(D)) 					  // D sets program counter width
     pc1 (.reset            ,
         .clk              ,
		 .jump_en (jump),
		 .target  (muxPC)         ,
		 .prog_ctr          );

// contains machine code
  instr_ROM ir1(.prog_ctr,
               .mach_code);

  assign opcode  = mach_code[8:6];
  assign rd_addrA = mach_code[5:4];
  assign rd_addrB = mach_code[3:2];

// control decoder
  Control ctl1(.instr(opcode),
  .func(operation_type)
  .RegDst  (), 
  .Branch  (), 
  .Swap      ,  
  .Jump    (jump),
  .MemWrite , 
  .ALUSrc   , 
  .RegWrite ,     
  .MemtoReg(),
  .ALUOp(alu_op));
    
  assign mux1 = Swap ? {rd_addrB, 1} : {rd_addrA, 0};
  assign mux2 = Swap ? {rd_addrA, 0} : {rd_addrB, 1};
  assign mux3 = RegDst ? mux1 : rd_addrB;
  assign inputmux4 = mux1 || 3'b001;
  assign mux4 = Branch ? inputmux4 : mux2;


  reg_file #(.pw(3)) rf1(.dat_in(mux_mem_reg),	   // loads, most ops
              .clk         ,
              .wr_en   (RegWrite),
              .rd_addrA(mux1),      // read register address 1
              .rd_addrB(mux4),      // read register address 2
              .wr_addr (mux3),      // in place operation
              .datA_out(datA),
              .datB_out(datB)); 

  assign muxALU2In = {4'b0000, mach_code[3:0]};
  assign muxALU1 = Swap ? 8'b00000000 : datA;
  assign muxALU2 = ALUSrc ? muxALU2In : datB;
  assign muxALU3 = (!RegDst) ? {6'b000000, mach_code[1:0]} : muxALU2;
  assign operation_type = mach_code[1:0];

  
 alu_control alu_control_1(.ALUOp(alu_op),
         .opType(operation_type)    ,
     .ALUOpFinal(alu_cmd) );  
  
  
  alu alu1(.alu_cmd(alu_cmd),
         .inA    (muxALU1),
		 .inB    (muxALU2),
		 .sc_i   (sc),   // output from sc register
		 .rslt       ,
		 .sc_o (sc_o), // input to sc register
		 .pari       ,  
     .zero );  

  assign jumpIdx = {2'b00, mach_code[5:0]};
  assign branchIdx = {4'b0000, mach_code[3:0]};

  // lookup table to facilitate jumps/branches
  JUMP_LUT #(.D(D))
    pl1 (.index  (jumpIdx),
         .addr   (jump_addr)       );   

  // lookup table to facilitate jumps/branches
  BRANCH_LUT #(.D(D))
    pl1 (.index  (branchIdx),
         .addr   (branch_addr)      );   

  assign AND_output = Branch && zero;
  assign OR_output = AND_output || Jump;
  assign mux_j_b = Branch ? branch_addr : jump_addr;
  assign muxPC = OR_output ? mux_j_b : prog_ctr;

  dat_mem dm1(.dat_in(datB)  ,  // from reg_file
             .clk           ,
			 .wr_en  (MemWrite), // stores
			 .addr   (rslt),
       .dat_out);

  assign mux_mem_reg = MemtoReg ? dat_out : rslt;

// registered flags from ALU
  always_ff @(posedge clk) begin
    pariQ <= pari;
	zeroQ <= zero;
    if(sc_clr)
	  sc_in <= 'b0;
    else if(sc_en)
      sc_in <= sc_o;
  end

  assign done = prog_ctr == 128;
 
endmodule