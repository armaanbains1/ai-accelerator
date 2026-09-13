module firstlayer(
	input CLOCK_50,
	input SW[0:0],
	output reg [7:0] layer_1_out [31:0],
	output reg [9:0] LEDR,
	output reg done = 0
	);
	reg signed [7:0] inputImage [783:0];
	reg signed [26:0] result [31:0];
	reg signed [7:0] weights1 [25087:0];
	reg signed [7:0] biases1 [31:0];
	reg  [26:0] relu_out [31:0];
	reg layer1done = 0;
	(* keep *) reg [287:0] layer_1_debug;
	initial begin

		$readmemh("weightsFirstLayer.hex", weights1);
		$readmemh("biasesFirstLayer.hex", biases1);
		$readmemh("digit_9.hex", inputImage);

	end
	
	integer i;

	reg activation = 0;
	localparam IDLE = 3'd0;
	localparam ROW = 3'd1;
	localparam COLUMN = 3'd2;
	localparam COMPLETE = 3'd3;
	localparam RELU = 3'd4;
	localparam QUANTIZATION = 3'd5;

	reg [2:0] state = IDLE; 
	reg [1:0] nextState; 

	//columns represnt pixels
	reg [9:0] currPixel = 0;
	//rows represent neurons
	wire start;
	assign start = SW[0];
	reg [5:0] currNeuron = 0;

	reg signed [26:0] answer [31:0];
	reg signed [26:0] sum;
	reg signed [26:0] tempMultiplication;
	
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
					  answer[currNeuron] <= sum + biases1[currNeuron];
					  sum <= 0;
					  tempMultiplication <= 0;
					  currPixel <= 0;

					  if (currNeuron == 31) begin
							currNeuron <= 32;
							state      <= RELU;
					  end else begin
							currNeuron <= currNeuron + 1;
							state      <= COLUMN;
					  end
				 end
			end
			
			COLUMN: begin
				if (currPixel == 784) begin
					state <= ROW;
				end
				else begin

					sum <= sum + (inputImage[currPixel] * weights1[index]);
					currPixel <= currPixel + 1;
				end
				
	
				
			end
			
			RELU: begin
				result <= answer;
				for (i = 0; i<32; i = i+1) begin
					if (answer[i][26] == 1'b1) begin
						relu_out[i] <= 0;
					end
					else begin
						relu_out[i] = answer[i];
					end
				end
				state <= QUANTIZATION;
			end
			
			QUANTIZATION: begin
			
			  for (i = 0; i < 32; i = i + 1) begin
					layer_1_out[i] <= (64'd1462 * relu_out[i])  >> 20;
			  end
			  
			  state <= COMPLETE;
			end
			
			COMPLETE: begin
				done <= 1;
			
			end
		
		endcase
	end
	
	// ReLU Actication layer
	// ReLU(z) = max(0,z)
	// We are essentially just going to be converted the 32 raw outputs into either 0 or, keeping them the same, depending if they are negative or now.
	// This acts as a zero filter
	/*
	always @(posedge CLOCK_50) begin
		if (activation) begin
			for (i = 0; i<32; i = i+1) begin
				if (answer[i][26] == 1'b1) begin
					relu_out[i] <= 0;
				end
				else begin
					relu_out[i] = answer[i];
				end
			end
		end
		
	end
	
	always @(posedge CLOCK_50) begin
		layer1done <= activation;
	end
	
	// Hardware Quantization
	
(* keep *) reg [7:0] test_neuron_5;
(* keep *) reg [7:0] test_neuron_24;
(* keep *) reg [7:0] test_neuron_31;

always @(posedge CLOCK_50) begin
	 if (layer1done == 1 && done == 0) begin
        for (i = 0; i < 32; i = i + 1) begin
            layer_1_out[i] <= relu_out[i];
        end
        test_neuron_5  <= (64'd1462 * relu_out[5])  >> 20;
        test_neuron_24 <= (64'd1462 * relu_out[24]) >> 20;
        test_neuron_31 <= (64'd1462 * relu_out[31]) >> 20;

        // Drive the physical outputs inside the single-execution block
        LEDR[8:0] <= (64'd1462 * relu_out[31]) >> 20;
        LEDR[9]   <= 1'b1; // Turn on LED9 to visually confirm execution completed
        done      <= 1'b1;
    end
	 if (done == 1) begin
		LEDR[9] <= 1'b1;
	 end
end
*/
	
	
endmodule