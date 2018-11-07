/***************************************************************************************************************************
*
*    File Name:  Counter.sv
*      Version:  1.0
*        Model:  Internal Delay counter
*
* Dependencies:  DUT.sv
*				 
*
*  Description:  Acts as a down counter to generate the delay for obeying the timing specifications.
*
*
* Rev   Author   Date        Changes
* ---------------------------------------------------------------------------------------
* 0.1    Suraj       03/10/18    Design
* 0.2    Suraj 	     03/17/18    Code Freeze

*****************************************************************************************************************************/

module counter (                           //counter Module
	input  logic       clock    ,          //Clock fro the counter from Emulator
	input  logic       reset    ,          //Reset
	input  logic       en,                 //Counter Enable 
	input  logic [31:0] max_count,         //Set the counter to a Maximum Value
	output bit         done     ,          //if done , counter has reached it's max_count value
	output bit [31:0] count              //counter is active when enable signal is on and counts till it reaches max_count
);
//==================================================================================================================================================
//Counter for DDR3 memory Model depending on the max_count value set the counter gets incremented and when count==max_count-1 then the done signal is
//asserted
	always@(posedge clock) begin           //Activates at posedge of Clock
		if((reset) | (count==max_count-1)) //if reset or reaches max count value resets the counter value to 0
			count <= 0;                    //assigning the counter value to zero if above condition is true
		else if(en)                        // if enable is high the counter starts counting it's value at every positive clock edge 
			count <= count+1;              //count gets incremented when enable signal is high and reaches to max count-1
	end

	assign done = (count==max_count-1);    //assigning the done =1 when counter reaches it's maximum value.

endmodule                                  //end of counter module
