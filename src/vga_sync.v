module vga_sync (
	input		wire	clk_pix,	// pixel clock (25.2 MHz)
	input 	wire 	rst_pix,		// reset pixel clock
	output 	reg 	[9:0] sx,	// screen horizontal position
	output 	reg 	[9:0] sy,	// screen vertical position
	output 	wire 	hsync,		// horizontal sync
	output 	wire 	vsync,		// vertical sync
	output 	wire 	de				// data enable (low in blanking interval)
	);

   // horizontal timings
   parameter HA_END = 639;           // end of active pixels
   parameter HS_STA = HA_END + 16;   // sync starts after front porch
   parameter HS_END = HS_STA + 96;   // sync ends
   parameter LINE   = 799;           // last pixel on line (after back porch)

   // vertical timings
   parameter VA_END = 479;           // end of active pixels
   parameter VS_STA = VA_END + 10;   // sync starts after front porch
   parameter VS_END = VS_STA + 2;    // sync ends
   parameter SCREEN = 524;           // last line on screen (after back porch)

   assign hsync = ~(sx >= HS_STA && sx < HS_END);  // invert: negative polarity
   assign vsync = ~(sy >= VS_STA && sy < VS_END);  // invert: negative polarity
   assign de = (sx <= HA_END && sy <= VA_END);

   // calculate horizontal and vertical screen position
   always @(posedge clk_pix) begin
       if (sx == LINE) begin  // last pixel on line?
           sx <= 0;
			  if (sy == SCREEN) begin // last line on screen?
			     sy <= 0;
			  end else begin
			     sy <= sy + 1;
			  end
       end else begin
           sx <= sx + 1;
       end
       if (rst_pix) begin
           sx <= 0;
           sy <= 0;
       end
   end
endmodule