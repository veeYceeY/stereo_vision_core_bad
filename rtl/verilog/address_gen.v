module address_gen_rw
	(
		input wire clk_in,
		input wire rst_in,
		input wire inc_in,
		output wire[18:0] x_index_out,
		output wire[18:0] y_index_out,
		output reg ov_out
	);
	
	localparam WIDTH  = 320,
				  HEIGHT = 240;
	
	reg [18:0] x_count;
	reg [18:0] y_count;
	
	assign x_index_out=x_count;
	assign y_index_out=y_count;
	
	always@(posedge inc_in,negedge rst_in)
	begin
		if(!rst_in)
		begin
			x_count<=19'b0;
			y_count<=19'b0;
			ov_out<=1'b0;
		end
		else
		begin
			///if(inc_in)
			begin
				if(x_count<(WIDTH-1))
				begin
					x_count<=x_count+1'b1;
				end
				else
				begin
					x_count<=19'b0;
					if(y_count<(HEIGHT-1))
					begin
						y_count<=y_count+1'b1;
					end
					else
					begin
						ov_out<=1'b1;
					end
				end
			end
		end
	end
	
endmodule