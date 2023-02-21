module milestone2_quicktest_tb();

bit clk, reset;
wire done;
logic error[2];

top_level dut(
  .clk,
  .reset,
  .done);


always begin
  #5 clk = 1;
  #5 clk = 0;
end

initial begin

  dut.rf1.core[3'b000] = 8'b00000000;
  dut.rf1.core[3'b001] = 8'b00000000;
  dut.rf1.core[3'b010] = 8'b00000000;
  dut.rf1.core[3'b011] = 8'b00000000;
  dut.rf1.core[3'b100] = 8'b00000000;
  dut.rf1.core[5] = 8'b00000000;
  dut.rf1.core[6] = 8'b00000000;
  dut.rf1.core[7] = 8'b00000000;
  dut.rf1.core[8] = 8'b00000000;

  dut.dm1.core[0] = 8'b00000001;
  dut.dm1.core[1] = 8'b00000010;
  dut.dm1.core[3] =	8'b11000011;
  dut.dm1.core[4] = 8'b01010101;
  #10 reset = 1;
  #10 reset = 0;
  #10 wait(done);
  #10 error[0] = (8'b00000011) == dut.dm1.core[0];
  // #10 error[1] = (8'b11000011 & 8'b01010101) != dut.dm1.core[5];
  #10 $display(error[0]);
  $stop;
end    

endmodule