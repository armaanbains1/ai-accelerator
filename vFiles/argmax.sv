module argmax(
	input CLOCK_50, 
	input signed [26:0] layer2 [9:0], 
	input trigger, 
	output reg [3:0] class_out
);
	reg [3:0] maxNum;
	reg signed [26:0] maxVal;
	integer i;

	always @(posedge CLOCK_50) begin
		if (trigger) begin
			maxNum = 4'd0;
			maxVal = layer2[0];
			for (i = 1; i < 10; i = i + 1) begin
				if (layer2[i] > maxVal) begin
					maxNum = i[3:0];
					maxVal = layer2[i];
				end
			end
			class_out <= maxNum;
		end
	end
endmodule
