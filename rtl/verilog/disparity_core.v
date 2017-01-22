module disparity_core
    (
      input wire clk_in,
      input wire rst_in,
		input wire load_in,
      input wire [1:0]mode_in,
      input wire [18:0]roi_x_in,
      input wire [18:0]roi_y_in,
			input wire [18:0] win_5x5_x_index_in,
			input wire [18:0] win_5x5_y_index_in,
			input wire [18:0] win_68x5_x_index_in,
			input wire [18:0] win_68x5_y_index_in,
      input wire strip_ov_in,
      input wire [7:0] pix_in,
      output wire [7:0]disparity_out,
      output reg disp_done_out
    );

    reg [7:0]	win_5x5_buff[4:0][4:0];
    reg  [7:0] 	win_69x5_buff[68:0][4:0];
    reg  [7:0] index;
    wire [7:0] 	diff[24:0];
    wire [31:0] sad_val;
    reg  [2:0]  state;
     reg  [7:0]	count;
    reg  [31:0]  lowest_sad;
    reg         disparity_sign;
    reg [7:0]   disparity;
    //State definition
    localparam 	IDLE		 = 3'b001,
            DISPARITY = 3'b011,
            SAD		 = 3'b100,
            DISP		 = 3'b101,
            DONE		 = 3'b110;
    //mode definition				
    localparam  LOAD_5x5 = 3'b00,
            LOAD_69x5= 3'b01,
            START		 = 3'b10,
            DISABLE	 = 3'b11;
            
    //Setting
    localparam  SAD_WAIT_CYCLES =8'd14;				
            
				
	always@(posedge load_in)
	begin
          case(mode_in)
				 LOAD_5x5:
				 begin
					win_5x5_buff[win_5x5_x_index_in][win_5x5_y_index_in]<=pix_in;
				 end
				 LOAD_69x5:
				 begin
					win_69x5_buff[win_68x5_x_index_in][win_68x5_y_index_in]<=pix_in;
				 end
				 DISABLE:
				 begin
					
				 end
          endcase
	end
				
				
    assign disparity_out = disparity;		
    wire[18:0] right_pos = (roi_x_in-35)+(index);
    always@(posedge clk_in,negedge rst_in)
    begin
      if(!rst_in)
      begin
			index<=19'd2;
        state<=IDLE;
        count<=8'b0;
        disparity<=0;
        disp_done_out<=1'b1;
        lowest_sad<=32'hFFFFFFFF;
      end
      else
      begin	
        case(state)
        IDLE:
        begin
          case(mode_in)
          LOAD_5x5:
          begin
            //win_5x5_buff[win_5x5_x_index_in][win_5x5_y_index_in]<=pix_in;
          end
          LOAD_69x5:
          begin
				//win_69x5_buff[win_68x5_x_index_in][win_68x5_y_index_in]<=pix_in;
          end
          START:
          begin
            index<=19'd2;
				count<=8'b0;
				disp_done_out<=1'b0;	
				state<=SAD;
          end
          DISABLE:
          begin
            
          end
          endcase
        end
        SAD: 
        begin
				if(count>SAD_WAIT_CYCLES)
				begin
					count<=8'b0;
					state<=DISP;
				end
				else
				begin
					count<=count+1;
				end
			end
        DISP:
        begin
			
          if(sad_val<lowest_sad)
          begin
            lowest_sad<=sad_val;
				disparity<=index;
          end
          else
          begin
            lowest_sad<=lowest_sad;
            disparity<=disparity;
          end
			 
          if(index<66)
			    begin
				    index<=index+1;
				    state<=SAD;
			   end
			   else
			     state<=DONE;
			   begin
			   end
            
        end
        DONE:
        begin
          lowest_sad<=32'hFFFFFFFF;
          
				  state<=IDLE;
				  disp_done_out<=1'b1;			    
        end
        default:
        begin
          state<=IDLE;
        end
        endcase
      end
    end
  
    
assign diff[0]=	win_5x5_buff[0][0]<win_69x5_buff[index-2][0]?win_69x5_buff[index-2][0]-win_5x5_buff[0][0]:win_5x5_buff[0][0]-win_69x5_buff[index-2][0];
assign diff[1]=	win_5x5_buff[0][1]<win_69x5_buff[index-2][1]?win_69x5_buff[index-2][1]-win_5x5_buff[0][1]:win_5x5_buff[0][1]-win_69x5_buff[index-2][1];
assign diff[2]=	win_5x5_buff[0][2]<win_69x5_buff[index-2][2]?win_69x5_buff[index-2][2]-win_5x5_buff[0][2]:win_5x5_buff[0][2]-win_69x5_buff[index-2][2];
assign diff[3]=	win_5x5_buff[0][3]<win_69x5_buff[index-2][3]?win_69x5_buff[index-2][3]-win_5x5_buff[0][3]:win_5x5_buff[0][3]-win_69x5_buff[index-2][3];
assign diff[4]=	win_5x5_buff[0][4]<win_69x5_buff[index-2][4]?win_69x5_buff[index-2][4]-win_5x5_buff[0][4]:win_5x5_buff[0][4]-win_69x5_buff[index-2][4];
    
assign diff[5]=	win_5x5_buff[1][0]<win_69x5_buff[index-1][0]?win_69x5_buff[index-1][0]-win_5x5_buff[1][0]:win_5x5_buff[1][0]-win_69x5_buff[index-1][0];
assign diff[6]=	win_5x5_buff[1][1]<win_69x5_buff[index-1][1]?win_69x5_buff[index-1][1]-win_5x5_buff[1][1]:win_5x5_buff[1][1]-win_69x5_buff[index-1][1];
assign diff[7]=	win_5x5_buff[1][2]<win_69x5_buff[index-1][2]?win_69x5_buff[index-1][2]-win_5x5_buff[1][2]:win_5x5_buff[1][2]-win_69x5_buff[index-1][2];
assign diff[8]=	win_5x5_buff[1][3]<win_69x5_buff[index-1][3]?win_69x5_buff[index-1][3]-win_5x5_buff[1][3]:win_5x5_buff[1][3]-win_69x5_buff[index-1][3];
assign diff[9]=	win_5x5_buff[1][4]<win_69x5_buff[index-1][4]?win_69x5_buff[index-1][4]-win_5x5_buff[1][4]:win_5x5_buff[1][4]-win_69x5_buff[index-1][4];
      
assign diff[10]=	win_5x5_buff[2][0]<win_69x5_buff[index][0]?win_69x5_buff[index][0]-win_5x5_buff[2][0]:win_5x5_buff[2][0]-win_69x5_buff[index][0];
assign diff[11]=	win_5x5_buff[2][1]<win_69x5_buff[index][1]?win_69x5_buff[index][1]-win_5x5_buff[2][1]:win_5x5_buff[2][1]-win_69x5_buff[index][1];
assign diff[12]=	win_5x5_buff[2][2]<win_69x5_buff[index][2]?win_69x5_buff[index][2]-win_5x5_buff[2][2]:win_5x5_buff[2][2]-win_69x5_buff[index][2];
assign diff[13]=	win_5x5_buff[2][3]<win_69x5_buff[index][3]?win_69x5_buff[index][3]-win_5x5_buff[2][3]:win_5x5_buff[2][3]-win_69x5_buff[index][3];
assign diff[14]=	win_5x5_buff[2][4]<win_69x5_buff[index][4]?win_69x5_buff[index][4]-win_5x5_buff[2][4]:win_5x5_buff[2][4]-win_69x5_buff[index][4];
      
assign diff[15]=	win_5x5_buff[3][0]<win_69x5_buff[index+1][0]?win_69x5_buff[index+1][0]-win_5x5_buff[3][0]:win_5x5_buff[3][0]-win_69x5_buff[index+1][0];
assign diff[16]=	win_5x5_buff[3][1]<win_69x5_buff[index+1][1]?win_69x5_buff[index+1][1]-win_5x5_buff[3][1]:win_5x5_buff[3][1]-win_69x5_buff[index+1][1];
assign diff[17]=	win_5x5_buff[3][2]<win_69x5_buff[index+1][2]?win_69x5_buff[index+1][2]-win_5x5_buff[3][2]:win_5x5_buff[3][2]-win_69x5_buff[index+1][2];
assign diff[18]=	win_5x5_buff[3][3]<win_69x5_buff[index+1][3]?win_69x5_buff[index+1][3]-win_5x5_buff[3][3]:win_5x5_buff[3][3]-win_69x5_buff[index+1][3];
assign diff[19]=	win_5x5_buff[3][4]<win_69x5_buff[index+1][4]?win_69x5_buff[index+1][4]-win_5x5_buff[3][4]:win_5x5_buff[3][4]-win_69x5_buff[index+1][4];
    
assign diff[20]=	win_5x5_buff[4][0]<win_69x5_buff[index+2][0]?win_69x5_buff[index+2][0]-win_5x5_buff[4][0]:win_5x5_buff[4][0]-win_69x5_buff[index+2][0];
assign diff[21]=	win_5x5_buff[4][1]<win_69x5_buff[index+2][1]?win_69x5_buff[index+2][1]-win_5x5_buff[4][1]:win_5x5_buff[4][1]-win_69x5_buff[index+2][1];
assign diff[22]=	win_5x5_buff[4][2]<win_69x5_buff[index+2][2]?win_69x5_buff[index+2][2]-win_5x5_buff[4][2]:win_5x5_buff[4][2]-win_69x5_buff[index+2][2];
assign diff[23]=	win_5x5_buff[4][3]<win_69x5_buff[index+2][3]?win_69x5_buff[index+2][3]-win_5x5_buff[4][3]:win_5x5_buff[4][3]-win_69x5_buff[index+2][3];
assign diff[24]=	win_5x5_buff[4][4]<win_69x5_buff[index+2][4]?win_69x5_buff[index+2][4]-win_5x5_buff[4][4]:win_5x5_buff[4][4]-win_69x5_buff[index+2][4];
      
    
  assign sad_val=diff[0]+diff[1]+
            diff[2]+diff[3]+
            diff[4]+diff[5]+
            diff[6]+diff[7]+
            diff[8]+diff[9]+
            
            diff[10]+diff[11]+
            diff[12]+diff[13]+
            diff[14]+diff[15]+
            diff[16]+diff[17]+
            diff[18]+diff[19]+
            
            diff[20]+diff[21]+
            diff[22]+diff[23]+
            diff[24];	
    
endmodule