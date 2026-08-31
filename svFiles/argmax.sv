module argmax(
input CLOCK_50, 
input signed [27:0] layer2 [9:0], 
input trigger, 
output reg [3:0] class_out
);
	
	reg [3:0] maxNum;
	reg signed [27:0] maxVal;
	int i;
	always @(posedge CLOCK_50) begin
		if (trigger) begin
				maxNum = 4'd0;
				maxVal = layer2[0];
				for (i = 0; i <= 9; i = i + 1) begin
					if (layer2[i] > maxVal) begin
						maxNum = i;
						maxVal = layer2[i];
					end
				end
				class_out <= maxNum;
		end
	end
	
endmodule