module  Gatherer(
	input clk, rst, valid_i,
	input [5:0] ID_i,
	input [2:0] SEW_i,
	input [4:0] Vd_Addr_i,
	input [127:0] mask_i,
	input [127:0] data_i,

	output reg [127:0] Vd_o, mask_o,
	output reg [5:0] ID_o,
	output reg [4:0] Vd_Addr_o,
	output reg almost_done_o, // to chaining unit
	output reg done //rename to valid_o
);
  localparam E32 = 3'b010,
             E16 = 3'b001, 
             E8 = 3'b000;

reg [2:0] cycle;
reg [127:0] Vd_o_reg;
reg [2:0] SEW_reg;

wire [2:0] SEW_used;
assign SEW_used = (cycle>0)? SEW_reg:SEW_i;


always @(posedge clk or posedge rst) begin
	if (rst) begin
		cycle <= 0;
		Vd_Addr_o <= 0;
		ID_o <= 0;
		Vd_o <= 0;
		mask_o <=0;
		done <= 0;
		SEW_reg <= 0;
		almost_done_o <= 0;
	end else begin

		if (cycle==0) begin
			SEW_reg <= SEW_i;
		end
		

		if (valid_i) begin
			case (SEW_used)
        E32: begin
        	cycle <= 0;
        end

        E16: begin 
            if (cycle < 3'd1) begin
              cycle <= cycle + 1'b1;
            end else begin
              cycle <= 0;
          end
        end

        E8:	begin	
        	 	if (cycle < 3'd3) begin
            		cycle <= cycle + 1'b1;
          		end else begin
            		cycle <= 0;
          		end
          	end

        	default : begin 
            	cycle <= 0;
        	end
    	endcase

    	case (SEW_used)
        	E32: begin
        		Vd_o <= data_i;
        		Vd_Addr_o <= Vd_Addr_i;
						ID_o <= ID_i;
						mask_o <=mask_i;
        		done <= 1;
        		almost_done_o <=  1;
        	end

        	E16: begin 
        		if (cycle==0) begin
        			Vd_o[63:0] <= {data_i[110:96], data_i[79:64], data_i[47:32], data_i[15:0]};
        			almost_done_o <= 1;
        		end else begin
        			Vd_o[127:64] <= {data_i[110:96], data_i[79:64], data_i[47:32], data_i[15:0]};
        			almost_done_o <= 0;
        		end
        		done <= 0;
        		Vd_Addr_o <= Vd_Addr_i;
						ID_o <= ID_i;
						mask_o <=mask_i;
						
						if (cycle==1) begin
							done <= 1;
						end
        	end

        	E8: begin
        				if (cycle == 0) begin
    							Vd_o[31:0]   <= {data_i[103:96], data_i[71:64], data_i[39:32], data_i[7:0]};
								end else if (cycle == 1) begin
    							Vd_o[63:32]  <= {data_i[103:96], data_i[71:64], data_i[39:32], data_i[7:0]};
								end else if (cycle == 2) begin
    							Vd_o[95:64]  <= {data_i[103:96], data_i[71:64], data_i[39:32], data_i[7:0]};
								end else if (cycle == 3) begin
    							Vd_o[127:96] <= {data_i[103:96], data_i[71:64], data_i[39:32], data_i[7:0]};
								end
        			done <= 0;
        			Vd_Addr_o <= Vd_Addr_i;
							ID_o <= ID_i;
							mask_o <=mask_i;
        		if (cycle==3) begin
							done <= 1;
							almost_done_o <=0;
        		end else if (cycle == 2) begin
        			almost_done_o <= 1;
        			done <= 0;
        		end else begin
        			almost_done_o <=0;
        			done <=0;
        		end
        end

        	default: begin
        		done <= 0;
        	end
        endcase
    end else begin
    	done <= 0;
    end

  end
end


endmodule



