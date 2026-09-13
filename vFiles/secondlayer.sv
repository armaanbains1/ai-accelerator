module secondlayer(
	input CLOCK_50,
	input signed [7:0] layer_1_in [31:0],
	input start,
	output reg signed [26:0] layer_2_out [9:0],
	output reg complete = 0
);
	reg signed [7:0]  weights2 [319:0];
	reg signed [19:0] biases2 [9:0];       // Widened to 20 bits
	reg signed [26:0] answer [9:0];

	initial begin
		$readmemh("weightsSecondLayer.hex", weights2);
		$readmemh("biasesSecondLayer.hex", biases2);
	end

	integer i;
	localparam IDLE     = 2'd0;
	localparam ROW      = 2'd1;
	localparam COLUMN   = 2'd2;
	localparam COMPLETE = 2'd3;

	reg [1:0] state = IDLE; 
	reg [9:0] currPixel = 0;
	reg [5:0] currNeuron = 0;
	reg signed [26:0] sum = 0;
	
	wire [14:0] index = (currNeuron * 32) + currPixel;
	
	always @(posedge CLOCK_50) begin
		case (state) 
			IDLE: begin
				complete <= 0;
				if (start) begin
					state <= ROW; 
				end
			end
			
			ROW: begin
				if (currNeuron == 0 && currPixel == 0) begin
					state <= COLUMN;
				end
				else if (currPixel == 32) begin
					answer[currNeuron] <= sum + biases2[currNeuron]; // Sign-extends 20-bit bias to 27-bit sum
					sum <= 0;
					currPixel <= 0;
					
					if (currNeuron == 9) begin
						currNeuron <= 10;
						state <= COMPLETE;
					end else begin
						currNeuron <= currNeuron + 1'b1;
						state <= COLUMN;
					end
				end
			end
			
			COLUMN: begin
				if (currPixel == 32) begin
					state <= ROW;
				end else begin
					sum <= sum + (layer_1_in[currPixel] * weights2[index]);
					currPixel <= currPixel + 1'b1;
				end
			end
			
			COMPLETE: begin
				for (i = 0; i < 10; i = i + 1) begin
					layer_2_out[i] <= answer[i];
				end
				complete <= 1'b1;
			end
		endcase
	end
endmodule
