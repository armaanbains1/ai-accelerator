module firstlayer(
	input CLOCK_50,
	input [0:0] SW,
	output reg signed [7:0] layer_1_out [31:0],
	output reg [9:0] LEDR,
	output reg done = 0
);
	reg signed [7:0]  inputImage [783:0];
	reg signed [7:0]  weights1 [25087:0];
	reg signed [19:0] biases1 [31:0];      // Widened to 20 bits
	reg signed [26:0] answer [31:0];
	reg signed [26:0] relu_out [31:0];

	initial begin
		$readmemh("weightsFirstLayer.hex", weights1);
		$readmemh("biasesFirstLayer.hex", biases1);
		$readmemh("digit_8.hex", inputImage);
	end
	
	integer i;
	localparam IDLE         = 3'd0;
	localparam ROW          = 3'd1;
	localparam COLUMN       = 3'd2;
	localparam COMPLETE     = 3'd3;
	localparam RELU         = 3'd4;
	localparam QUANTIZATION = 3'd5;

	reg [2:0] state = IDLE; 
	reg [9:0] currPixel = 0;
	reg [5:0] currNeuron = 0;
	reg signed [26:0] sum = 0;
	
	wire start = SW[0];
	wire [14:0] index = (currNeuron * 784) + currPixel;

	always @(posedge CLOCK_50) begin
		case (state) 
			IDLE: begin
				done <= 0;
				if (start) begin
					state <= ROW; 
				end
			end
			
			ROW: begin
				if (currNeuron == 0 && currPixel == 0) begin
					state <= COLUMN;
				end
				else if (currPixel == 784) begin
					answer[currNeuron] <= sum + biases1[currNeuron]; // Sign-extends 20-bit bias to 27-bit sum
					sum <= 0;
					currPixel <= 0;

					if (currNeuron == 31) begin
						currNeuron <= 32;
						state      <= RELU;
					end else begin
						currNeuron <= currNeuron + 1'b1;
						state      <= COLUMN;
					end
				end
			end
			
			COLUMN: begin
				if (currPixel == 784) begin
					state <= ROW;
				end else begin
					sum <= sum + (inputImage[currPixel] * weights1[index]);
					currPixel <= currPixel + 1'b1;
				end
			end
			
			RELU: begin
				for (i = 0; i < 32; i = i + 1) begin
					if (answer[i][26] == 1'b1) begin
						relu_out[i] <= 27'sd0;
					end else begin
						relu_out[i] <= answer[i];
					end
				end
				state <= QUANTIZATION;
			end
			
			QUANTIZATION: begin
				for (i = 0; i < 32; i = i + 1) begin
					if (((relu_out[i] * 40'sd1462) >>> 20) > 40'sd127)
						layer_1_out[i] <= 8'sd127;
					else if (((relu_out[i] * 40'sd1462) >>> 20) < -40'sd128)
						layer_1_out[i] <= -8'sd128;
					else
						layer_1_out[i] <= ((relu_out[i] * 40'sd1462) >>> 20);
				end
				state <= COMPLETE;
			end
			
			COMPLETE: begin
				done <= 1'b1;
				LEDR[0] <= 1'b1;
			end
		endcase
	end
endmodule
