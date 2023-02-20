// cache memory/register file
// default address pointer width = 4, for 16 registers
module reg_file #(parameter pw=3)(
  input[7:0] dat_in,
  input      clk,
  input      wr_en,           // write enable
  input[pw:0] wr_addr,		  // write address pointer
  input[pw-1:0] rd_addrA,		  // read address pointers
		rd_addrB,
  output logic[7:0] datA_out, // read data
                    datB_out);
  //logic[7:0] core[] = 8'b00000000;
  logic[7:0] core[2**pw];    // 2-dim array  8 wide  8 deep
  assign core[0] =  8'b00000000;
  assign core[1] =  8'b00000001;
  assign core[2] =  8'b00000010;
  assign core[3] =  8'b00000011;
  assign core[4] =  8'b00000100;
  assign core[5] =  8'b00000101;
  
  integer a;
  integer b;
// reads are combinational
  always @( rd_addrA) 
        a = rd_addrA;
  assign datA_out = core[a];
  always @ (rd_addrB)
  	b = rd_addrB;	
  assign datB_out = core[b];
   

// writes are sequential (clocked)
  always_ff @(posedge clk)
    if(wr_en)				   // anything but stores or no ops
      core[wr_addr] <= dat_in; 

endmodule
/*
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
*/