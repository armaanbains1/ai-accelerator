`timescale 1ns/1ps

module layer2_tb();

	logic clk_50_tb;
	logic signed [7:0] layer_1_in_tb [31:0]= '{
		
			8'h00, 8'h00,
			8'h00, 8'h00, 8'h00, 8'h04, 8'h18, 8'h09,
			8'h10, 8'h00, 8'h05, 8'h00, 8'h08,8'h00,
			8'h00, 8'h00, 8'h0d, 8'h06, 8'h00, 8'h1a,
			8'h03, 8'h1b, 8'h00, 8'h00, 8'h0b, 8'h1d,
			8'h04, 8'h01, 8'h12, 8'h1a, 8'h01, 8'h03
		
		};
		
	logic start_tb;
	logic signed [26:0] layer_2_out_tb [9:0];
		
	logic complete_tb;
	

	
	
	initial clk_50_tb = 0;
	always #10 clk_50_tb = ~clk_50_tb;
	
	initial start_tb = 0;
	initial complete_tb = 0;
	
	secondlayer layer2(.CLOCK_50(clk_50_tb), .layer_1_in(layer_1_in_tb), .start(start_tb), .layer_2_out(layer_2_out_tb), .complete(complete_tb));

	
	initial begin
	

		
		
		#20;
		
		@(posedge clk_50_tb)
		
		start_tb = 1;
		
		@(posedge complete_tb)
		
		#2000;
		
		for (int i = 0; i <= 9; i=i+1) begin
			
			$display("The output for layer %d is equal to %d", i, layer_2_out_tb[9-i]);
			
			
		end
		
		#10;
		
		$end;
		
	end


endmodule
