/***************************************************************************************************************************
*
*    File Name:  interface.sv
*      Version:  1.0
*        Model:  Interface
*
* Dependencies:  DUT.sv
*				 DDR3MemPkg.sv
*
*
*  Description:  contains 2 interfaces. 1. CPU-CONTROLLER    2. CONTROLLER-MEMORY
*				 Contains respective modports in each interface.
*
*
*
* Rev   Author   Date        Changes
* ---------------------------------------------------------------------------------------
* 0.1    TJ       03/08/18    Design
* 0.2    TJ 	   03/17/18    Code Freeze

*****************************************************************************************************************************/

import DDR3MemPkg::* ;//Importing the variables for memory parameters and Address bit parameters
//==================================================================================================================================================
//Interface signals between MemController and DRAM memory
interface mem_if(input logic i_cpu_ck);	   //Clock from emulator mem_if Interface
	logic                 rst_n  ; //Reset Signal
	logic                 ck     ; // complement of CPU Clock
	logic                 ck_n   ; //CPU Clock
	logic                 cke    ; //Clock_enable from MemController to Memory
	logic                 cs_n   ; //Chip Select Signal
	logic                 ras_n  ; //RAS Signal row to column signal
	logic                 cas_n  ; //CAS Signal column to data delay signal
	logic                 we_n   ; //Write or read enable signal
	tri   [        1-1:0] dm_tdqs;
	logic [  BA_BITS-1:0] ba     ; // bank Bits
	logic [ADDR_BITS-1:0] addr   ; //MAX Address Bits for the address bus
	tri   [  DQ_BITS-1:0] dq     ; //data bits from/to memory controller form memory or CPU
	tri   [        1-1:0] dqs    ; //data strobe signal
	tri   [        1-1:0] dqs_n  ; //Checks if data is valid and assigned to complement of Cpu clock
	logic [        1-1:0] tdqs_n ; //terminating Data strobe signal
	logic                 odt    ; //on-die terminating Signal

//======Module port for controller signals===============================================================
	modport contr_sig (
		output ck, ck_n, rst_n, cs_n, cke, ras_n, cas_n, we_n, odt, ba, addr,tdqs_n,
		inout dm_tdqs, dq, dqs, dqs_n
	);


//======Module ports for Memory===========================================================================
	modport mem_sig (
		input ck, ck_n, rst_n, cs_n, cke, ras_n, cas_n, we_n, odt,ba, addr,tdqs_n,
		inout dm_tdqs,dq, dqs, dqs_n
	);


endinterface : mem_if

///////////////////////// Interface for Driver///////////////////////////


//==================================================================================================================================================
//Interface between CPU and Memory Controller
interface mem_intf(input logic i_cpu_ck);

	//logic	     				i_cpu_ck;		// Clock from TB
	logic                     i_cpu_reset        ; // Reset passed to Controller from TB
	logic [   ADDR_MCTRL-1:0] i_cpu_addr         ; // Cpu Addr
	logic                     i_cpu_cmd          ; // Cpu command RD or WR
	logic [    8*DQ_BITS-1:0] i_cpu_wr_data      ; // Cpu Write Data
	logic                     i_cpu_valid        ; // Valid is set when passing CPU addr and command
	logic                     i_cpu_enable       ; // Chip Select
	logic [      BURST_L-1:0] i_cpu_dm           ; // Data Mask - One HOT
	logic [$clog2(BURST_L):0] i_cpu_burst        ; // Define Burst Length - wont be used for now
	logic [    8*DQ_BITS-1:0] o_cpu_rd_data      ; // Cpu data Read
	logic                     o_cpu_data_rdy     ; // Cpu data Ready
	logic                     o_cpu_rd_data_valid; // Signal for valid data sent to CPU

//Memory Contoller Modport
	modport MemController (
		input   i_cpu_ck,                    // Clock from TB
		input 	i_cpu_reset,               //Reset passed to controller from TB
		input 	i_cpu_addr,                //CPU Address to MemController
		input 	i_cpu_cmd,                 //CPU command Read or write
		input 	i_cpu_wr_data,             //CPU write Data
		input 	i_cpu_valid,               //Valid is set when passing CPU Addr and Command
		input 	i_cpu_enable,              //Enable Signal
		input 	i_cpu_dm,                  //Data mask-One Hot
		input 	i_cpu_burst,               //Defining the Burst Lenght
		output  o_cpu_rd_data,             //CPU data Read
		output  o_cpu_data_rdy,	           //CPU data Ready
		output 	o_cpu_rd_data_valid
	);      //Signal for Valid data sent to CPU


//CPU Modport
	modport cpu (
		output 	i_cpu_reset,
		output 	i_cpu_addr,
		output 	i_cpu_cmd,
		output 	i_cpu_wr_data,
		output 	i_cpu_valid,
		output 	i_cpu_enable,
		output 	i_cpu_dm,
		output 	i_cpu_burst,
		input   o_cpu_rd_data,
		input   o_cpu_data_rdy,
		input 	o_cpu_rd_data_valid
	);

endinterface : mem_intf                                                               //end mem_intf





