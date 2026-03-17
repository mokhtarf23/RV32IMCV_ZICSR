module Reservation_Station_ALU #(parameter RS=1)
  (
  input wire clk,
  input wire rst,
  input wire valid_i,
  input wire [127:0] Vs1_i, Vs2_i, mask_i, 
  input wire [31:0] Imm_i,     
  input wire [5:0] ID_i,   
  input wire [2:0] SEW_i,  
  input wire [2:0] reservation_station_en_i, 
  input wire [6:0] opcode_i,
  input wire [2:0] funct3_i,
  input wire [5:0] funct6_i,
  input wire [4:0] Vd_Addr_i,
  input wire valid1_i, valid2_i,      

  input [31:0] Rs1_i,Rs2_i,
  input [2:0] mem_width_i,
  input [31:0] vector_length_i,
  input vm_i,
  input vma_i,
  input [1:0] mop_i,

  output reg [2:0] mem_width_o,
  output reg [31:0] vector_length_o,
  output reg vm_o,
  output reg vma_o,
  output reg [1:0] mop_o,
  output reg [31:0] Rs1_o,Rs2_o,
  output reg [31:0] Imm_o,

  output reg [31:0] data1_o [3:0],
  output reg [31:0] data2_o [3:0],
  output reg [5:0] ID_o,
  output reg [2:0] SEW_o,
  output reg [6:0] opcode_o,
  output reg [2:0] funct3_o,
  output reg [5:0] funct6_o,
  output reg [4:0] Vd_Addr_o,
  output reg full,
  output reg valid_o,
  output reg done //hatroo7 lel chaining 3ashan te3arafo eno 5alas el chain el howa ba3etha we yeb3at el ba3do
);

  localparam E32 = 3'b010,
             E16 = 3'b001, 
             E8 = 3'b000;

  reg [127:0] Vs1_1, Vs2_1, mask_1, Vs1_2, Vs2_2, mask_2;
  reg [31:0] Imm_1, Imm_2;
  reg [4:0] ID_1,ID_2;
  reg [2:0] SEW_1,SEW_2;
  reg [6:0] opcode_1,opcode_2;
  reg [2:0] funct3_1,funct3_2;
  reg [5:0] funct6_1,funct6_2;
  reg [4:0] Vd_Addr_1,Vd_Addr_2;
  reg valid1_1, valid2_1, valid1_2, valid2_2;

  reg [2:0] mem_width_1,mem_width_2;
  reg [31:0] vector_length_1, vector_length_2;
  reg vm_1,vm_2;
  reg vma_1,vma_2;
  reg [1:0] mop_1,mop_2;
  reg [31:0] Rs1_1, Rs1_2, Rs2_1, Rs2_2;

  reg [1:0] occupied;
  reg [2:0] cycle;


  reg [2:0] reservation_station_reg;
  reg [2:0] SEW_used;
 

  always @(*) begin
    case (occupied)
      2'b00: SEW_used = SEW_i;
      default: SEW_used = SEW_1;
    endcase
  end
  

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      Vs1_1 <= 0;
      Vs2_1 <= 0;
      mask_1 <= 0;
      Imm_1 <= 0;
      ID_1 <= 0;
      SEW_1 <= 0;
      opcode_1 <= 0;
      funct3_1 <= 0;
      funct6_1 <= 0;
      Vd_Addr_1 <= 0;
      valid1_1 <= 0;
      valid2_1 <= 0;
      Imm_1<=0;
      Imm_2<=0;


      Vs1_2 <= 0;
      Vs2_2 <= 0;
      mask_2 <= 0;
      Imm_2 <= 0;
      SEW_2 <= 0;
      ID_2 <= 0;
      opcode_2 <= 0;
      funct3_2 <= 0;
      funct6_2 <= 0;
      Vd_Addr_2 <= 0;
      valid1_2 <= 0;
      valid2_2 <= 0;

      mem_width_1<=0;
      mem_width_2<=0;
      vector_length_1<=0;
      vector_length_2<=0;
      vm_1<=0;
      vm_2<=0;
      vma_1<=0;
      vma_2<=0;
      mop_1<=0;
      mop_2<=0;
      Rs1_1<=0;
      Rs1_2<=0;
      Rs2_1<=0;
      Rs2_2<=0;

      mem_width_o<=0;
      vector_length_o<=0;
      vm_o<=0;
      vma_o<=0;
      mop_o<=0;
      Rs1_o<=0;
      Rs2_o<=0;


      cycle <=0;
      occupied <= 0;
      valid_o <= 0;
      done <= 0;
      reservation_station_reg<=0;
    end else begin 
      if (valid_i) begin
        reservation_station_reg<=reservation_station_en_i;
      end else if (!valid1_2) begin
        reservation_station_reg <= 0;
      end
      
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

      if (reservation_station_en_i == RS || cycle>0  || (reservation_station_reg == RS &&valid1_2)) begin
        case (occupied)

          2'b00: begin
            if (valid_i) begin
              Vs1_1 <= Vs1_i;
              Vs2_1 <= Vs2_i;
              mask_1 <= mask_i;
              Imm_1 <= Imm_i;
              SEW_1 <= SEW_i;
              ID_1 <= ID_i;
              opcode_1 <= opcode_i;
              funct3_1 <= funct3_i;
              funct6_1 <= funct6_i;
              Vd_Addr_1 <= Vd_Addr_i;
              valid1_1 <= valid1_i;
              valid2_1 <= valid2_i;
              Imm_1<=Imm_i;
              mem_width_1<=mem_width_i;
              vector_length_1<=vector_length_i;
              vm_1<=vm_i;
              vma_1<=vma_i;
              mop_1<=mop_i;
              Rs1_1<=Rs1_i;
              Rs2_1<=Rs2_i;

              occupied[0] <= 1;
            end else if (done) begin
              Vs1_1 <= 0;
              Vs2_1 <= 0;
              mask_1 <= 0;
              Imm_1 <= 0;
              SEW_1 <= 0;
              ID_1 <= 0;
              opcode_1 <= 0;
              funct3_1 <= 0;
              funct6_1 <= 0;
              Vd_Addr_1 <= 0;
              Imm_1<=0;

              mem_width_1<=0;
              vector_length_1<=0;
              vm_1<=0;
              vma_1<=0;
              mop_1<=0;
              Rs1_1<=0;
              Rs2_1<=0;

              occupied[0] <= 0;
            end
          end


          2'b01: begin
            if (valid_i) begin
              if (done && valid_o) begin //LAW REG 1 5ALAS BEY5ALAS 7OT EL INPUT FE REG1 3ADY //valid_out 3ashan momken a7tag astana for chaining if SEW_1==32
                Vs1_1 <= Vs1_i;
                Vs2_1 <= Vs2_i;
                mask_1 <= mask_i;
                Imm_1 <= Imm_i;
                SEW_1 <= SEW_i;
                ID_1 <= ID_i;
                opcode_1 <= opcode_i;
                funct3_1 <= funct3_i;
                funct6_1 <= funct6_i;
                Vd_Addr_1 <= Vd_Addr_i;
                valid1_1 <= valid1_i;
                valid2_1 <= valid2_i;
                Imm_1<=Imm_i;

                mem_width_1<=mem_width_i;
                vector_length_1<=vector_length_i;
                vm_1<=vm_i;
                vma_1<=vma_i;
                mop_1<=mop_i;
                Rs1_1<=Rs1_i;
                Rs2_1<=Rs2_i;

                occupied[0] <= 1;
              end else begin //LAW REG 1 MESH BEY5ALAS 7OT EL INPUT FE REG2 3ASHAN YESTANA
                Vs1_2 <= Vs1_i;
                Vs2_2 <= Vs2_i;
                mask_2 <= mask_i;
                Imm_2 <= Imm_i;
                SEW_2 <= SEW_i;
                ID_2 <= ID_i;
                opcode_2 <= opcode_i;
                funct3_2 <= funct3_i;
                funct6_2 <= funct6_i;
                Vd_Addr_2 <= Vd_Addr_i;
                valid1_2 <= valid1_i;
                valid2_2 <= valid2_i;
                Imm_2<=Imm_i;

                mem_width_2<=mem_width_i;
                vector_length_2<=vector_length_i;
                vm_2<=vm_i;
                vma_2<=vma_i;
                mop_2<=mop_i;
                Rs1_2<=Rs1_i;
                Rs2_2<=Rs2_i;

                occupied[1] <= 1;
              end     
          end
        end
        


          2'b11: begin
            if (done && valid_o) begin //KEDA KEDA LAW EL INSTRUCTION EL ABLI HAT5ALAS HA SHIFT EL MESTANI //valid_out 3ashan momken a7tag astana for chaining if SEW_1==32
              Vs1_1 <= Vs1_2;                              Vs1_2 <= 0; 
              Vs2_1 <= Vs2_2;                              Vs2_2 <= 0;
              mask_1 <= mask_2;                            mask_2 <= 0;
              Imm_1 <= Imm_2;                              Imm_2 <= 0;
              SEW_1 <= SEW_2;                              SEW_2 <= 0;
              ID_1 <= ID_2;                                ID_2 <= 0;
              opcode_1 <= opcode_2;                        opcode_2 <= 0;
              funct3_1 <= funct3_2;                        funct3_2 <= 0;
              funct6_1 <= funct6_2;                        funct6_2 <= 0;
              Vd_Addr_1 <= Vd_Addr_2;                      Vd_Addr_2 <= 0;
              valid1_1 <= valid1_2;                        valid1_2 <= 0;
              valid2_1 <= valid2_2;                        valid2_2 <= 0;    
              
              mem_width_1<=mem_width_2;                   mem_width_2<=0;
              vector_length_1<=vector_length_2;           vector_length_2<=0;
              vm_1<=vm_2;                                 vm_2<=0;
              vma_1<=vma_2;                               vma_2<=0;
              mop_1<=mop_2;                               mop_2<=0;
              Rs1_1<=Rs1_2;                               Rs1_2<=0;
              Rs2_1<=Rs2_2;                               Rs2_2<=0;
              Imm_1<=Imm_2;
              Imm_2<=0;

              occupied <= 2'b01;

              if (valid_i) begin //LAW FI KAMAN INSTRUCTION DA5LA YEB2A HADA5ALHA MAKAN EL SHIFTED BIT (registers 2)
                Vs1_2 <= Vs1_i;
                Vs2_2 <= Vs2_i;
                mask_2 <= mask_i;
                Imm_2 <= Imm_i;
                SEW_2 <= SEW_i;
                ID_2 <= ID_i;
                opcode_2 <= opcode_i;
                funct3_2 <= funct3_i;
                funct6_2 <= funct6_i;
                Vd_Addr_2 <= Vd_Addr_i;
                valid1_2 <= valid1_i;
                valid2_2 <= valid2_i;
                Imm_2<=Imm_i;

                mem_width_2<=mem_width_i;
                vector_length_2<=vector_length_i;
                vm_2<=vm_i;
                vma_2<=vma_i;
                mop_2<=mop_i;
                Rs1_2<=Rs1_i;
                Rs2_2<=Rs2_i;

                occupied <= 2'b11;
              end
         end
       end

          2'b10: begin //should not happen bas just in case
          Vs1_1 <= Vs1_2;
          Vs2_1 <= Vs2_2;
          mask_1 <= mask_2;
          Imm_1 <= Imm_2;
          SEW_1 <= SEW_2;
          ID_1 <= ID_2;
          opcode_1 <= opcode_2;
          funct3_1 <= funct3_2;
          funct6_1 <= funct6_2;
          Vd_Addr_1 <= Vd_Addr_2;
          valid1_1 <= valid1_2;
          valid2_1 <= valid2_2;

          mem_width_1<=mem_width_i;
          vector_length_1<=vector_length_2;
          vm_1<=vm_2;
          vma_1<=vma_2;
          mop_1<=mop_2; 
          Rs1_1<=Rs1_2;
          Rs2_1<=Rs2_2;

          occupied <= 2'b01;
        end
        endcase
    end

    if ((valid_i&&reservation_station_en_i==RS) || occupied[0] || (cycle>0 && SEW_1==E8) || (valid1_2&&reservation_station_reg==RS)) begin
        done <= 0;
///////start cycles calculations as now there's guarenteed output/////////
        case (SEW_1)
        E32: begin 
          cycle <= 0;
          done <= 1;
          valid_o <= 1;
          if (!occupied[1] && !valid_i && valid_o) begin //Law mafish instruction mestania aw gaia clear 3ady
            occupied[0]<=0;
          end
        end
        E16: begin 
            valid_o <= 1;
            if (cycle < 3'd1 && valid_o) begin
              cycle <= cycle + 1'b1;
            end else begin 
              if (cycle==1) begin
                cycle <= 0;
              end
              if (!occupied[1] && !valid_i && valid_o) begin //Law mafish instruction mestania aw gaia clear 3ady
                occupied[0]<=0;
                valid_o <= 0;
              end
            end
        end
        E8: begin 
          valid_o <= 1;
          if (cycle < 3'd3 && valid_o) begin
            cycle <= cycle + 1'b1;
          end else begin
            cycle <= 0;
            if (!occupied[1] && !valid_i && valid_o && done) begin //Law mafish instruction mestania aw gaia clear 3ady
              occupied[0]<=0;
              valid_o <= 0;
            end
          end
        end

        default : begin 
          valid_o <= 0;
          cycle <= 0;
          if (!occupied[1] && !valid_i) begin //Law mafish instruction mestania aw gaia clear 3ady
            occupied[0]<=0;
          end
        end

      endcase

      end else begin
        cycle<=0;
        valid_o <= 0;
      end
  end
  end


integer i;
always @(*) begin
  for (i = 0; i < 4; i = i+1) begin
    data1_o[i] = 0; 
    data2_o[i] = 0;
  end
  ID_o = 0;
  SEW_o = 0;
  opcode_o = 0;
  funct3_o = 0;
  funct6_o = 0;
  Vd_Addr_o = 0;


  if (valid_o) begin
    ID_o = ID_1;
    SEW_o = SEW_1;
    opcode_o = opcode_1;
    funct3_o = funct3_1;
    funct6_o = funct6_1;
    Vd_Addr_o = Vd_Addr_1;

    mem_width_o=mem_width_i;
    vector_length_o=vector_length_i;
    vm_o=vm_i;
    vma_o=vma_i;
    mop_o=mop_i; 
    Rs1_o=Rs1_i;
    Rs2_o=Rs2_i;

    done = (SEW_1==E32 || (SEW_1==E16 && cycle==3'd1) || (SEW_1==E8 && cycle==3'd3));

    case (SEW_1)

      E32: begin 
        for (i = 0; i < 4; i = i+1) begin
          data1_o[i] =  Vs1_1[32*i +: 32];  // +: ya3ni hata5od men el kebir lel so8ayar so 32:0 and then 64:32
          data2_o[i] = (funct3_1==3'b011)? Imm_1:(funct3_1==3'b100)? Rs1_1:Vs2_1[32*i +: 32]; 
        end
      end

      E16: begin 
        for (i = 0; i < 4; i = i+1) begin
          data1_o[i] = Vs1_1[16*i + cycle*64 +: 16] ; // +: nafs el 7aga bas 16*i 3ashan 16 bits and cycle*64 3ashan yebda2 men el nos fel second cycle
          data2_o[i] = (funct3_1==3'b011)? Imm_1:(funct3_1==3'b100)? Rs1_1:Vs2_1[16*i + cycle*64 +: 16] ;
        end
      end

      E8: begin 
        for (i = 0; i < 4; i = i+1) begin
          data1_o[i] = Vs1_1[8*i + cycle*32 +: 8]; // +: nafs el 7aga bas 8*i 3ashan 8 bits and cycle*32 3ashan yebda2 men el rob3 fel second cycle
          data2_o[i] = (funct3_1==3'b011)? Imm_1:(funct3_1==3'b100)? Rs1_1:Vs2_1[8*i + cycle*32 +: 8];
        end
      end
        
      default : begin 
        for (i = 0; i < 4; i = i+1) begin
          data1_o[i] = Vs1_1[32*i +: 32]; 
          data2_o[i] = (funct3_1==3'b011)? Imm_1:(funct3_1==3'b100)? Rs1_1:Vs2_1[32*i +: 32]; 
        end
      end

    endcase

  end
      
end

always @(*) begin
  full = 0;
  case (occupied)
    2'b00: full = 0;
    2'b01: full = valid_i? 
                  (done && valid_o)? 0:1
                  :0;
    2'b11: full = (done && valid_o)? 
                  valid_i? 1:0
                  :1;
  endcase
end

endmodule