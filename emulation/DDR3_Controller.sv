
import DDR3MemPkg::* ;
module  DDR3_controller(
	input logic 			i_cpu_ck,
	input logic 			i_cpu_ck_ps,
	mem_intf.MemController 	cont_if_cpu,
	mem_if.contr_sig		cont_if_mem
	);

logic timer_intr;							// Timer interrupt flag
logic rw_flag;								// Read right flag
logic en;									// enable signal for counter
logic [31:0] max_count		= 'd0;			// Max count for internal clock cycle counting
logic [31:0] v_count;
logic t_flag;
logic s_cpu_rd_data_valid;
logic  [63:0] s_cpu_rd_data;
logic  [28:0] s_addr                        ;
logic  [15:0] wdata;
logic  [15:0] rdata;
logic  [63:0] s_data;
logic  [15:0] wdata_local                   ;
logic  [15:0] rdata_local                   ;
logic  [63:0] cpu_rd_data                   ;
logic  [7:0] ddr_wdata;
typedef enum logic [3:0] {POWER_UP,IDLE,ACTIVATE,READ, WRITE}States;
	bit toggle;
States state;

logic [7:0] rdata_pip;
wire [15:0] rdata_local_t;
//=================================Internal module instantiation==========================

counter i_counter(.clock(i_cpu_ck), .reset(cont_if_cpu.i_cpu_reset), .en(en), .max_count(max_count), .done(timer_intr), .count(v_count));

always_ff@(posedge i_cpu_ck) rdata_pip <= rdata_local_t[15:8];

assign rdata_local = {rdata_pip,rdata_local_t[7:0]};

my_oddrx8 write_inst(
					 .clk(i_cpu_ck),
					 .d0(wdata_local[7:0]),
					 .d1(wdata_local[15:8]),
					 .io(ddr_wdata));

my_iddrx8 iddrx8_dm_inst (
		.clk(i_cpu_ck),
		.io (cont_if_mem.dq),
		.d0 (rdata_local_t[7:0]),
		.d1 (rdata_local_t[15:8])
	);

// Configure controller clock according to the CPU clock
assign cont_if_mem.ck   = i_cpu_ck;		
assign cont_if_mem.ck_n = ~i_cpu_ck;


//================================== STATE TRANSITION BLOCK===============================

always_comb
begin
	cont_if_cpu.o_cpu_rd_data <= cpu_rd_data;
	cont_if_cpu.o_cpu_rd_data_valid <= s_cpu_rd_data_valid;
end
 


always_ff @ (posedge i_cpu_ck) begin
	if(cont_if_cpu.i_cpu_reset)
		state <= POWER_UP;
	else 
		unique case (state)

			POWER_UP: if(timer_intr)
			state <= IDLE;

			IDLE: if (cont_if_cpu.i_cpu_valid)
			state <= ACTIVATE;

			ACTIVATE: begin
						if(rw_flag == 1)
							state <= WRITE;
						else 
							state <= READ;
			end // ACTIVATE:

			WRITE: begin
					if(timer_intr) 
						state <= IDLE;
					else 
						state<= WRITE;
			end // WRITE:

			READ : begin
					if(timer_intr)
						state<= IDLE;
					else
						state<= READ;
			end // READ :

			default : state <= ACTIVATE;
		endcase // state
end // always_ff @ (posedge ck)


always_comb cont_if_cpu.o_cpu_data_rdy <= (state==IDLE);


//===========================Output block=======================================

always_comb begin
		cont_if_mem.rst_n = 1'b1;		// deassert reset
		cont_if_mem.odt   = 1'b1;		// Set odt
		cont_if_mem.ras_n = 1'b1;		// deassert ras
		cont_if_mem.cas_n = 1'b1;		// deassert cas
		cont_if_mem.cs_n  = 1'b0;		// deassert chipselect
		cont_if_mem.we_n  = 1'b1;		// deassert write enable
		cont_if_mem.ba    = 'b0;		// set bank address to 0
		cont_if_mem.addr  = 'b0;		// set address to 0
		cont_if_mem.cke   = 'b1;		// Set clock enable

		t_flag			  	= 'b0;		// flag for count 
		s_cpu_rd_data_valid = 0;		// Data valid signal while read		
		s_cpu_rd_data 		= 0;		// Data after read from memory		
		max_count          =0;
		en        		= 1'b0;	 
		case (state)
			POWER_UP: begin
			max_count = 10;
			cont_if_mem.rst_n = 1'b0;
			en = 1;
			end

			ACTIVATE : begin
					cont_if_mem.ba    = s_addr[12:10];
					cont_if_mem.addr  = s_addr[28:16];
					cont_if_mem.ras_n = 1'b0;				// check if we_n should be asserted
			end	// ACTIVATE 

			READ : begin
				max_count = 17;
				en        = 1'b1;
				cont_if_mem.odt = 1'b0;
				if(v_count == 'd0)begin
					cont_if_mem.we_n  = 1'b1;
					cont_if_mem.ba    = s_addr[12:10];
					cont_if_mem.addr  = {s_addr[9:3],3'b0};
					cont_if_mem.cas_n = 1'b0;
				end
				else if(v_count == 'd16) begin				
					cpu_rd_data[63:48] = rdata_local;
					s_cpu_rd_data_valid = 1;
					end
				else if(v_count == 'd15) 
					cpu_rd_data[47:32] = rdata_local;
				else if(v_count == 'd14) 
					cpu_rd_data[31:16] = rdata_local;
				else if(v_count == 'd13) begin
					cpu_rd_data[15:0] = rdata_local;
					end
			end

			WRITE : begin
				en        = 1'b1;
				max_count = 13;
				if(v_count == 'd0) begin
					cont_if_mem.we_n  = 1'b0;
					cont_if_mem.ba    = s_addr[12:10];
					cont_if_mem.addr  = {s_addr[9:3],3'b0};
					cont_if_mem.cas_n = 1'b0;
				end
				if(v_count == 'd9) 
					wdata_local = s_data[15:0];
				else if(v_count == 'd10) 
					wdata_local = s_data[31:16];
				else if(v_count == 'd11)
					wdata_local = s_data[47:32];
				else if(v_count == 'd12)
					wdata_local = s_data[63:48];
			end
		endcase // state	


end

// TRISTATING  DQ , DQS
	assign s_valid_data = (state==WRITE) & (v_count >=9);
	assign dq_valid = (state==WRITE) & (v_count >=9);

	assign cont_if_mem.dq      = (dq_valid) ? ddr_wdata	:'bz ;
	assign cont_if_mem.dqs     = (s_valid_data) ? i_cpu_ck	:'bz ;
	assign cont_if_mem.dqs_n   = (s_valid_data) ? ~i_cpu_ck	:'bz ;
//	assign cont_if_mem.dm_tdqs = (s_valid_data) ?  ((v_count==9) ? i_cpu_ck : (v_count==10) ? 1'b1 : (v_count==11) ? 1'b1 : ~i_cpu_ck) :'b0 ;
	assign cont_if_mem.dm_tdqs = (s_valid_data) ?  i_cpu_ck : 1'b0;

	
//	always_ff@(posedge i_cpu_ck) 
//		if( (cont_if_cpu.i_cpu_reset) | (state==IDLE) )
//			toggle <= 0;
//		else if (s_valid_data)
//			toggle <= ~toggle;

	always_ff @(posedge i_cpu_ck) begin : proc_addr_data_lacth
		if(cont_if_cpu.i_cpu_reset) begin
			s_addr <= 0;
			s_data <= 0;
		end else if ((cont_if_cpu.i_cpu_valid) & (state==IDLE)) begin
			s_addr <= cont_if_cpu.i_cpu_addr;
			s_data <= cont_if_cpu.i_cpu_wr_data;
		end
	end
	
	always_ff @ (posedge i_cpu_ck) begin
		if({cont_if_cpu.i_cpu_reset}) begin
			rw_flag <= 0;
		end
		else if ((cont_if_cpu.i_cpu_valid)& (state==IDLE))
			rw_flag <= (cont_if_cpu.i_cpu_cmd);
	end

endmodule 
