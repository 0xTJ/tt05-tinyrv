module tt_um_0xtj_tinyrv (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    wire [7:0] test1;

    wire  [15:0] instr;
    assign instr[15:8] = ui_in;
    assign instr[7:0] = uio_in;

    wire [2:0]  opcode;
    wire [1:0]  rega;
    wire [1:0]  regb;
    wire [1:0]  regc;
    wire [15:0] simm;
    wire [15:0] imm;
    wire        eq;

    assign opcode     = instr[15:13];
    assign rega       = instr[12:10];
    assign regb       = instr[9:7];
    assign regc       = instr[2:0];
    assign simm[5:0]  = instr[5:0];
    assign simm[15:6] = instr[6];
    assign imm[15:6]  = instr[9:0];
    assign imm[5:0]   = 6'b000000;

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

    wire [2:0] src1;
    wire [2:0] src2;
    wire [2:0] tgt;

    assign src1 = regb;
    assign src2 = mux_rf ? rega : regc;
    assign tgt = rega;

    reg [1:0] func_alu;
    reg       mux_alu1;
    reg       mux_alu2;
    reg [1:0] mux_pc;
    reg       mux_rf;
    reg       mux_tgt;
    reg       we_rf;
    reg       we_dmem;
    
    always @(*) begin
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

    register_file register_file (
        .src1       (src1),
        .src2       (src2),
        .tgt        (tgt),
        .src1_dat   ({uio_out,uio_oe}),
        .src2_dat   ({uo_out,test1}),
        .tgt_dat    ({ui_in,uio_in}),
        .we         (we_rf),
        .clk        (clk),      // clock
        .rst_n      (rst_n)     // not reset
    );

    always @(posedge clk) begin
        if (!rst_n) begin
        end else begin
        end
    end

endmodule
