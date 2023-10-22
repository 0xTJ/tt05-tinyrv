module control (
    input  wire [2:0] opcode,
    input  wire       eq,
    output reg  [1:0] func_alu,
    output reg        mux_alu1,
    output reg        mux_alu2,
    output reg  [1:0] mux_pc,
    output reg        mux_rf,
    output reg  [1:0] mux_tgt,
    output reg        we_rf,
    output reg        we_dmem
);

    localparam OPCODE_ADD  = 3'b000;
    localparam OPCODE_ADDI = 3'b001;
    localparam OPCODE_NAND = 3'b010;
    localparam OPCODE_LUI  = 3'b011;
    localparam OPCODE_LW   = 3'b100;
    localparam OPCODE_SW   = 3'b101;
    localparam OPCODE_BEQ  = 3'b110;
    localparam OPCODE_JALR = 3'b111;

    localparam FUNC_ALU_ADD   = 2'b00;
    localparam FUNC_ALU_NAND  = 2'b01;
    localparam FUNC_ALU_PASS1 = 2'b10;
    localparam FUNC_ALU_EQ    = 2'b11;

    localparam MUX_PC_NEXT   = 2'b01;
    localparam MUX_PC_BRANCH = 2'b10;
    localparam MUX_PC_JUMP   = 2'b11;

    localparam MUX_TGT_ALU   = 2'b01;
    localparam MUX_TGT_DMEM  = 2'b10;
    localparam MUX_TGT_PC    = 2'b11;
    
    always @(opcode or eq) begin
        case (opcode)
            OPCODE_ADD:  func_alu = FUNC_ALU_ADD;
            OPCODE_ADDI: func_alu = FUNC_ALU_ADD;
            OPCODE_NAND: func_alu = FUNC_ALU_NAND;
            OPCODE_LUI:  func_alu = FUNC_ALU_PASS1;
            OPCODE_LW:   func_alu = FUNC_ALU_ADD;
            OPCODE_SW:   func_alu = FUNC_ALU_ADD;
            OPCODE_BEQ:  func_alu = FUNC_ALU_EQ;
            OPCODE_JALR: func_alu = FUNC_ALU_PASS1;
        endcase

        case (opcode)
            OPCODE_ADD:  mux_alu1 = 1'b0;
            OPCODE_ADDI: mux_alu1 = 1'b0;
            OPCODE_NAND: mux_alu1 = 1'b0;
            OPCODE_LUI:  mux_alu1 = 1'b1;
            OPCODE_LW:   mux_alu1 = 1'b0;
            OPCODE_SW:   mux_alu1 = 1'b0;
            OPCODE_BEQ:  mux_alu1 = 1'b0;
            OPCODE_JALR: mux_alu1 = 1'b0;
        endcase

        case (opcode)
            OPCODE_ADD:  mux_alu2 = 1'b0;
            OPCODE_ADDI: mux_alu2 = 1'b1;
            OPCODE_NAND: mux_alu2 = 1'b0;
            OPCODE_LW:   mux_alu2 = 1'b1;
            OPCODE_SW:   mux_alu2 = 1'b1;
            OPCODE_BEQ:  mux_alu2 = 1'b0;
        endcase

        case (opcode)
            OPCODE_BEQ:  mux_pc = eq ? MUX_PC_BRANCH : MUX_PC_NEXT;
            OPCODE_JALR: mux_pc = MUX_PC_JUMP;
            default:     mux_pc = MUX_PC_NEXT;
        endcase

        case (opcode)
            OPCODE_ADD:  mux_rf = 1'b0;
            OPCODE_NAND: mux_rf = 1'b0;
            OPCODE_SW:   mux_rf = 1'b1;
            OPCODE_BEQ:  mux_rf = 1'b1;
        endcase

        case (opcode)
            OPCODE_ADD:  mux_tgt = MUX_TGT_ALU;
            OPCODE_ADDI: mux_tgt = MUX_TGT_ALU;
            OPCODE_NAND: mux_tgt = MUX_TGT_ALU;
            OPCODE_LUI:  mux_tgt = MUX_TGT_ALU;
            OPCODE_LW:   mux_tgt = MUX_TGT_DMEM;
            OPCODE_JALR: mux_tgt = MUX_TGT_PC;
        endcase

        case (opcode)
            OPCODE_ADD:  we_rf = 1'b1;
            OPCODE_ADDI: we_rf = 1'b1;
            OPCODE_NAND: we_rf = 1'b1;
            OPCODE_LUI:  we_rf = 1'b1;
            OPCODE_LW:   we_rf = 1'b1;
            OPCODE_JALR: we_rf = 1'b1;
            default:     we_rf = 1'b0;
        endcase

        case (opcode)
            OPCODE_SW:   we_dmem = 1'b1;
            default:     we_dmem = 1'b0;
        endcase
    end

endmodule
