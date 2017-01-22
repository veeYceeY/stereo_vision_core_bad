module address_generator
  (
    input wire clk_in,
    
    input wire rst_roi_in,
    input wire rst_5x5_in,
    input wire rst_68x5_in,
    
    input wire inc_roi_in,
    input wire inc_5x5_in,
    input wire inc_68x5_in,
    
    output reg[18:0] ram_5x5_x_out,
    output reg[18:0] ram_5x5_y_out,
    output wire[18:0] win_5x5_x_out,
    output wire[18:0] win_5x5_y_out,
    
    output reg[18:0] ram_68x5_x_out,
    output reg[18:0] ram_68x5_y_out,
    output wire[18:0] win_68x5_x_out,
    output wire[18:0] win_68x5_y_out,
    
    output wire[18:0] roi_x_out,
    output wire[18:0] roi_y_out,
    
    output reg  roi_line_ov_out,
    output reg  roi_ov_out,
    output reg  win_5x5_ov_out,
    output reg  win_68x5_ov_out
  );
  
  reg [18:0]  roi_x_counter,
              win_5x5_x_counter,
              win_68x5_x_counter,
              roi_y_counter,
              win_5x5_y_counter,
              win_68x5_y_counter;
  localparam  WIDTH   = 320,
              HEIGHT  = 240;            
              
  assign win_5x5_x_out = win_5x5_x_counter;
  assign win_5x5_y_out = win_5x5_y_counter;
  
  assign win_68x5_x_out = win_68x5_x_counter;
  assign win_68x5_y_out = win_68x5_y_counter;
  
  
  assign roi_x_out = roi_x_counter;
  assign roi_y_out = roi_y_counter;
  
  
  
  
  
  ///////ROI counter/////////
  always@(posedge inc_roi_in,negedge rst_roi_in)
  begin
      if(!rst_roi_in)
        begin
          roi_x_counter=19'd2;
          roi_y_counter=19'd2;
          roi_line_ov_out=1'b0;
          roi_ov_out=1'b0;
        end
      else
        begin
          //if(inc_roi_in)
            begin
              if(roi_x_counter<WIDTH-3)
                begin
                  roi_x_counter=roi_x_counter+1'b1;
                  roi_line_ov_out<=1'b0;
                end
              else
                begin
                  roi_line_ov_out=1'b1;
                  if(roi_y_counter<HEIGHT-3)
                    begin
                      roi_x_counter=19'd2;
                      roi_y_counter=roi_y_counter+1'b1;
                    end
                  else
                    begin
                      roi_ov_out=1'b1;
                    end
                end
            end
        end
  end
  
  //assign roi_ov_out = (roi_y_counter>=(HEIGHT-3)) & (roi_x_counter>=(WIDTH-3));
  //assign roi_line_ov_out = roi_x_counter>=(WIDTH-3);
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  ////5x5 window counter
  always@(posedge inc_5x5_in,negedge rst_5x5_in)
  begin
      if(!rst_5x5_in)
        begin
          win_5x5_x_counter=19'd0;
          win_5x5_y_counter=19'd0;
          win_5x5_ov_out=1'b0;
				ram_5x5_y_out = (roi_y_counter-2)+ win_5x5_y_counter; 
				ram_5x5_x_out = (roi_x_counter-2)+ win_5x5_x_counter;
        end
      else
        begin
          //if(inc_5x5_in)
            begin
              if(win_5x5_x_counter<4)
                begin
                  win_5x5_x_counter=win_5x5_x_counter+1'b1;
                end
              else
                begin
                  if(win_5x5_y_counter<4)
                    begin
                      win_5x5_x_counter=19'd0;
                      win_5x5_y_counter=win_5x5_y_counter+1'b1;
                    end
                  else
                    begin
                      win_5x5_ov_out=1'b1;
                    end
                end
            end
				ram_5x5_y_out = (roi_y_counter-2)+ win_5x5_y_counter; 
				ram_5x5_x_out = (roi_x_counter-2)+ win_5x5_x_counter;
        end
  end
  
  //assign win_5x5_ov_out = (win_5x5_y_counter>=4) & (win_5x5_x_counter>=4);
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  ////68x5 window counter 
  
  always@(posedge inc_68x5_in,negedge rst_68x5_in)
  begin
      if(!rst_68x5_in)
        begin
          win_68x5_x_counter=19'd0;
          win_68x5_y_counter=19'd0;
          win_68x5_ov_out=1'b0;
				if(roi_x_counter>34)
				  begin
					 if(roi_x_counter>WIDTH-34)
						begin
						  ram_68x5_x_out=win_68x5_x_counter+(WIDTH-69);
						end
					 else
						begin
						  ram_68x5_x_out=win_68x5_x_counter+(roi_x_counter-35);
						end
				  end
				else
				  begin
					 ram_68x5_x_out=win_68x5_x_counter;
				  end
				ram_68x5_y_out = (roi_y_counter-2)+ win_68x5_y_counter;
        end
      else
        begin
          //if(inc_68x5_in)
            begin
              if(win_68x5_x_counter<68)
                begin
                  win_68x5_x_counter=win_68x5_x_counter+1'b1;
                end
              else
                begin
                  if(win_68x5_y_counter<4)
                    begin
                      win_68x5_x_counter=19'd0;
                      win_68x5_y_counter=win_68x5_y_counter+1'b1;
                    end
                  else
                    begin
                      win_68x5_ov_out=1'b1;
                    end
                end
            end
				
				if(roi_x_counter>34)
				  begin
					 if(roi_x_counter>WIDTH-34)
						begin
						  ram_68x5_x_out=win_68x5_x_counter+(WIDTH-69);
						end
					 else
						begin
						  ram_68x5_x_out=win_68x5_x_counter+(roi_x_counter-35);
						end
				  end
				else
				  begin
					 ram_68x5_x_out=win_68x5_x_counter;
				  end
				ram_68x5_y_out = (roi_y_counter-2)+ win_68x5_y_counter;
        end
  end
  //assign win_68x5_ov_out = (win_68x5_y_counter>=4) & (win_68x5_x_counter>=68); 
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  
  
endmodule