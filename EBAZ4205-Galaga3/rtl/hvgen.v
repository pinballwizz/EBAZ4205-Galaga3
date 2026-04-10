// Copyright (c) 2019 MiSTer-X

module hvgen
(
	output  [8:0]		HPOS,
	output  [8:0]		VPOS,
	input 				PCLK,

	output reg			HBLK = 1,
	output reg			VBLK = 1,
	output reg			HSYN = 1,
	output reg			VSYN = 1
);


reg [8:0] hcnt = 0;
reg [8:0] vcnt = 0;

assign HPOS = hcnt;
assign VPOS = vcnt;

always @(posedge PCLK) begin
	case (hcnt)
		  0: begin HBLK <= 0; hcnt <= hcnt+1; end
		289: begin HBLK <= 1; hcnt <= hcnt+1; end
		311: begin HSYN <= 0; hcnt <= hcnt+1; end
		342: begin HSYN <= 1; hcnt <= 471;    end
		511: begin hcnt <= 0;
			case (vcnt)
				223: begin VBLK <= 1; vcnt <= vcnt+1; end
				235: begin VSYN <= 0; vcnt <= vcnt+1; end
				242: begin VSYN <= 1; vcnt <= 492;	  end
				511: begin VBLK <= 0; vcnt <= 0;		  end
				default: vcnt <= vcnt+1;
			endcase
		end
		default: hcnt <= hcnt+1;
	endcase

end

endmodule