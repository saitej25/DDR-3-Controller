module counter (
	input  logic       clock    ,
	input  logic       reset    ,
	input  logic       en,
	input  logic [31:0] max_count,
	output bit         done     ,
	output bit [31:0] count
);

	always@(posedge clock) begin
		if((reset) | (count==max_count-1))
			count <= 0;
		else if(en)
			count <= count+1;
	end

	assign done = (count==max_count-1);

endmodule
