
module address_map
	(	input wire [1:0]  sel_in,
		input wire[18:0]  col_index_in,
		input wire[18:0]  row_index_in,
		output wire [18:0] address_out
	);
	
	
	localparam array_wid=19'd320;
	localparam array_hgt=19'd240;
	
	localparam 	LEFT_IMAGE 		= 19'd10,
					RIGHT_IMAGE		= 19'd174763,
					DISP_IMAGE		= 19'd349525;
	
	reg [31:0] address;
	
	always@*
	begin
		case(sel_in)
		2'b00:
		begin
			address=LEFT_IMAGE+(row_index_in*(array_wid))+col_index_in;
		end
		2'b01:
		begin
			address=RIGHT_IMAGE+(row_index_in*(array_wid))+col_index_in;
		end
		2'b10:
		begin
			address=DISP_IMAGE+(row_index_in*(array_wid))+col_index_in;
		end
		2'b11:
		begin
			address=LEFT_IMAGE+(row_index_in*(array_wid))+col_index_in;
		end
		default:
		begin
			
		end
		endcase
	end
	
	assign address_out=address[18:0];
	
		
endmodule