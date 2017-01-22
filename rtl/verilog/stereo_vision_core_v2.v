module stereo_vision_core_v2

	(
		input wire clk_in,
		input wire rst_in,
		input wire RxD,
		output wire TxD,
		output wire sram_ce_n_out,
		output wire sram_oe_n_out,
		output wire sram_we_n_out,
		output wire sram_ub_n_out,
		output wire sram_lb_n_out,
		output wire [17:0]sram_address_out,
		inout wire [15:0]sram_dq_out,
		output wire [7:0]debug,
		output wire [7:0] debug2
	
	);
wire [7:0]		rx_data,rd_data_bus,wr_data_bus,disparity;
wire [18:0]		addr_roi_x,addr_roi_y,
					addr_l_x,addr_l_y,
					addr_r_x,addr_r_y,
					addr_rw_x,addr_rw_y,
					addr_x,addr_y,
					buff_l_x,buff_l_y,
					buff_r_x,buff_r_y,
					sram_address;
wire [1:0]		mem_bank_sel,addr_sel,wr_data_sel,disp_mode;					
wire 				tx_trig,sram_trig,
					sram_rw,
					rst_rw,
					rst_l,rst_r,rst_roi,
					rst_disp,
					inc_l,inc_r,inc_roi,
					inc_rw,
					
					rw_ov,roi_ov,win_l_ov,win_r_ov,
					disp_done,sram_done,tx_done,
					rx_drdy;
wire				clk_sys,clk_disp,clk_uart;
reg				clk_half,clk_h;

	wire [7:0] tx_data;
	wire [1:0] tx_data_sel;

			
	always@(posedge clk_in,negedge rst_in)
	begin
		if(!rst_in)
		begin
			clk_h<=1'b0;
		end
		else
		begin
			clk_h<=!clk_h;
		end
	end
					
	always@(posedge clk_h,negedge rst_in)
	begin
		if(!rst_in)
		begin
			clk_half<=1'b0;
		end
		else
		begin
			clk_half<=!clk_half;
		end
	end
			
assign debug2[0] = sram_trig;
assign debug2[1] = sram_done;

assign clk_sys = clk_half;
assign clk_uart = clk_half;
assign clk_disp = clk_half; 

control_unit cu0
	(
		.clk_in				(clk_in),
		.rst_in				(rst_in),
		
		.cmd_in				(rx_data),
		
		.tx_trig				(tx_trig),
		.sram_trig			(sram_trig),
		
		.sram_rw				(sram_rw),
		.disp_mode			(disp_mode),
		.load_window		(load_window),
		.mem_bank_sel		(mem_bank_sel),
		.addr_sel			(addr_sel),
		.wr_data_sel		(wr_data_sel),
		.tx_data_sel		(tx_data_sel),
		
		.rst_rw				(rst_rw),
		.rst_l				(rst_l),
		.rst_r				(rst_r),
		.rst_roi				(rst_roi),
		.rst_disp			(rst_disp),
		
		.inc_rw				(inc_rw),
		.inc_l				(inc_l),
		.inc_r				(inc_r),
		.inc_roi				(inc_roi),
		
		.rw_ov      		(rw_ov), 
		.roi_ov				(roi_ov),
		.win_l_ov			(win_l_ov),
		.win_r_ov			(win_r_ov),
		
		.disp_done			(disp_done),
		.sram_done			(sram_done),
		.tx_done				(tx_done),
		.rx_drdy				(rx_drdy),
		
		.debug				(debug),
		.debug2				(gy)
	);
	
	
 address_gen_rw addr0
	(
		.clk_in			(clk_sys),
		.rst_in			(rst_rw),
		.inc_in			(inc_rw),
		.x_index_out	(addr_rw_x),
		.y_index_out	(addr_rw_y),
		.ov_out			(rw_ov)
	);
	
address_generator addgen0
  (
    .clk_in				(clk_sys),
    
    .rst_roi_in		(rst_roi),
    .rst_5x5_in		(rst_l),
    .rst_68x5_in		(rst_r),
    
    .inc_roi_in		(inc_roi),
    .inc_5x5_in		(inc_l),
    .inc_68x5_in		(inc_r),
    
    .ram_5x5_x_out	(addr_l_x),
    .ram_5x5_y_out	(addr_l_y),
    .win_5x5_x_out	(buff_l_x),
    .win_5x5_y_out	(buff_l_y),
    
    .ram_68x5_x_out	(addr_r_x),
    .ram_68x5_y_out	(addr_r_y),
    .win_68x5_x_out	(buff_r_x),
    .win_68x5_y_out	(buff_r_y),
    
    .roi_x_out			(addr_roi_x),
    .roi_y_out			(addr_roi_y),
    
    .roi_line_ov_out	(),
    .roi_ov_out		(roi_ov),
    .win_5x5_ov_out	(win_l_ov),
    .win_68x5_ov_out	(win_r_ov)
  );

   
disparity_core disp_core
    (
      .clk_in					(clk_sys),
      .rst_in					(rst_disp),
		.load_in					(load_window),
      .mode_in					(disp_mode),
      .roi_x_in				(addr_roi_x),
      .roi_y_in				(addr_roi_y),
		.win_5x5_x_index_in	(buff_l_x),
		.win_5x5_y_index_in	(buff_l_y),
		.win_68x5_x_index_in	(buff_r_x),
		.win_68x5_y_index_in	(buff_r_y),
		.pix_in					(rd_data_bus),
      .disparity_out			(disparity),
      .disp_done_out			(disp_done)
    );
    
    
mux	address_mux0
	(
		.x0_in			(addr_rw_x),
		.x1_in			(addr_l_x),
		.x2_in			(addr_r_x),
		.x3_in			(addr_roi_x),
		
		.y0_in			(addr_rw_y),
		.y1_in			(addr_l_y),
		.y2_in			(addr_r_y),
		.y3_in			(addr_roi_y),
		
		.sel_in			(addr_sel),
		
		.x_out			(addr_x),
		.y_out			(addr_y)
	);
 
 
address_map map0
	(
		.sel_in			(mem_bank_sel),
		.col_index_in	(addr_x),
		.row_index_in	(addr_y),
		.address_out	(sram_address)
	);
mux8b wr_bus_mux
	(
		.a_in				(rx_data),
		.b_in				(disparity),
		.c_in				(),
		.d_in				(),
		.sel_in			(wr_data_sel),
		.x_out			(wr_data_bus)
	
	);
sramctrl ram0 (
	.clk			(clk_sys),
	.reset_n			(rst_in),
	.start_n			(sram_trig),
	.rw			(sram_rw),
	.addr_in			(sram_address),
	.data_write		(wr_data_bus),
	.data_read		(rd_data_bus),
	.ready		(sram_done),
	.ce_a_n		(sram_ce_n_out),
	.oe_n		(sram_oe_n_out),
	.we_n		(sram_we_n_out),
	.lb_a_n		(sram_lb_n_out),
	.ub_a_n		(sram_ub_n_out),
	.sram_addr		(sram_address_out),
	.data_io			(sram_dq_out)
	);	

		
mux8b tx_mux
	(
		.a_in				(rd_data_bus),
		.b_in				(disparity),
		.c_in				(),
		.d_in				(),
		.sel_in			(tx_data_sel),
		.x_out			(tx_data)
	
	);
	
async_transmitter uart_tx(
	.clk				(clk_uart),
	.TxD_start		(tx_trig),
	.TxD_data		(tx_data),
	.TxD				(TxD),
	.TxD_busy		(tx_done)
);

 async_receiver uart_rx(
	.clk					(clk_uart),
	.RxD					(RxD),
	.RxD_data_ready	(rx_drdy),
	.RxD_data			(rx_data),
	.RxD_idle			(),
	.RxD_endofpacket	()
);
	
	
endmodule