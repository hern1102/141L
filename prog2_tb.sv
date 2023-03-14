// CSE141L  Winter 2023
// test bench for program 2
// flip probabilities:
// 75% one error bit
//    condition: flip2[5:4] != 2'b00;
// 25 * (255/256)%  two error bits
//    condition: flip2[5:4] == 2'b00 && flip2[3:0] != flip;
// 25 * (1/256)% no errors (flip2[5:4] == 2'b00 && flip2[3:0] == flip)
//    
module prog2_tb();

bit   clk   ,                    // clock source -- drives DUT input of same name
      reset  ,                   // clock source -- drives DUT input of same name 
      req   ;	                 // req -- start program -- drives DUT input
wire  done;		    	         // ack -- from DUT -- done w/ program

// program 1-specific variables
bit  [11:1] d1_in[15];           // original messages
logic      p0, p8, p4, p2, p1;  // Hamming block parity bits
logic[15:0] d1_out[15];          // orig messages w/ parity inserted

// program 2-specific variables
logic[11:1] d2_in[15];           // use to generate data
logic[15:0] d2_good[15];         // d2_in w/ parity
logic[ 3:0] flip[15];            // position of first corruption bit
logic[ 5:0] flip2[15];           // position of possible second corruption bit
logic[15:0] d2_bad1[15];         // possibly corrupt message w/ parity
logic[15:0] d2_bad[15];          // possibly corrupt messages w/ parity
logic       s16, s8, s4, s2, s1; // parity generated from data of d_bad
logic[ 3:0] err;                 // bitwise XOR of p* and s* as 4-bit vector        
logic[11:1] d2_corr[15];         // recovered and corrected messages
bit  [15:0] score2, case2;

// your device goes here
// explicitly list ports if your names differ from test bench's
// top_level DUT(.clk, .start, .done);	 // replace "top_level" with the name of your top level module
top_level DUT(.clk, .reset(reset) , .req , .done(done));            // replace "proc" with the name of your top level module

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
    DUT.dm1.core[60] = 8'b00000000;
    DUT.dm1.core[61] = 8'b11111110;
    DUT.dm1.core[62] = 8'b11110000;
    DUT.dm1.core[63] = 8'b11100000;
    DUT.dm1.core[64] = 8'b11001100;
    DUT.dm1.core[65] = 8'b11001000;
    DUT.dm1.core[66] = 8'b10101010;
    DUT.dm1.core[67] = 8'b10101000;
    DUT.dm1.core[68] = 8'b11101000;
    DUT.dm1.core[69] = 8'b00011110;
    DUT.dm1.core[70] = 8'b00001000;
    DUT.dm1.core[71] = 8'b00000000;
    DUT.dm1.core[72] = 8'b00000000;
    DUT.dm1.core[73] = 8'b00011110;
    DUT.dm1.core[74] = 8'b00000000;
    DUT.dm1.core[75] = 8'b00011110;
    DUT.dm1.core[76] = 8'b00000000;
    DUT.dm1.core[77] = 8'b00000000;
    DUT.dm1.core[78] = 8'b00000000;
    DUT.dm1.core[79] = 8'b00000000;
    DUT.dm1.core[80] = 8'b00000000;
    DUT.dm1.core[81] = 8'b00000000;
    DUT.dm1.core[82] = 8'b00000000;
    DUT.dm1.core[83] = 8'b00000001;
    DUT.dm1.core[84] = 8'b00010000;
    DUT.dm1.core[85] = 8'b00000100;
    DUT.dm1.core[86] = 8'b00000010;
    DUT.dm1.core[87] = 8'b00000000;
    DUT.dm1.core[88] = 8'b00000000;
    DUT.dm1.core[89] = 8'b00000000;
    DUT.dm1.core[90] = 8'b00000000;
    DUT.dm1.core[91] = 8'b00000000;
    DUT.dm1.core[92] = 8'b00000000;
    DUT.dm1.core[93] = 8'b00000000;

  //these need to be updated based on 10 bit pointer
  //initialize jump table
    DUT.jump1.core[0] = 10'b0000001001; //9
    DUT.jump1.core[1] = 10'b0101100111; //359
    DUT.jump1.core[2] = 10'b0110010001; //401
    DUT.jump1.core[3] = 10'b0111101111; //495
    DUT.jump1.core[4] = 10'b0111011011; //475
  
  //initialize branch table
    DUT.branch1.core[0] = 10'b0101101011; //577
    DUT.branch1.core[1] = 10'b0111001111; //463
    DUT.branch1.core[2] = 10'b0110110101; //437
    DUT.branch1.core[3] = 10'b0110001011; //395
    DUT.branch1.core[4] = 10'b0101011110; //350
    DUT.branch1.core[5] = 10'b0101101011; //363
    DUT.branch1.core[6] = 10'b0110010101; //405
    DUT.branch1.core[7] = 10'b1000101000; //552

// generate parity from random 11-bit messages 
  for(int i=0; i<15; i++) begin
	d2_in[i] = $random;
    p8 = ^d2_in[i][11:5];
    p4 = (^d2_in[i][11:8])^(^d2_in[i][4:2]); 
    p2 = d2_in[i][11]^d2_in[i][10]^d2_in[i][7]^d2_in[i][6]^d2_in[i][4]^d2_in[i][3]^d2_in[i][1];
    p1 = d2_in[i][11]^d2_in[i][ 9]^d2_in[i][7]^d2_in[i][5]^d2_in[i][4]^d2_in[i][2]^d2_in[i][1];
    p0 = ^d2_in[i]^p8^p4^p2^p1;
    d2_good[i] = {d2_in[i][11:5],p8,d2_in[i][4:2],p4,d2_in[i][1],p2,p1,p0};
// flip one bit
    flip[i] = $random;	  // 'b1000000;
    d2_bad1[i] = d2_good[i] ^ (1'b1<<flip[i]);
// flip second bit about 25% of the time (flip2<16)		// 00_0010     1010
// if flip2[5:4]!=0, flip2 will have no effect, and we'll have a one-bit flip
    flip2[i] = $random;	   // 'b0;
	d2_bad[i] = d2_bad1[i] ^ (1'b1<<flip2[i]);
// if flip2[5:4]==0 && flip2[3:0]==flip, then flip2 undoes flip, so no error
	DUT.dm1.core[31+2*i] = {d2_bad[i][15:8]};
    DUT.dm1.core[30+2*i] = {d2_bad[i][ 7:0]};
  end
  #10ns reset   = 1'b1;
  #10ns reset   = 1'b0;
  wait(done);
  $display();
  $display("start program 2");
  $display();
  for(int i=0; i<15; i++) begin
    $displayb({5'b0,d2_in[i]});
    $writeb  (DUT.dm1.core[1+2*i]);
    $displayb(DUT.dm1.core[0+2*i]);
    if(flip2[i][5:4]) begin :sgl_err                           // single error scenario
      $display("single error injected, expecting MSBs of output = 2'b01");
      if({5'b01000,d2_in[i]}=={DUT.dm1.core[1+2*i],DUT.dm1.core[0+2*i]}) begin
	    $display("we have a match");
		score2++;
	  end
	  else
	    $display("erroneous output");
	  $display("expected %b, got %b",{5'b01000,d1_in[i]},{DUT.dm1.core[1+2*i],DUT.dm1.core[0+2*i]});
	end	 :sgl_err

    else if(flip2[i][3:0]==flip[i]) begin :no_err       // zero error scenario: flip2 undoes flip
      $display("no errors injected, expecting MSBs of output = 2'b00");
      if({5'b00000,d2_in[i]}=={DUT.dm1.core[1+2*i],DUT.dm1.core[0+2*i]}) begin
	    $display("we have a match");
		score2++;
	  end
	  else
	    $display("erroneous output");
	  $display("expected %b, got %b",{5'b00000,d1_in[i]},{DUT.dm1.core[1+2*i],DUT.dm1.core[0+2*i]});
    end	:no_err

	else begin :dbl_err									// two-error scenario; time to give up and raise the white flag
	  $display("two errors injected, expecting MSB of output = 1'b1");
      if(DUT.dm1.core[1+2*i][7]==1'b1) begin		   // test for MSB = 1 (two error flag)
	    $display("we have a match");
		score2++;
	  end
	  else
	    $display("erroneous output");
	  $display("expected 1???????????????, got %b",{DUT.dm1.core[1+2*i],DUT.dm1.core[0+2*i]});
    end :dbl_err
    case2++;
	$display("flip positions = %b %b",flip2[i],flip[i]);
	$display();
  end

  $display("program 2 score = %d out of %d",score2,case2);
  #10ns $stop;
end

always begin
  #5ns clk = 1;            // tic
  #5ns clk = 0;			   // toc
end										

endmodule
