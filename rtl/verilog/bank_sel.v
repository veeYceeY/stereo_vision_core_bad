module bank_sel
			(
				input wire [1:0]  sel_in,
				output reg [18:0] x_out
			);

			
	always@*
	begin
		case(sel_in)
		2'b00:
		begin
			x_out=19'd0;
		end
		2'b01:
		begin
			x_out=19'd174763;
		end
		2'b10:
		begin
			x_out=19'd349525;
		end
		2'b11:
		begin
			x_out=19'bz;
		end
		default:
		begin
			x_out=19'bz;
		end
		endcase
	end
			
endmodule