import DDR3MemPkg::* ;
interface mem_if(input logic i_cpu_ck);	
	logic   rst_n;
    logic   ck;
    logic   ck_n;
    logic   cke;
    logic   cs_n;
    logic   ras_n;
    logic   cas_n;
    logic   we_n;
    tri   [1-1:0]   dm_tdqs;
    logic   [BA_BITS-1:0]   ba;
    logic   [ADDR_BITS-1:0] addr;
    tri   [DQ_BITS-1:0]   dq;
    tri   [1-1:0]  dqs;
    tri   [1-1:0]  dqs_n;
    logic  [1-1:0]  tdqs_n;
    logic   odt;

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


interface mem_intf(input logic i_cpu_ck);
   
	logic	     				i_cpu_reset;	// Reset passed to Controller from TB
	logic [ADDR_MCTRL-1:0]		i_cpu_addr;  	// Cpu Addr
	logic 	     				i_cpu_cmd;		// Cpu command RD or WR
	logic [8*DQ_BITS-1:0]		i_cpu_wr_data;	// Cpu Write Data 
	logic 	     				i_cpu_valid;	// Valid is set when passing CPU addr and command
	logic 	     				i_cpu_enable;	// Chip Select
	logic [BURST_L-1:0]  		i_cpu_dm;		// Data Mask - One HOT
	logic [$clog2(BURST_L):0]	i_cpu_burst;	// Define Burst Length - wont be used for now
	logic [8*DQ_BITS-1:0]		o_cpu_rd_data;	// Cpu data Read
	logic	     				o_cpu_data_rdy;	// Cpu data Read	
	logic 						o_cpu_rd_data_valid; // Signal for valid data sent to CPU   
	
  
  // Memory Controller modport
  modport MemController (
		input 	i_cpu_ck,
		input 	i_cpu_reset,
		input 	i_cpu_addr,
		input 	i_cpu_cmd,
		input 	i_cpu_wr_data,
		input 	i_cpu_valid,
		input 	i_cpu_enable,
		input 	i_cpu_dm,
		input 	i_cpu_burst,
		output  o_cpu_rd_data,
		output  o_cpu_data_rdy,	
		output 	o_cpu_rd_data_valid);

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
		input 	o_cpu_rd_data_valid);

    endinterface : mem_intf

