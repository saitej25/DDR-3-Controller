//-----------------------------------------------------
// Design Name : lfsr
// File Name   : lfsr.v
// Function    : Linear feedback shift register
// Coder       : Deepak Kumar Tala
//-----------------------------------------------------
module lfsr  #(parameter WIDTH = 64)  (
out             ,  // Output of the counter
enable          ,  // Enable  for counter
clk             ,  // clock input
reset              // reset input
);

parameter max = (2^^WIDTH);

//----------Output Ports--------------
output [WIDTH-1:0] out;
//------------Input Ports--------------
input enable, clk, reset;
//------------Internal Variables--------
bit [WIDTH-1:0] out;
bit [WIDTH-1:0] temp;
wire        linear_feedback;
bit  		toggle;
bit [2:0] counter;

//-------------Code Starts Here-------
 assign linear_feedback = !(out[19] ^ out[6] ^ out[2] ^out[1]);

// assign linear_feedback = !(out[7] ^ out[3] ^ out[1] ^out[4]);

always @(posedge clk)
if (reset) begin // active high reset
  out <= 'b0 ;
end else if (enable) begin
  out <= {out[WIDTH-1:0], linear_feedback} ;
end


always_ff @(posedge clk) begin : proc_count
	if(reset) begin
		counter <= 0;
	end else begin
		counter <= counter + 1;
	end
end


//always_ff@(posedge clk)
//if(enable) out <= (counter==0) ? max-temp : (counter==(~temp[2:0])) ? {13'b0,temp[13:0]} : temp;

//if(enable) out <= out + 1;

endmodule // End Of Module counter
