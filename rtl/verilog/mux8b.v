module mux8b
			(
				input wire [7:0] a_in,
				input wire [7:0] b_in,
				input wire [7:0] c_in,
				input wire [7:0] d_in,
				input wire [1:0]  sel_in,
				output reg [7:0] x_out
			);

			
	always@*
	begin
		case(sel_in)
		2'b00:
		begin
			x_out=a_in;
		end
		2'b01:
		begin
			x_out=b_in;
		end
		2'b10:
		begin
			x_out=c_in;
		end
		2'b11:
		begin
			x_out=d_in;
		end
		default:
		begin
			x_out=8'bz;
		end
		endcase
	end
			
endmodule