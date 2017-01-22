module mux
			(
				input wire [18:0] x0_in,
				input wire [18:0] x1_in,
				input wire [18:0] x2_in,
				input wire [18:0] x3_in,
				
				input wire [18:0] y0_in,
				input wire [18:0] y1_in,
				input wire [18:0] y2_in,
				input wire [18:0] y3_in,
				
				input wire [1:0]  sel_in,
				output reg [18:0] x_out,
				output reg [18:0] y_out
			);

			
	always@*
	begin
		case(sel_in)
		2'b00:
		begin
			x_out=x0_in;
			y_out=y0_in;
		end
		2'b01:
		begin
			x_out=x1_in;
			y_out=y1_in;
		end
		2'b10:
		begin
			x_out=x2_in;
			y_out=y2_in;
		end
		2'b11:
		begin
			x_out=x3_in;
			y_out=y3_in;
		end
		default:
		begin
			x_out=19'bz;
			y_out=19'bz;
		end
		endcase
	end
			
endmodule