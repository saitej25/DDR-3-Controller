/***************************************************************************************************************************
*
*    File Name:  LFSR.sv
*      Version:  1.0
*        Model:  Linear Feedback Shift Register
*
* Dependencies:  LFSR.sv
*
*
*  Description:  Generates the Synthesize-able constrained random generator for generating 64 bits write data and 27 bits Address
*                generator for constrained Random.Summary 
*    			LFSR -Linear feedback Shift Register is a random generator with the characteristics of 
*				x5 + x3 + x + 1 for a 6 bit random generator similarly for 64 bit we will have x64 degree
*				polynomial depending on the characteristics polynomial the random generator will be determined 
*				One of the Model is Gaussian LFSR
** Rev   Author   Date        Changes
* ---------------------------------------------------------------------------------------
* 0.1    TJs       03/08/18    Design
* 0.2    TJs 	   03/17/18    Code Freeze
*****************************************************************************************************************************/
//Summary 
//LFSR -Linear feedback Shift Register is a random generator with the characteristics of 
//x5 + x3 + x + 1 for a 6 bit random generator similarly for 64 bit we will have x64 degree
//polynomial depending on the characteristics polynomial the random generator will be determined 
//One of the Model is Gaussian LFSR

module lfsr  #(parameter WIDTH = 64)  (
out             ,                        // Output of the counter
enable          ,                        // Enable  for counter
clk             ,                        // clock input
reset                                    // reset input
);
//=============================================================================================
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
 assign linear_feedback = !(out[19] ^ out[6] ^ out[2] ^out[1]);   //getting feedback from bits 19,6,2,1.

always @(posedge clk)                                  //always at the posedge of CLK
if (reset) begin                                       // active high reset
  temp <= 'b0 ;                                        //random generator will be 0
end else if (enable) begin                             //if enable signal is high
  temp <= {temp[WIDTH-1:0], linear_feedback} ;         //assigning the random address to temp variable
end


always_ff @(posedge clk or negedge reset) begin : proc_count    //
	if(reset) begin                                             //If reset High counter will be set to Zero
		counter <= 0;
	end else begin                                               //We keep on incrementing the counter
		counter <= counter + 1;
	end
end


always_latch
if(enable) out = (counter==0) ? max-temp : (counter==(~temp[2:0])) ? {'b0,temp[13:0]} : temp; // we are latching the generated random signal to a specific bank
                                                                                              //and assigning the random generated to out variable
endmodule // End Of Module counter