/***************************************************************************************************************************
*
*    File Name:  cpu.sv
*      Version:  1.0
*        Model:  Linear Feedback Shift Register
*
* Dependencies:  LFSR.sv
*
*
*  Description:  First we reset the Memcontroller and then we generate the Constrained random data and address with the help of Gaussian LFSR and
*                and then we give the data and address to Memcontroller fro write and when write is done we go to read state and send the same address to 
                 Memcontroller and check the data received is equal to data sent if it is same we go to writr state and the process continues else 
                 it returns a flag.		
* Rev   Author   Date        Changes
* ---------------------------------------------------------------------------------------
* 0.1    Rahul       03/08/18    Design
* 0.2    TJ      	 03/17/18    Code Freeze		 
*****************************************************************************************************************************/

module cpu_model (
	input        i_cpu_ck,        //Input Clock from Emulator
	mem_intf.cpu if_cpu           //Interface between DUT and CPU 
);

	enum bit [3:0] {IDLE,RESET,WAIT_RDY,LOAD_LFSR,WRITE,WRITE_DELAY,WRITE_RDY_WAIT,READ,READ_VLD_WAIT,COMPARE} state; //FSM States for generating data and address
                                                                                                                      //
	logic [31:0] max_count;              //sets the Max_counter Value
	logic [63:0] wr_data,rd_data;        //64 bits read and write data 
	logic        error,en,lfsr_enable;   //Flags to check weather our data received or sent are valid commands to Memcontrollers
//===========================================================================================================================================
//Address 27 bits constrained random generator for a specific bank 
	lfsr #(27) addr_lfsr (.out(if_cpu.i_cpu_addr), .enable(lfsr_enable), .clk(i_cpu_ck), .reset(1'b0));
//===========================================================================================================================================
//Data 64 bits constrained random generator for a specific bank
	lfsr #(64) data_lfsr (.out(if_cpu.i_cpu_wr_data), .enable(lfsr_enable), .clk(i_cpu_ck), .reset(1'b0));
//===========================================================================================================================================
//Counter Instantiation
	counter i_counter (.clock(i_cpu_ck), .reset(0), .en(en), .max_count(max_count), .done(timer_intr), .count());
//===========================================================================================================================================
//Present State Logic 
	always_ff @(posedge i_cpu_ck) begin : proc_fsm
		case (state)
			IDLE : if(timer_intr)                                                   //IDLE waits for Timer to go to Next State
				state <= RESET;

			RESET : state <= WAIT_RDY;                                              //Reset go to Next State

			WAIT_RDY : if(if_cpu.o_cpu_data_rdy)                                    //WAIT_RDY State waits for data ready signal goes to Next State
				state <= LOAD_LFSR;

			LOAD_LFSR : state <= WRITE;                                             //Loads the data for Write and Address in this state

			WRITE : state <= WRITE_DELAY;                                           //Delays the the write operation to Memcontroller 

			WRITE_DELAY : if(!if_cpu.o_cpu_data_rdy)	state <= WRITE_RDY_WAIT;    //Delays the the write operation to Memcontroller for certain time 

			WRITE_RDY_WAIT : if(if_cpu.o_cpu_data_rdy)                              //waits for the data to be written to the DRAM memory
				state <= READ;

			READ : if(!if_cpu.o_cpu_data_rdy)                                       //waits for the data sent in write to to come out from that memory location trhough Memcontroller to CPU
				state <= READ_VLD_WAIT;

			READ_VLD_WAIT : if(if_cpu.o_cpu_rd_data_valid)                          //Checks weather the data sent is equal to data received
				state <= COMPARE;

			COMPARE : if(!error)                                                    // if error is not generated it goes again and repeats the write and read process
				state <= WAIT_RDY;

			default : state <= IDLE;                                                //default state is IDLE
		endcase
	end
//============================================================================================================================================================
//Output logic depends on the present state
	always_comb begin : proc_out               
		en                 = 0;                       // required signals needed to be asserted low except in required states (micron Specifications)
		lfsr_enable        = 0;
		if_cpu.i_cpu_reset = 0;
		if_cpu.i_cpu_cmd   = 0;
		if_cpu.i_cpu_valid = 0;
		error              = 0;
		case (state)
			IDLE : begin                                          //IDLE state
				en        = 1; 
				max_count = 'd5000;                               //set counter value to Zero
			end
 
			RESET : begin                                         //RESET State
				if_cpu.i_cpu_reset = 1;                            //reset active high
			end

			LOAD_LFSR : lfsr_enable = 1;                          //LOAD_LFSR State

			WRITE : begin
				if_cpu.i_cpu_cmd   = 1;                           //Determines if it is read    
				if_cpu.i_cpu_valid = 1;                           //Valid if address and data is valid or not
			end

			READ : begin                                          //READ State
				if_cpu.i_cpu_cmd   = 0;                           //determines if it is write
				if_cpu.i_cpu_valid = 1;                           //Valid if address and data sent to Memcontroller is valid or not
			end

			COMPARE : error = (wr_data[55:0]!=rd_data[55:0]);     //Checks if data sent is equal to data received.

			default : begin
				en                 = 0;                           // Same as Idle Case
				lfsr_enable        = 0;
				if_cpu.i_cpu_reset = 0;
				if_cpu.i_cpu_cmd   = 0;
				if_cpu.i_cpu_valid = 0;
			end
		endcase
	end
//=================================================================================================================================================
	always_ff @(posedge i_cpu_ck) if (state==WRITE) wr_data <= if_cpu.i_cpu_wr_data;               //Send the data at every posedge of clock 
	always_ff @(posedge i_cpu_ck) if (if_cpu.o_cpu_rd_data_valid) rd_data <= if_cpu.o_cpu_rd_data; //waits for data from Memcontroller

endmodule