module secondlayer(
	input CLOCK_50,
	input reg [7:0] layer_1_in [31:0],
	input reg start,
	output reg signed [26:0] layer_2_out [9:0],
	output reg complete = 0
	);
	
	reg signed [7:0] inputImage [783:0];
	reg signed [26:0] result [9:0];

	reg signed [7:0] weights2 [319:0];
	reg signed [7:0] biases2 [9:0];

initial begin
    $readmemh("weightsSecondLayer.hex", weights2);
    $readmemh("biasesSecondLayer.hex", biases2);

    // Print first & last elements to verify hex parsing and sign extension
    $display("--- Memory Initialization Check ---");
    $display("weights2[0]   = %0h (signed dec: %0d)", weights2[0], weights2[0]);
    $display("weights2[319] = %0h (signed dec: %0d)", weights2[319], weights2[319]);
    $display("biases2[0]    = %0h (signed dec: %0d)", biases2[0], biases2[0]);
    $display("biases2[9]    = %0h (signed dec: %0d)", biases2[9], biases2[9]);
end

	integer i;

	reg activation = 0;
	localparam IDLE = 2'd0;
	localparam ROW = 2'd1;
	localparam COLUMN = 2'd2;
	localparam COMPLETE = 2'd3;
	reg [1:0] state = IDLE; 
	reg [1:0] nextState; 
	//columns represnt pixels
	reg [9:0] currPixel = 0;
	//rows represent neurons
	reg [5:0] currNeuron = 0;

	reg signed [26:0] answer [9:0];
	reg signed [26:0] sum;
	reg signed [26:0] tempMultiplication;
	
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
				if (currNeuron == 0 && currPixel == 0)begin
					state<=COLUMN;
				end

				else if (currPixel == 32) begin
					answer[currNeuron] <= sum + biases2[currNeuron];
					sum <= 0;
					tempMultiplication <= 0;
					currPixel <= 0;
					
					if (currNeuron == 9) begin
						currNeuron <= 10;
						state <= COMPLETE;
					end
					else begin
						currNeuron <= currNeuron + 1;
						state<=COLUMN;
					end
					
				end

				
			end
			
			COLUMN: begin
				if (currPixel == 32) begin
					state <= ROW;
				end
				else begin
					sum <= sum + (layer_1_in[currPixel] * weights2[index]);
					currPixel <= currPixel + 1;
				end
				
			end
			
			COMPLETE: begin
				layer_2_out <= answer;
				complete <= 1;
			end
		
		
		endcase
	end
	

	
	
endmodule