module cpu_model (
	input        i_cpu_ck,
	output	     error,
	mem_intf.cpu if_cpu
);

	enum bit [3:0] {IDLE,RESET,WAIT_RDY,LOAD_LFSR,DELAY,WRITE,WRITE_DELAY,WRITE_RDY_WAIT,READ,READ_VLD_WAIT,COMPARE} state;

	bit [31:0] max_count;
	bit [63:0] wr_data,rd_data;
	bit [26:0] wr_addr;
	bit        error,en,lfsr_enable    ;
	logic [63:0] t_wr_data;
	logic [26:0] t_wr_addr;

	lfsr #(27) addr_lfsr (.out(t_wr_addr), .enable(1), .clk(i_cpu_ck), .reset(1'b0));
	lfsr #(64) data_lfsr (.out(t_wr_data), .enable(1), .clk(i_cpu_ck), .reset(1'b0));
	counter i_counter (.clock(i_cpu_ck), .reset(0), .en(en), .max_count(max_count), .done(timer_intr), .count());

	always_ff @(posedge i_cpu_ck) begin : proc_fsm
		case (state)
			IDLE : if(timer_intr)
				state <= RESET;

			RESET : state <= WAIT_RDY;

			WAIT_RDY : if(if_cpu.o_cpu_data_rdy)
				state <= LOAD_LFSR;

			LOAD_LFSR : state <= DELAY;

			DELAY: state <= WRITE;

			WRITE : state <= WRITE_DELAY;

			WRITE_DELAY: if(!if_cpu.o_cpu_data_rdy)	state <= WRITE_RDY_WAIT;

			WRITE_RDY_WAIT : if(if_cpu.o_cpu_data_rdy)
				state <= READ;

			READ : if(!if_cpu.o_cpu_data_rdy)
				state <= READ_VLD_WAIT;

			READ_VLD_WAIT : if(if_cpu.o_cpu_rd_data_valid)
				state <= COMPARE;

			COMPARE : if(!error)
				state <= WAIT_RDY;

			default : state <= IDLE;
		endcase
	end

	always_comb begin : proc_out
		en                  = 0;
		lfsr_enable         = 0;
		if_cpu.i_cpu_reset  = 0;
		if_cpu.i_cpu_cmd    = 0;
		if_cpu.i_cpu_valid  = 0;
		error               = 0;
		if_cpu.i_cpu_wr_data = 0;
		if_cpu.i_cpu_addr =0;
		max_count 			= 0;
		case (state)
			IDLE : begin
				en        = 1;
				max_count = 'd5000;
			end

			RESET : begin
				if_cpu.i_cpu_reset = 1;
			end

			LOAD_LFSR : lfsr_enable = 1;

			WRITE : begin
				if_cpu.i_cpu_cmd    = 1;
				if_cpu.i_cpu_valid = 1;
				if_cpu.i_cpu_wr_data = wr_data;
				if_cpu.i_cpu_addr = wr_addr;

			end

			READ : begin
				if_cpu.i_cpu_cmd    = 0;
				if_cpu.i_cpu_valid = 1;
				if_cpu.i_cpu_addr = wr_addr;
			end

			COMPARE : error = (wr_data[55:0]!=rd_data[55:0]);

			default : begin
				en                  = 0;
				lfsr_enable         = 0;
				if_cpu.i_cpu_reset  = 0;
				if_cpu.i_cpu_cmd    = 0;
				if_cpu.i_cpu_valid  = 0;
			end
		endcase
	end

	always_ff @(posedge i_cpu_ck) if (state==LOAD_LFSR) wr_data <= t_wr_data;
	always_ff@(posedge i_cpu_ck) if(state==LOAD_LFSR) wr_addr <= t_wr_addr;
	always_ff @(posedge i_cpu_ck) if (if_cpu.o_cpu_rd_data_valid) rd_data <= if_cpu.o_cpu_rd_data;

endmodule
