module vga_square #(
	parameter SIZE = 100,
	parameter [11:0] SQ_COLOR = 12'hFFF, // hex triplet RGB, each value specifies intensity
	parameter [11:0] BG_COLOR = 12'h137
)
(
	input wire [9:0] sx,
	input wire [9:0] sy,
	output wire [3:0] paint_r,
	output wire [3:0] paint_g,
	output wire [3:0] paint_b
);
	localparam CENTER_X = 320, CENTER_Y = 240;
	
	// define square within coordinates
	wire square;
	assign square = (sx > (CENTER_X - SIZE) && sx < (CENTER_X + SIZE)) 
						&& (sy > (CENTER_Y - SIZE) && sy < (CENTER_Y + SIZE));
	
	assign paint_r = (square) ? SQ_COLOR[11:8] : BG_COLOR[11:8];
	assign paint_g = (square) ? SQ_COLOR[7:4] : BG_COLOR[7:4];
	assign paint_b = (square) ? SQ_COLOR[3:0] : BG_COLOR[3:0];

endmodule