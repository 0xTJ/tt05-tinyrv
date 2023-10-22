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
    localparam MUX_PC_NEXT   = 2'b01;
    localparam MUX_PC_BRANCH = 2'b10;
    localparam MUX_PC_JUMP   = 2'b11;

    localparam MUX_TGT_ALU   = 2'b01;
    localparam MUX_TGT_DMEM  = 2'b10;
    localparam MUX_TGT_PC    = 2'b11;

    wire  [15:0] instr;
    assign instr[15:8] = ui_in;
    assign instr[7:0] = uio_in;

    assign uo_out = pc[15:8];
    assign uio_out = src1_dat[15:8];
    assign uio_oe = src2_dat[15:8];

    reg [15:0] pc;
    reg [15:0] pc_plus_one;
    reg [15:0] pc_next;
    assign pc_plus_one = pc + 15'b1;
    always @(*) begin
        case (mux_pc)
        MUX_PC_NEXT: pc_next = pc_plus_one;
        MUX_PC_BRANCH: pc_next = pc_plus_one + imm;
        MUX_PC_JUMP: pc_next = alu_result;
        endcase
    end

    wire eq;

    // Split components of intruction
    wire [2:0]  opcode;
    wire [2:0]  rega;
    wire [2:0]  regb;
    wire [2:0]  regc;
    wire [15:0] simm;
    wire [15:0] imm;
    assign opcode     = instr[15:13];
    assign rega       = instr[12:10];
    assign regb       = instr[9:7];
    assign regc       = instr[2:0];
    assign simm[5:0]  = instr[5:0];
    assign simm[15:6] = {10{instr[6]}};
    assign imm[15:6]  = instr[9:0];
    assign imm[5:0]   = 6'b000000;

    wire [1:0] func_alu;
    wire       mux_alu1;
    wire       mux_alu2;
    wire [1:0] mux_pc;
    wire       mux_rf;
    wire [1:0] mux_tgt;
    wire       we_rf;
    wire       we_dmem;

    control control (
        .opcode   (opcode),
        .eq       (eq),
        .func_alu (func_alu),
        .mux_alu1 (mux_alu1),
        .mux_alu2 (mux_alu2),
        .mux_pc   (mux_pc),
        .mux_rf   (mux_rf),
        .mux_tgt  (mux_tgt),
        .we_rf    (we_rf),
        .we_dmem  (we_dmem)
    );

    wire [15:0] dmem_data_out;
    assign dmem_data_out = {ui_in,uio_in};

    wire [15:0] src1_dat;
    wire [15:0] src2_dat;
    reg  [15:0] tgt_dat;
    always @(*) begin
        case (mux_tgt)
            MUX_TGT_ALU: tgt_dat = alu_result;
            MUX_TGT_DMEM: tgt_dat = dmem_data_out;
            MUX_TGT_PC: tgt_dat = pc_plus_one;
        endcase
    end

    wire [15:0] alu_operand1;
    wire [15:0] alu_operand2;
    wire [15:0] alu_result;
    assign alu_operand1 = mux_alu1 ? imm : src1_dat;
    assign alu_operand2 = mux_alu2 ? simm : src2_dat;

    alu alu (
        .func     (func_alu),
        .operand1 (alu_operand1),
        .operand2 (alu_operand2),
        .result   (alu_result),
        .eq       (eq)
    );

    // Make register file selectors
    wire [2:0] src1;
    reg  [2:0] src2;
    wire [2:0] tgt;
    assign src1 = regb;
    always @(*) src2 = mux_rf ? rega : regc; // TODO: Use assign?
    assign tgt = rega;

    register_file register_file (
        .src1       (src1),
        .src2       (src2),
        .tgt        (tgt),
        .src1_dat   (src1_dat),
        .src2_dat   (src2_dat),
        .tgt_dat    (tgt_dat),
        .we         (we_rf),
        .clk        (clk),      // clock
        .rst_n      (rst_n)     // not reset
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            pc <= 0;
        end else begin
            pc <= pc_next;
        end
    end

endmodule
