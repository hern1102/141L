// test bench for program 3
module prog3_tb();

bit   clk   , 
	reset,                // clock source -- drives DUT input of same name
	  req   ;	             // req -- start next program -- drives DUT input
wire  done;		    	         // ack -- from DUT -- done w/ program

// program 3-specific variables
logic[  7:0] cto,		       // how many bytes hold the pattern? (32 max)
             cts,		       // how many patterns in the whole string? (253 max)
		     ctb;		       // how many patterns fit inside any byte? (160 max)
logic        ctp;		       // flags occurrence of patern in a given byte
logic[  7:0] pat;              // pattern to search for
logic[255:0] str2; 	           // message string
logic[  7:0] mat_str[32];      // message string parsed into bytes

// your device goes here
// explicitly list ports if your names differ from test bench's
 top_level DUT(.clk, .reset(reset) , .req , .done(done));              // replace "proc" with the name of your top level module

initial begin

  //initial state of registers
    DUT.rf1.core[0] = 8'b00000000;
    DUT.rf1.core[1] = 8'b00000000;
    DUT.rf1.core[2] = 8'b00000000;
    DUT.rf1.core[3] = 8'b00000000;
    DUT.rf1.core[4] = 8'b00000000;
    DUT.rf1.core[5] = 8'b00000000;
    DUT.rf1.core[6] = 8'b00000000;
    DUT.rf1.core[7] = 8'b00000000;

  //initial state of memory 
    DUT.dm1.core[33] = 8'b00000000;  // instance COUNT 
    DUT.dm1.core[34] = 8'b00000000;
    DUT.dm1.core[35] = 8'b00000000;
    DUT.dm1.core[60] = 8'b00000000;   
    DUT.dm1.core[61] = 8'b11111000;   
    DUT.dm1.core[62] = 8'b00100000;  // outsideCounter
    DUT.dm1.core[63] = 8'b00000000;  // insideCounter
    DUT.dm1.core[64] = 8'b00100001;  // 33
    DUT.dm1.core[65] = 8'b00000000;  // patternReg
    DUT.dm1.core[66] = 8'b00000000;  // compareReg
    DUT.dm1.core[67] = 8'b00000000;  // message mem counter
    DUT.dm1.core[68] = 8'b00000000;  // equalCounter
    DUT.dm1.core[69] = 8'b10000000;
    DUT.dm1.core[70] = 8'b11000000;
    DUT.dm1.core[71] = 8'b11100000;
    DUT.dm1.core[72] = 8'b11110000;
    DUT.dm1.core[73] = 8'b00000000;   
    DUT.dm1.core[74] = 8'b00000001;

  //initialize jump table
    DUT.jump1.core[0] = 10'b0000101101; //45
    DUT.jump1.core[1] = 10'b0001010010; //82
    DUT.jump1.core[2] = 10'b0010100101; //165
    DUT.jump1.core[3] = 10'b0011000001; //193
    DUT.jump1.core[4] = 10'b0011011101; //221
    DUT.jump1.core[5] = 10'b0001111010; //122
    DUT.jump1.core[6] = 10'b0011111001; //249

  //initialize brunch table
    DUT.branch1.core[0] = 10'b0101000010; //322
    DUT.branch1.core[1] = 10'b0000001100; //12
    DUT.branch1.core[2] = 10'b0001001100; //76
    DUT.branch1.core[3] = 10'b0001101001; //105
    DUT.branch1.core[4] = 10'b0001111010; //122
    DUT.branch1.core[5] = 10'b0100001010; //266
    DUT.branch1.core[6] = 10'b0100011000; //280
    DUT.branch1.core[7] = 10'b0100100110; //294
    DUT.branch1.core[8] = 10'b0100110100; //308

// program 3
// pattern we are looking for; experiment w/ various values
  //pat = {5'b00000,3'b000};//{5'b10101,3'b000};//{$random,3'b000};
  pat = {5'b11111,3'b000};
  //pat = {5'b10101,3'b000};
  str2 = 0;
  DUT.dm1.core[32] = pat;
  for(int i=0; i<32; i++) begin
// search field; experiment w/ various vales
    //mat_str[i] = 8'b00000000;//8'b01010101;// $random;
    mat_str[i] = 8'b11111111;
    //mat_str[i] = 8'b01010101;
	DUT.dm1.core[i] = mat_str[i];   
	str2 = (str2<<8)+mat_str[i];
  end
  ctb = 0;
  for(int j=0; j<32; j++) begin
    if(pat[7:3]==mat_str[j][4:0]) ctb++;
    if(pat[7:3]==mat_str[j][5:1]) ctb++;
    if(pat[7:3]==mat_str[j][6:2]) ctb++;
    if(pat[7:3]==mat_str[j][7:3]) ctb++;
  end
  cto = 0;
  for(int j=0; j<32; j++) 
    if((pat[7:3]==mat_str[j][4:0]) | (pat[7:3]==mat_str[j][5:1]) |
       (pat[7:3]==mat_str[j][6:2]) | (pat[7:3]==mat_str[j][7:3])) cto ++;
  cts = 0;
  for(int j=0; j<252; j++) begin
    if(pat[7:3]==str2[255:251]) cts++;
	str2 = str2<<1;
  end        	    
  #10ns reset   = 1'b1;      // pulse request to DUT
  #10ns reset   = 1'b0;
  wait(done);               // wait for ack from DUT
  $display();
  $display("start program 3");
  $display();
  $display("number of patterns w/o byte crossing    = %d %d",ctb,DUT.dm1.core[33]);   //160 max
  $display("number of bytes w/ at least one pattern = %d %d",cto,DUT.dm1.core[34]);   // 32 max
  $display("number of patterns w/ byte crossing     = %d %d",cts,DUT.dm1.core[35]);   //253 max
  #10ns $stop;
end

always begin
  #5ns clk = 1;            // tic
  #5ns clk = 0;			   // toc
end										

endmodule
