module top (
    input CLOCK_50, 
	 input [0:0] SW,
    output logic [9:0] LEDR,
	 output logic [6:0] HEX2
);

    logic signed [7:0] layer1Output [31:0];
    logic signed [26:0] layer2Output [9:0] ;
    logic [3:0]         result = 0;
    
    logic firstLayerComplete = 0;
    logic secondLayerComplete = 0;
    logic argmaxComplete = 0;
	 logic [31:0] cycle_count = 0;

    firstlayer u_firstlayer (
        .CLOCK_50    (CLOCK_50),
		  .SW          (SW),
        .done        (firstLayerComplete),
        .layer_1_out (layer1Output),
		  .LEDR(LEDR[0])
    );

    secondlayer u_secondLayer (
        .CLOCK_50    (CLOCK_50),
        .start       (firstLayerComplete),
        .layer_1_in  (layer1Output),
        .layer_2_out (layer2Output),
		  .complete        (secondLayerComplete)
    );

    argmax u_argmax (
        .CLOCK_50   (CLOCK_50),
        .trigger    (secondLayerComplete),
        .layer2     (layer2Output),
        .class_out  (result)

    );

	 always_ff @(posedge CLOCK_50) begin
		 if (!SW[0]) begin
			  cycle_count <= 32'd0;
		 end else if (!secondLayerComplete) begin
			  cycle_count <= cycle_count + 1'b1;
		 end
	end
	
	
	always_comb begin
			  case (result)
					4'd0:    HEX2 = 7'b100_0000; // 0
					4'd1:    HEX2 = 7'b111_1001; // 1
					4'd2:    HEX2 = 7'b010_0100; // 2
					4'd3:    HEX2 = 7'b011_0000; // 3
					4'd4:    HEX2 = 7'b001_1001; // 4
					4'd5:    HEX2 = 7'b001_0010; // 5
					4'd6:    HEX2 = 7'b000_0010; // 6 (b segment OFF)
					4'd7:    HEX2 = 7'b111_1000; // 7
					4'd8:    HEX2 = 7'b000_0000; // 8
					4'd9:    HEX2 = 7'b001_0000; // 9
					default: HEX2 = 7'b111_1111; // All segments OFF
			  endcase
			  LEDR[9:1] = cycle_count[9:1];
		 end


endmodule