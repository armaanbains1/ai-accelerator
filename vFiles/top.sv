module top (
    input  wire CLOCK_50, 
	 input SW[0:0],
    output reg  [9:0] LEDR,
	 output reg [6:0] HEX2
);

    reg [7:0]         layer1Output [31:0] ;
    reg signed [26:0] layer2Output [9:0] ;
    reg [3:0]         result = 0;
    
    reg firstLayerComplete = 0;
    reg secondLayerComplete = 0;
    reg argmaxComplete = 0;
	 reg [31:0] cycle_count = 0;

    firstlayer u_firstlayer (
        .CLOCK_50    (CLOCK_50),
		  .SW				(SW[0:0]),
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

	 always @(posedge CLOCK_50 or negedge SW[0]) begin
		 if (!SW[0]) begin
			  cycle_count <= 32'd0;
		 end else if (!secondLayerComplete) begin
			  cycle_count <= cycle_count + 1'b1;
		 end
	end
	
	
	always @(*) begin
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
			  LEDR[9:1] <= cycle_count[9:1];
		 end


endmodule