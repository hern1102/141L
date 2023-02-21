// sample top level design
module top_level(
  input        clk, reset, req, 
  output logic done);
  parameter D = 12,             // program counter width
            A = 3;             	// ALU command bit width
  
  
  wire[8:0]   mach_code;          // machine code

  /* Control Wires */
  wire regDst,
        branch,
        swap,
        jump,
        ls,
        isig,
        MemtoReg,
        MemWrite,
        ALUSrc,
        regWrite;
  wire[2:0] alu_op;

  /* 8 bit wires */
  wire[7:0] target, 	
            prog_ctr,
            immed,
            jump_addr,
            branch_addr,
            dat_out,
            rslt;

    wire [7:0] datA, datB;


    wire[7:0] muxALU2In,
              muxALU1,
              muxALU2,
              muxALU3,
			        muxALU4,
              jumpIdx,
              branchIdx,
              mux_j_b,
              muxPC,
              mux_mem_reg;
  /* 3 bit wires */

    wire[2:0] mux1,
              mux2,
              mux3,
              inputmux4,
              mux4;

    wire[2:0]   opcode;
    wire[2:0]   alu_cmd;

  /* 2 bit wires */
    wire[1:0] operation_type;

    wire[1:0] rd_addrA, rd_addrB;    // address pointers to reg_file

  /* 1 bit wires */

   wire AND_output,
       OR_output;

   wire  pari,
        zero,
		    sc_clr,
		    sc_en;		
 
    logic sc_in,   				  // shift/carry out from/to ALU
        sc_o,
   		  pariQ,            // registered parity flag from ALU
		    zeroQ;  
  

// fetch subassembly
  PC pc1 (.reset            ,
         .clk              ,
                 .branch_en (branch),
		 .jump_en (jump),
		 .target  (muxPC)    ,
		 .prog_ctr          );

// contains machine code
  instr_ROM ir1(.prog_ctr,
               .mach_code);

  assign opcode  = mach_code[8:6];
  assign rd_addrA = mach_code[5:4];
  assign rd_addrB = mach_code[3:2];

// control decoder
  Control ctl1(.instr(opcode),
  .func   (operation_type),
  .RegDst (regDst), 
  .LS(ls),
  .iSig(isig),
  .Branch (branch), 
  .Swap  (swap),  
  .Jump  (jump),
  .MemWrite (MemWrite), 
  .ALUSrc (ALUSrc)  , 
  .RegWrite (regWrite),     
  .MemtoReg(MemtoReg),
  .ALUOp(alu_op));
    
  assign mux1 = swap ? {rd_addrB, 1'b1} : {rd_addrA, 1'b0};
  assign mux2 = swap ? {rd_addrA, 1'b0} : {rd_addrB, 1'b1};
  assign mux3 = regDst ? mux1 : {rd_addrB, 1'b1};
  assign inputmux4 = mux1 || 3'b001;
  assign mux4 = branch ? inputmux4 : mux2;

  reg_file #(.pw(3)) rf1(
			  .dat_in(mux_mem_reg),	   // loads, most ops
              .clk         ,
              .wr_en   (regWrite),
              .rd_addrA(mux1),      // read register address 1
              .rd_addrB(mux4),      // read register address 2
              .wr_addr (mux3),      // in place operation
              .datA_out(datA) ,
              .datB_out(datB) ); 
			  
  assign operation_type = mach_code[1:0];

  assign muxALU2In = {4'b0000, mach_code[3:0]};
  assign muxALU1 = swap ? 8'b00000000 : datA;
  assign muxALU2 = ALUSrc ? muxALU2In : datB;
  assign muxALU3 = ls ? {6'b000000, operation_type} : muxALU2;
  assign muxALU4 = isig ? {6'b000000, mach_code[3:2]} : muxALU3;
  

  
 alu_control aluC1(.ALUOp(alu_op),
         .opType(operation_type)    ,
     .ALUOpFinal(alu_cmd) );  
  
  
  alu alu1(.alu_cmd(alu_cmd),
         .inA    (muxALU1),
		 .inB    (muxALU4),
		 .sc_i   (sc_in),   // output from sc register
		 .rslt (rslt)  ,
		 .sc_o (sc_o), // input to sc register
		 .pari       ,  
     .zero );  

  assign jumpIdx = {2'b00, mach_code[5:0]};
  assign branchIdx = {4'b0000, mach_code[3:0]};

  // lookup table to facilitate jumps/branches
  JUMP_LUT jump1 (.index  (jumpIdx),
         .jump_addr   (jump_addr)       );   

  // lookup table to facilitate jumps/branches
  BRANCH_LUT branch1 (.index  (branchIdx),
         .branch_addr   (branch_addr)      );   

  assign AND_output = branch && zero;
  assign OR_output = AND_output || jump;
  assign mux_j_b = branch ? branch_addr : jump_addr;
  assign muxPC = OR_output ? mux_j_b : prog_ctr;

  dat_mem dm1(.dat_in(datB)  ,  // from reg_file
             .clk           ,
			 .wr_en  (MemWrite), // stores
			 .addr   (rslt),
       .dat_out(dat_out));

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