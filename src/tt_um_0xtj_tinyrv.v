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

    wire eq;
    assign eq = ena;

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
    wire       mux_tgt;
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

    // Make register file selectors
    wire [2:0] src1;
    reg  [2:0] src2;
    wire [2:0] tgt;
    assign src1 = regb;
    always @(*) src2 = mux_rf ? rega : regc;
    assign tgt = rega;

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
