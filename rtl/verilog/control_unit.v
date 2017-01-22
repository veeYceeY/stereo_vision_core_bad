module control_unit
	(
		input wire clk_in,
		input wire rst_in,
		
		input wire [7:0] cmd_in,
		
		output reg tx_trig,
		output reg sram_trig,
		
		output reg sram_rw,
		output reg [1:0] disp_mode,
		output reg load_window,
		
		output reg [1:0] mem_bank_sel,
		output reg [1:0] addr_sel,
		output reg [1:0] wr_data_sel,
		output reg [1:0] tx_data_sel,
		
		output reg rst_rw,
		output reg rst_l,
		output reg rst_r,
		output reg rst_roi,
		output reg rst_disp,
		
		output reg inc_rw,
		output reg inc_l,
		output reg inc_r,
		output reg inc_roi,
		
		input wire rw_ov,
		input wire roi_ov,
		input wire win_l_ov,
		input wire win_r_ov,
		
		input wire disp_done,
		input wire sram_done,
		input wire tx_done,
		input wire rx_drdy,
		
		output wire [7:0] debug,
		output wire [7:0] debug2
	);
	
	
	reg [1:0]	mem_sel;
	//////////////Signal def//////////////////////
	localparam	LOW =1'b0,
					HIGH=1'b1;
	//////////////////////////////////////////////
	
	/////////////*state defenition*///////////////
	reg [7:0] state,state_disp,state_read,state_write;
	reg [7:0] next_state,next_state_disp,next_state_read,next_state_write;
	
	localparam 	INIT							=1,
					IDLE							=2,
					UART_RX_WAIT				=3,
					UART_TX						=4,
					UART_TX_WAIT				=5,
					INC_ROI						=6,
					RST_ROI						=7,
					INC_L							=8,
					RST_L							=9,
					INC_R							=10,
					RST_R							=11,
					INC_RW						=12,
					RST_RW						=13,
					SRAM_READ_PRE_WAIT		=14,
					SRAM_READ					=15,
					SRAM_READ_POST_WAIT		=16,
					SRAM_WRITE_PRE_WAIT		=17,
					SRAM_WRITE					=18,
					SRAM_WRITE_POST_WAIT		=19,
					DONE							=20,
					DISP_LOAD_L					=21,
					DISP_LOAD_R					=22,
					DISP_START					=23,
					DISP_WAIT					=24,
					RST_DISP						=25,
					DISP_WRITE					=26,
					SRAM_READ_R_PRE_WAIT		=27,
					SRAM_READ_R					=28,
					SRAM_READ_R_POST_WAIT	=29,
					COMMAND						=30,
					WRITE							=31,
					READ							=32,
					DISP							=33,
					DISP_WAIT2					=34,
					RW_OV							=35,
					ROI_OV						=36,
					L_OV							=37,
					R_OV							=38;

	///////////////////////////////////////////////	

	//////////*command defenition*/////////////////

	localparam	CMD_WRITE_L					=110,
					CMD_WRITE_R					=120,
					CMD_WRITE_DISP				=130,
					CMD_READ_L					=140,
					CMD_READ_R					=150,
					CMD_READ_DISP				=160,
					CMD_DISP						=170;
	///////////////////////////////////////////////
	
	/////////////*disparity mode defenition *//////
	localparam	DISP_LOAD_LEFT				=2'b00,
					DISP_LOAD_RIGHT			=2'b01,
					DISP_START_MODE			=2'b10,
					DISP_DISABLE				=2'b11;
	///////////////////////////////////////////////
	
	/////////////mem bank /////////////////////////
	localparam	LEFT_IMAGE					=2'b00,
					RIGHT_IMAGE					=2'b01,
					DISP_IMAGE					=2'b10;
	///////////////////////////////////////////////
	
	/////////////write data sel////////////////////
	localparam	DATA_UART_RX				=2'b00,
					DATA_DISP					=2'b01;
	///////////////////////////////////////////////

	/////////////address sel///////////////////////
	localparam	ADDR_RW						=2'b00,
					ADDR_L						=2'b01,
					ADDR_R						=2'b10,
					ADDR_DISP					=2'b11;
	///////////////////////////////////////////////
	
	////////////tx data sel////////////////////////
	localparam	DATA_SRAM					=2'b00;
	///////////////////////////////////////////////
	assign debug = state;
	assign debug2 = state_disp;
	///////////////////////////////////////////////
	always@(posedge clk_in,negedge rst_in)
	begin
		if(!rst_in)
		begin
			state<=INIT;
		end
		else
		begin
			state<=next_state;
			state_read<=next_state_read;
			state_write<=next_state_write;
			state_disp<=next_state_disp;
		end
	end
	
	always@(posedge clk_in)
	begin
				inc_l		=LOW;
				inc_r		=LOW;
				inc_roi	=LOW;
				inc_rw	=LOW;
				
				rst_rw	=HIGH;
				rst_l		=HIGH;
				rst_r		=HIGH;
				rst_roi	=HIGH;
				rst_disp	=HIGH;
				//sram_trig=LOW;
				//tx_trig	=LOW;
				
				//disp_mode=DISP_DISABLE;
				
				//sram_rw	=HIGH;
				/*
				tx_data_sel=DATA_SRAM;
				addr_sel	=ADDR_RW;
				mem_bank_sel=LEFT_IMAGE;
				mem_sel	=LEFT_IMAGE;
				wr_data_sel=DATA_UART_RX;*/
				
		case(state)
			INIT:
			begin
				inc_l		=LOW;
				inc_r		=LOW;
				inc_roi	=LOW;
				inc_rw	=LOW;
				
				rst_rw	=LOW;
				rst_l		=LOW;
				rst_r		=LOW;
				rst_roi	=LOW;
				rst_disp	=LOW;
				
				sram_trig<=LOW;
				tx_trig	=LOW;
				
				disp_mode=DISP_DISABLE;
				
				sram_rw	=HIGH;
				
				addr_sel	=ADDR_RW;
				mem_bank_sel=LEFT_IMAGE;
				mem_sel	=LEFT_IMAGE;
				wr_data_sel=DATA_UART_RX;
				
				next_state=COMMAND;
				next_state_disp=INIT;
				next_state_read=INIT;
				next_state_write=INIT;
			end
			COMMAND:
			begin
				rst_rw=HIGH;
				rst_l=HIGH;
				rst_r=HIGH;
				rst_roi=HIGH;
				rst_disp=HIGH;
				if(rx_drdy==HIGH)
				begin
					case(cmd_in)
						CMD_WRITE_L:
						begin
							mem_sel=LEFT_IMAGE;
							next_state_write=INIT;
							next_state=WRITE;
						end
						CMD_WRITE_R:
						begin
							mem_sel=RIGHT_IMAGE;
							next_state_write=INIT;
							next_state=WRITE;
						end
						CMD_WRITE_DISP:
						begin
							mem_sel=DISP_IMAGE;
							next_state_write=INIT;
							next_state=WRITE;
						end
						CMD_READ_L:
						begin
							mem_sel=LEFT_IMAGE;
							next_state_read=INIT;
							next_state=READ;
						end
						CMD_READ_R:
						begin
							mem_sel=RIGHT_IMAGE;
							next_state_read=INIT;
							next_state=READ;
						end
						CMD_READ_DISP:
						begin
							mem_sel=DISP_IMAGE;
							next_state_read=INIT;
							next_state=READ;
						end
						CMD_DISP:
						begin
							next_state=DISP;
							next_state_disp=INIT;
						end
					endcase
				end
			end
	////////////////////////////////////////////////
			WRITE:
			begin
				case(state_write)
					INIT:
					begin
						mem_bank_sel=mem_sel;
						addr_sel=ADDR_RW;
						wr_data_sel=DATA_UART_RX;
						next_state_write=RST_RW;
					end
					IDLE:
					begin
						rst_rw=HIGH;
						rst_l=HIGH;
						rst_r=HIGH;
						inc_rw=LOW;
						inc_l=LOW;
						inc_r=LOW;
						next_state_write=UART_RX_WAIT;
					end
					UART_RX_WAIT:
					begin
						if(rx_drdy)
						begin
							next_state_write=SRAM_WRITE_PRE_WAIT;
						end
					end
					UART_TX_WAIT:
					begin
						if(tx_done)
						begin
							//tx_trig
						end
					end
					INC_L:
					begin
						
					end
					RST_L:
					begin
						
					end
					INC_R:
					begin
						
						
					end
					RST_R:
					begin
						
						
					end
					INC_RW:
					begin
					/*	if(!rw_ov)
						begin
							inc_rw=HIGH;
							next_state_write=IDLE;
						end
						else
						begin
							next_state_write=DONE;
						end*/
						inc_rw=HIGH;
						next_state_write=RW_OV;
					end
					RW_OV:
					begin
						inc_rw=LOW;
						if(!rw_ov)
						begin
							next_state_write=IDLE;
						end
						else
						begin
							next_state_write=DONE;
						end
					end
					RST_RW:
					begin
						rst_rw=LOW;
						next_state_write=IDLE;
					end
					
					SRAM_READ_PRE_WAIT:
					begin
						
					end
					SRAM_READ:
					begin
						
					end
					SRAM_READ_POST_WAIT:
					begin
						
					end
					
					SRAM_WRITE_PRE_WAIT:
					begin
						if(sram_done)
						begin
							sram_rw=LOW;
							sram_trig<=HIGH;
							next_state_write=SRAM_WRITE;
						end
					end
					SRAM_WRITE:
					begin
						if(sram_done)
						begin
							
						end
						else
						begin
							sram_trig<=LOW;
							next_state_write=SRAM_WRITE_POST_WAIT;
						end
					end
					SRAM_WRITE_POST_WAIT:
					begin
						if(sram_done)
						begin
							sram_rw=HIGH;
							next_state_write=INC_RW;
						end
					end
					DONE:
					begin
						next_state_write=INIT;
						next_state=COMMAND;
					end
				endcase
			end
	////////////////////////////////////////////////
			READ:
			begin
				case(state_read)
					INIT:
					begin
						sram_trig<=LOW;
						addr_sel=ADDR_RW;
						mem_bank_sel=mem_sel;
						wr_data_sel=DATA_UART_RX;
						tx_data_sel=DATA_SRAM;
						next_state_read=RST_RW;
					end
					IDLE:
					begin
						rst_rw=HIGH;
						rst_l=HIGH;
						rst_r=HIGH;
						inc_rw=LOW;
						inc_l=LOW;
						inc_r=LOW;
						next_state_read=SRAM_READ_PRE_WAIT;
					end
					UART_RX_WAIT:
					begin
						if(rx_drdy)
						begin
							next_state_read=SRAM_WRITE_PRE_WAIT;
						end
					end
					UART_TX:
					begin
						if(tx_done)
						begin
							tx_trig=HIGH;
							next_state_read=UART_TX_WAIT;
						end
					end
					UART_TX_WAIT:
					begin
						if(!tx_done)
						begin
							tx_trig=LOW;
							next_state_read=INC_RW;
						end
					end
					INC_L:
					begin
						
					end
					RST_L:
					begin
						
					end
					INC_R:
					begin
						
						
					end
					RST_R:
					begin
						
						
					end
					INC_RW:
					begin
					/*
						if(!rw_ov)
						begin
							inc_rw=HIGH;
							next_state_read=IDLE;
						end
						else
						begin
							next_state_read=DONE;
						end*/
						
						inc_rw=HIGH;
						next_state_read<=RW_OV;
					end
					RW_OV:
					begin
						inc_rw=LOW;
						if(!rw_ov)
						begin
							next_state_read=IDLE;
						end
						else
						begin
							next_state_read=DONE;
						end
					end
					RST_RW:
					begin
						rst_rw=LOW;
						next_state_read=IDLE;
					end
					
					SRAM_READ_PRE_WAIT:
					begin
						if(sram_done)
						begin
							sram_rw=HIGH;
							sram_trig<=HIGH;
							next_state_read=SRAM_READ;
						end
					end
					SRAM_READ:
					begin
						if(sram_done)
						begin
						
						end
						else
						begin
							sram_trig<=LOW;
							next_state_read=SRAM_READ_POST_WAIT;
						end
					end
					SRAM_READ_POST_WAIT:
					begin
						if(sram_done)
						begin
							sram_rw=HIGH;
							next_state_read=UART_TX;
						end
					end
					
					SRAM_WRITE_PRE_WAIT:
					begin
						if(sram_done)
						begin
							sram_rw=LOW;
							sram_trig<=HIGH;
							next_state_read=SRAM_WRITE;
						end
					end
					SRAM_WRITE:
					begin
						if(sram_done)
						begin
							
						end
						else
						begin
							sram_trig<=LOW;
							next_state_read=SRAM_WRITE_POST_WAIT;
						end
					end
					SRAM_WRITE_POST_WAIT:
					begin
						if(sram_done)
						begin
							sram_rw=HIGH;
							next_state_read=UART_TX;
						end
					end
					DONE:
					begin
						next_state_read=INIT;
						next_state=COMMAND;
					end
				endcase
			end
	////////////////////////////////////////////////
			DISP:
			begin
				case(state_disp)
					INIT:
					begin
						addr_sel=ADDR_RW;
						mem_bank_sel=DISP_IMAGE;
						wr_data_sel=DATA_UART_RX;
						next_state_disp=RST_DISP;
					end
					IDLE:
					begin
						rst_rw=HIGH;
						rst_l=HIGH;
						rst_r=HIGH;
						rst_roi=HIGH;
						inc_rw=LOW;
						inc_l=LOW;
						inc_r=LOW;
						next_state_disp=DISP_LOAD_L;
					end
					DISP_LOAD_L:
					begin
						mem_bank_sel=LEFT_IMAGE;
						addr_sel=ADDR_L;
						disp_mode=DISP_LOAD_LEFT;
						next_state_disp=SRAM_READ_PRE_WAIT;
					end
					DISP_LOAD_R:
					begin
						mem_bank_sel=RIGHT_IMAGE;
						addr_sel=ADDR_R;
						disp_mode=DISP_LOAD_RIGHT;
						next_state_disp=SRAM_READ_R_PRE_WAIT;
					end
					DISP_START:
					begin
						disp_mode=DISP_START_MODE;
						next_state_disp=DISP_WAIT;
					end
					DISP_WAIT:
					begin
						if(!disp_done)
						begin
							disp_mode=DISP_DISABLE;
							next_state_disp=DISP_WAIT2;
						end
					end
					DISP_WAIT2:
					begin
						if(disp_done)
						begin
							next_state_disp=DISP_WRITE;
						end
					end
					RST_DISP:
					begin
						rst_disp=LOW;
						next_state_disp=RST_ROI;
					end
					DISP_WRITE:
					begin
						addr_sel=ADDR_DISP;
						mem_bank_sel=DISP_IMAGE;
						wr_data_sel=DATA_DISP;
						next_state_disp=SRAM_WRITE_PRE_WAIT;
					end
					UART_RX_WAIT:
					begin
						if(rx_drdy)
						begin
							next_state_disp=SRAM_WRITE_PRE_WAIT;
						end
					end
					UART_TX:
					begin
						if(tx_done)
						begin
							tx_trig=HIGH;
							next_state_disp=UART_TX_WAIT;
						end
					end
					UART_TX_WAIT:
					begin
						if(!tx_done)
						begin
							tx_trig=LOW;
							next_state_disp=INC_RW;
						end
					end
					INC_ROI:
					begin
						/*if(!roi_ov)
						begin
							inc_roi=HIGH;
							next_state_disp=RST_L;
						end
						else
						begin
							next_state_disp=DONE;
						end*/
						inc_roi=HIGH;
						next_state_disp=ROI_OV;
					end
					ROI_OV:
					begin
						inc_roi=LOW;
						if(!roi_ov)
						begin
							next_state_disp=RST_L;
						end
						else
						begin
							next_state_disp=DONE;
						end
					end
					RST_ROI:
					begin
						rst_roi=LOW;
						next_state_disp=RST_L;
					end
					INC_L:
					begin
						load_window=LOW;
						/*if(!win_l_ov)
						begin
							inc_l=HIGH;
							next_state_disp=DISP_LOAD_L;
						end
						else
						begin
							next_state_disp=DISP_LOAD_R;
						end*/
						inc_l=HIGH;
						next_state_disp=L_OV;
					end
					L_OV:
					begin
						inc_l=LOW;
						if(!win_l_ov)
						begin
							next_state_disp=DISP_LOAD_L;
						end
						else
						begin
							next_state_disp=DISP_LOAD_R;
						end
					end
					RST_L:
					begin
						rst_l=LOW;
						next_state_disp=RST_R;
					end
					INC_R:
					begin
						load_window=LOW;
						/*if(!win_r_ov)
						begin
							inc_r=HIGH;
							next_state_disp=DISP_LOAD_R;
						end
						else
						begin
							next_state_disp=DISP_START;
						end*/
						inc_r=HIGH;
						next_state_disp=R_OV;
					end
					R_OV:
					begin
						inc_r=LOW;
						if(!win_r_ov)
						begin
							next_state_disp=DISP_LOAD_R;
						end
						else
						begin
							next_state_disp=DISP_START;
						end
					end
					RST_R:
					begin
						rst_r=LOW;
						next_state_disp=IDLE;
					end
					INC_RW:
					begin
						if(!rw_ov)
						begin
							inc_rw=HIGH;
							next_state_disp=IDLE;
						end
						else
						begin
							next_state_disp=DONE;
						end
					end
					RST_RW:
					begin
						rst_rw=LOW;
						next_state_disp=IDLE;
					end
					
					SRAM_READ_PRE_WAIT:
					begin
						if(sram_done)
						begin
							sram_rw=HIGH;
							sram_trig<=HIGH;
							next_state_disp=SRAM_READ;
						end
					end
					SRAM_READ:
					begin
						if(sram_done)
						begin
						
						end
						else
						begin
							sram_trig<=LOW;
							next_state_disp=SRAM_READ_POST_WAIT;
						end
					end
					SRAM_READ_POST_WAIT:
					begin
						if(sram_done)
						begin
							sram_rw=HIGH;
							next_state_disp=INC_L;
							load_window=HIGH;
						end
					end
					
					SRAM_READ_R_PRE_WAIT:
					begin
						if(sram_done)
						begin
							sram_rw=HIGH;
							sram_trig<=HIGH;
							next_state_disp=SRAM_READ_R;
						end
					end
					SRAM_READ_R:
					begin
						if(sram_done)
						begin
							
						end
						else
						begin
							sram_trig<=LOW;
							next_state_disp=SRAM_READ_R_POST_WAIT;
						end
					end
					SRAM_READ_R_POST_WAIT:
					begin
						if(sram_done)
						begin
							sram_rw=HIGH;
							next_state_disp=INC_R;
							load_window=HIGH;
						end
					end
					
					SRAM_WRITE_PRE_WAIT:
					begin
						if(sram_done)
						begin
							sram_rw=LOW;
							sram_trig<=HIGH;
							next_state_disp=SRAM_WRITE;
						end
					end
					SRAM_WRITE:
					begin
						if(sram_done)
						begin
						
						end
						else
						begin
							sram_trig<=LOW;
							next_state_disp=SRAM_WRITE_POST_WAIT;
						end
					end
					SRAM_WRITE_POST_WAIT:
					begin
						if(sram_done)
						begin
							sram_rw=HIGH;
							next_state_disp=INC_ROI;
						end
					end
					DONE:
					begin
						next_state_disp=INIT;
						next_state=COMMAND;
					end
				endcase
			end
	////////////////////////////////////////////////
		endcase
	end
	
	endmodule