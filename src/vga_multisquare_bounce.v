module vga_multisquare_bounce #(
	parameter [9:0] START_X = 0,
	parameter [9:0] START_Y = 0
)(
	input wire clk,
	input wire [9:0] sx,
	input wire [9:0] sy,
	input wire [9:0] osq_x, // other square pos
	input wire [9:0] osq_y,
	output wire [3:0] paint_r,
	output wire [3:0] paint_g,
	output wire [3:0] paint_b,
	output wire [9:0] pos_x, // this square pos
	output wire [9:0] pos_y
);
	
	localparam H_SIZE = 640, V_SIZE = 480;
	
	wire new_frame; // signal start of vertical blanking
	assign new_frame = (sy == V_SIZE) && (sx == 0);
	
	// define counter
	localparam FRAMES = 1; // update position every N frames
	reg [$clog2(FRAMES):0] counter; // clog2 returns min bits that can store decimal val
	always @(posedge clk) begin
		if (new_frame) begin
			counter <= (counter == FRAMES - 1) ? 0 : counter + 1;
		end
	end
	
	// define square params
	localparam SQ_SIZE = 100;
	reg [9:0] sq_x = START_X, sq_y = START_Y;	// square origin - deafult (0, 0) top left
	reg dir_x, dir_y;		// directions, default zero for positive direction
	reg [9:0] speed = 2;		// speed in pixels/frame
	
	localparam BUFFER = 4;
	
	wire bound_v, bound_h;
	assign bound_v = (sq_y <= osq_y + SQ_SIZE 
						&& sq_y > osq_y) 
						|| (sq_y + SQ_SIZE <= osq_y + SQ_SIZE 
						&& sq_y + SQ_SIZE > osq_y);
						
	assign bound_h = (sq_x <= osq_x + SQ_SIZE 
						&& sq_x > osq_x) 
						|| (sq_x + SQ_SIZE <= osq_x + SQ_SIZE 
						&& sq_x + SQ_SIZE > osq_x);
	
	// update square position
	always @(posedge clk) begin
		if (new_frame && counter == 0) begin // counter at zero signals update square pos
			// horizontal pos
			if (dir_x == 0) begin // moving right
				if (sq_x + SQ_SIZE + speed >= H_SIZE - 1) begin // hitting right edge
					sq_x <= H_SIZE - SQ_SIZE - 1; // position square at edge
					dir_x <= 1; // begin moving left
				end
				else if (sq_x + SQ_SIZE + speed >= osq_x // if hitting left edge of other square
						&& sq_x + SQ_SIZE + speed < osq_x + BUFFER
						&& bound_v) 
				begin
					sq_x <= osq_x - SQ_SIZE;
					dir_x <= 1;
				end
				else sq_x <= sq_x + speed; // continue moving right
			end
			else begin // moving left
				if (sq_x < speed) begin // hitting left edge
					sq_x <= 0; // position square at edge
					dir_x <= 0; // begin moving right
				end
				else if (sq_x - speed <= osq_x + SQ_SIZE // if hitting right edge of other square
						&& sq_x - speed > osq_x + BUFFER
						&& bound_v) 
				begin
					sq_x <= osq_x + SQ_SIZE;
					dir_x <= 0;
				end
				else sq_x <= sq_x - speed; // continue moving left;
			end
			
			// vertical pos
			if (dir_y == 0) begin // moving down
				if (sq_y + SQ_SIZE + speed >= V_SIZE - 1) begin // hitting bottom edge
					sq_y <= V_SIZE - SQ_SIZE - 1; // position square at bottom
					dir_y <= 1; // begin moving up
				end
				else if (sq_y + SQ_SIZE + speed >= osq_y // if hitting top edge of other square
						&& sq_y + SQ_SIZE + speed < osq_y + BUFFER
						&& bound_h) 
				begin
					sq_y <= osq_y - SQ_SIZE;
					dir_y <= 1;
				end
				else sq_y <= sq_y + speed; // continue moving down
			end
			else begin // moving up
				if (sq_y < speed) begin // hitting top edge
					sq_y <= 0; // position square at top
					dir_y <= 0; // begin moving down
				end
				else if (sq_y - speed <= osq_y + SQ_SIZE // if hitting bottom edge of other square
						&& sq_y - speed > osq_y + BUFFER
						&& bound_h) 
				begin
					sq_y <= osq_y + SQ_SIZE;
					dir_y <= 0;
				end
				else sq_y <= sq_y - speed; // continue moving up;
			end
		end
	end
	
	// define square from coords
	wire square;
	assign square = (sx >= sq_x) && (sx <= sq_x + SQ_SIZE)
					&& (sy >= sq_y) && (sy <= sq_y + SQ_SIZE);
	
	assign paint_r = (square) ? 4'hF : 4'h1;
	assign paint_g = (square) ? 4'hF : 4'h3;
	assign paint_b = (square) ? 4'hF : 4'h7;
	
	assign pos_x = sq_x;
	assign pos_y = sq_y;
	
endmodule
	