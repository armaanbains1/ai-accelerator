`timescale 1ns/1ps

module layer1_tb();
	
	logic CLOCK_50_tb = 0;
	
	logic SW_tb = 0;
	
	logic signed [7:0] layer_1_out_tb [31:0];
	logic signed [26:0] expectedAnswers [31:0];
	logic signed [26:0] expectedReluOut [31:0];
	logic signed [8:0] expectedLayer1Out [31:0];

	logic [9:0] LEDR_tb;
	
	logic done_tb = 0;

	logic signed [7:0]  expectedInputImage [0:9] = '{
        8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
    };

    logic signed [7:0]  expectedWeights [0:9] = '{
        8'h03, 8'h01, 8'h03, 8'h01, 8'h01, 8'h01, 8'h03, 8'h02, 8'h01, 8'h00
    };

    logic signed [19:0] expectedBiases [0:9] = '{
        20'hFFFBD, 20'hFFF81, 20'hFFEF4, 20'hFFF59, 20'hFFF49, 20'h0002C, 20'hFFF73, 20'hFFE8D, 20'hFFEE3, 20'hFFF2E
    };


	
	firstlayer layer1(.CLOCK_50(CLOCK_50_tb), .SW(SW_tb), .layer_1_out(layer_1_out_tb), .done(done_tb));

	always #10 CLOCK_50_tb = ~CLOCK_50_tb;

	
	initial begin
	
		$readmemh("expectedLayer1Out.hex", expectedLayer1Out);
		$readmemh("expectedRelu.hex", expectedReluOut);
		$readmemh("expectedAnswers.hex", expectedAnswers);

		#40
		
		/*
]				
			logic signed [7:0]  inputImage [783:0];
			logic signed [7:0]  weights1 [25087:0];
			logic signed [19:0] biases1 [31:0];     
			
		*/
		
		for (int i = 0; i<=9; i = i+1) begin
		
			if (layer1.inputImage[i] == expectedInputImage[i]) begin
				$display("Image loaded in pixel %d correctly", i);
			end
			else begin
				$display("Error with image loading pixel %d", i);
			end
		
		end
		
		for (int i = 0; i<=9; i = i+1) begin
		
			if (layer1.weights1[i] == expectedWeights[i]) begin
				$display("Image loaded in weight %d correctly", i);
			end
			else begin
				$display("Error with loaded in weight %d", i);
			end
		
		end
		
		for (int i = 0; i<=9; i = i+1) begin
		
			if (layer1.biases1[i] == expectedBiases[i]) begin
				$display("Image loaded in bias %d correctly", i);
			end
			else begin
				$display("Error with loaded in bias %d", i);
			end
		
		end
		
		
		#50
		
		SW_tb = 1;
		#500
		
		@(posedge done_tb);
		
		$display("First layer done");
		
		for (int i = 0; i<=31; i=i+1) begin
			$display("Answer(sum): Nueuron Value %d, received %d, expected %d", i, layer1.answer[i], expectedAnswers[i]);
			if (layer1.answer[i] == expectedAnswers[i]) begin
				$display("Correct");
			end
			else begin
				$display("Incorrect");

			end
		end
		
		for (int i = 0; i<=31; i=i+1) begin
			$display("Relu: Nueuron Value %d, received %d, expected %d", i, layer1.relu_out[i], expectedReluOut[i]);
			if (layer1.relu_out[i] == expectedReluOut[i]) begin
				$display("Correct");
			end
			else begin
				$display("Incorrect");

			end
		end
		
				
		for (int i = 0; i<=31; i=i+1) begin
			$display("Layer1Output: Nueuron Value %d, received %d, expected %d", i, layer1.layer_1_out[i], expectedLayer1Out[i]);
			if (layer1.layer_1_out[i] == expectedLayer1Out[i]) begin
				$display("Correct");
			end
			else begin
				$display("Incorrect");

			end
		end
		
		

		
		#50
		for (int i = 0; i<=31; i=i+1) begin
			$display("Nueuron Value %d, received %d", i, layer1.answer[i]);

		end
		for (int i = 0; i<=31; i=i+1) begin
			$display("Nueuron Value %d, received %d", i, layer1.layer_1_out[i]);

		end
		#50
		$finish;
		

	end

endmodule
