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
    assign uo_out = ui_in;
    wire [7:0] test1;
    wire [7:0] test2;

    wire [2:0] opcode;
    wire       eq;

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

    reg  [1:0] func_alu;
    wire       mux_alu1;
    wire       mux_alu2;
    wire       mux_pc;
    wire       mux_rf;
    wire       mux_tgt;
    wire       we_rf;
    wire       we_dmem;
    
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
    end

    register_file register_file (
        .src1       (ui_in[2:0]),
        .src2       (ui_in[5:3]),
        .tgt        (ui_in[7:5]),
        .src1_dat   ({uio_out,test1}),
        .src2_dat   ({uio_oe,test2}),
        .tgt_dat    ({uio_in,uio_in}),
        .clk        (clk),      // clock
        .rst_n      (rst_n)     // not reset
    );

    always @(posedge clk) begin
        if (!rst_n) begin
        end else begin
        end
    end

endmodule
