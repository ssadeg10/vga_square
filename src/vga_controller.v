/*
Pin Assignment for DE10-Lite:
clk_50						=> PIN_P11 or PIN_N14
btn_reset_n (button 0) 	=> PIN_B8
vga_hsync 					=> PIN_N3
vga_vsync 					=> PIN_N1
vga_r[0, 1, 2, 3] 		=> [PIN_AA1, PIN_V1, PIN_Y2, PIN_Y1]
vga_g[0, 1, 2, 3] 		=> [PIN_W1, PIN_T2, PIN_R2, PIN_R1]
vga_b[0, 1, 2, 3] 		=> [PIN_P1, PIN_T1, PIN_P4, PIN_N2]
*/

module vga_controller (
	input 	wire 	clk_50,			// 50 MHz clock
	input 	wire 	btn_reset_n,	// reset button
	output 	reg 	vga_hsync,		// horizontal sync
	output 	reg 	vga_vsync,		// vertical sync
	output 	reg 	[3:0] vga_r,	// 4 bit VGA red
	output 	reg 	[3:0] vga_g,	// 4 bit VGA green
	output 	reg 	[3:0] vga_b		// 4 bit VGA blue
	);
	
	// **** SETUP ****
	
	// generate pixel clock (25.2 MHz)
	wire clk_vga;
	pll_clock	pll_clock_inst (
		.areset (!btn_reset_n),
		.inclk0 (clk_50),
		.c0 (clk_vga)
	);
	
	// set sync signals and pixel coordinates
	wire [9:0] sx, sy;
	wire hsync, vsync, de;
	vga_sync display_inst (
		.clk_pix (clk_vga),
		.rst_pix (0),
		.sx (sx),
		.sy (sy),
		.hsync (hsync),
		.vsync (vsync),
		.de (de)
	);
	
	// **** DRAW ****
	
	// single static square
//	wire [3:0] paint_r, paint_g, paint_b;
//	vga_square # (
//		.SIZE (50),
//		.SQ_COLOR (12'hFFF), // hex triplet: RGB
//		.BG_COLOR (12'h137)
//	) draw_square (
//		.sx (sx),
//		.sy (sy),
//		.paint_r (paint_r),
//		.paint_g (paint_g),
//		.paint_b (paint_b)
//	);
	
	// single bouncing square
//	wire [3:0] paint_r, paint_g, paint_b;
//	vga_square_bounce square_1 (
//		.clk (clk_vga),
//		.sx (sx),
//		.sy (sy),
//		.paint_r (paint_r),
//		.paint_g (paint_g),
//		.paint_b (paint_b)
//	);

	// two bouncing squares with collision
	wire [3:0] paint_r1, paint_g1, paint_b1;
	wire [3:0] paint_r2, paint_g2, paint_b2;
	wire [9:0] pos1_x, pos1_y;
	wire [9:0] pos2_x, pos2_y;
	
	vga_multisquare_bounce square_1 (
		.clk (clk_vga),
		.sx (sx),
		.sy (sy),
		.osq_x (pos2_x),
		.osq_y (pos2_y),
		.paint_r (paint_r1),
		.paint_g (paint_g1),
		.paint_b (paint_b1),
		.pos_x (pos1_x),
		.pos_y (pos1_y)
	);
	
	vga_multisquare_bounce #(.START_X (200), .START_Y (400)) square_2 (
		.clk (clk_vga),
		.sx (sx),
		.sy (sy),
		.osq_x (pos1_x),
		.osq_y (pos1_y),
		.paint_r (paint_r2),
		.paint_g (paint_g2),
		.paint_b (paint_b2),
		.pos_x (pos2_x),
		.pos_y (pos2_y)
	);
	
	wire [3:0] comb_r, comb_g, comb_b;
	// overlap: white value is highest
//	assign comb_r = (paint_r1 == 4'hF && paint_r1 == paint_r2) 
//						? 4'h0 : ((paint_r1 > paint_r2) ? paint_r1 : paint_r2);
//	assign comb_g = (paint_g1 == 4'hF && paint_g1 == paint_g2) 
//						? 4'h0 : ((paint_g1 > paint_g2) ? paint_g1 : paint_g2);
//	assign comb_b = (paint_b1 == 4'hF && paint_b1 == paint_b2) 
//						? 4'h0 : ((paint_b1 > paint_b2) ? paint_b1 : paint_b2);
	assign comb_r = (paint_r1 > paint_r2) ? paint_r1 : paint_r2;
	assign comb_g = (paint_g1 > paint_g2) ? paint_g1 : paint_g2;
	assign comb_b = (paint_b1 > paint_b2) ? paint_b1 : paint_b2;
	
	//display color, display black in blanking interval
	wire [3:0] display_r, display_g, display_b;
	assign display_r = (de) ? comb_r : 4'h0;
	assign display_g = (de) ? comb_g : 4'h0;
	assign display_b = (de) ? comb_b : 4'h0;
//	assign display_r = (de) ? paint_r : 4'h0;
//	assign display_g = (de) ? paint_g : 4'h0;
//	assign display_b = (de) ? paint_b : 4'h0;
	
	// send vga output
	always @(posedge clk_vga) begin
		vga_hsync <= hsync;
		vga_vsync <= vsync;
		vga_r <= display_r;
		vga_g <= display_g;
		vga_b <= display_b;
	end
endmodule
	