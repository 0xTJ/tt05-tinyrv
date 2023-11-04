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

    assign uo_out[7:1]  = 7'b0;
    assign uio_out[7:4] = 4'b0;
    assign uio_oe[7:4]  = 4'b0;

    wire [3:0] lad_in;
    wire [3:0] lad_out;
    wire       lad_oe;
    assign lad_in       = uio_in[3:0];
    assign uio_out[3:0] = lad_out;
    assign uio_oe[3:0]  = {4{lad_oe}};

    wire lframe;
    assign uo_out[0] = ~lframe;

    wire lreset;
    assign lreset = ~rst_n;

    wire lclk;
    assign lclk = clk;

    lpc lpc (
        .lad_in     (lad_in),
        .lad_out    (lad_out),
        .lad_oe     (lad_oe),
        .lframe     (lframe),
        .lreset     (lreset),
        .lclk       (lclk),

        .go         (1'b1),
        .dir        (1'b0),
        .addr       (32'h87654321),
        .write_data (8'hA5)
    );

    // localparam PHASE_PC_LO          = 3'b000;
    // localparam PHASE_PC_HI          = 3'b001;
    // localparam PHASE_INSTR_LO       = 3'b010;
    // localparam PHASE_INSTR_HI       = 3'b011;
    // localparam PHASE_DMEM_ADDR_LO   = 3'b100;
    // localparam PHASE_DMEM_ADDR_HI   = 3'b101;
    // localparam PHASE_DMEM_DATA_LO   = 3'b110;
    // localparam PHASE_DMEM_DATA_HI   = 3'b111;

    // reg uio_oe_all;
    // assign uio_oe = {8{uio_oe_all}};

    // wire [15:0] pc;
    // reg  [15:0] instr;

    // reg [2:0] phase;

    // assign uo_out[2:0]  = phase;
    // assign uo_out[3]    = ext_dmem_we;

    // wire [15:0] dmem_addr;
    // wire [15:0] dmem_data_in;
    // reg  [15:0] dmem_data_out;
    // wire        dmem_we;
    // reg         ext_dmem_we;

    // reg core_clk;

    // always @(posedge clk) begin
    //     case (phase)
    //         PHASE_INSTR_LO:     instr[7:0]          <= uio_in;
    //         PHASE_INSTR_HI:     instr[15:8]         <= uio_in;
    //         PHASE_DMEM_DATA_LO: dmem_data_out[7:0]  <= uio_in;
    //         PHASE_DMEM_DATA_HI: dmem_data_out[15:8] <= uio_in;
    //     endcase

    //     case (phase)
    //         PHASE_DMEM_ADDR_LO: ext_dmem_we <= dmem_we;
    //     endcase

    //     case (phase)
    //         PHASE_INSTR_HI:     core_clk <= 1'b0;
    //         PHASE_DMEM_DATA_HI: core_clk <= 1'b1;
    //     endcase
    // end

    // always @(negedge clk) begin
    //     phase <= phase + 3'b1;

    //     uio_oe_all <= 1'b0;

    //     case (phase)
    //         PHASE_PC_LO:        uio_out <= pc[7:0];
    //         PHASE_PC_HI:        uio_out <= pc[15:8];
    //         PHASE_DMEM_ADDR_LO: uio_out <= dmem_addr[7:0];
    //         PHASE_DMEM_ADDR_HI: uio_out <= dmem_addr[15:8];
    //         PHASE_DMEM_DATA_LO: uio_out <= dmem_data_in[7:0];
    //         PHASE_DMEM_DATA_HI: uio_out <= dmem_data_in[15:8];
    //     endcase

    //     case (phase)
    //         PHASE_PC_LO:        uio_oe_all <= 1'b1;
    //         PHASE_PC_HI:        uio_oe_all <= 1'b1;
    //         PHASE_DMEM_ADDR_LO: uio_oe_all <= 1'b1;
    //         PHASE_DMEM_ADDR_HI: uio_oe_all <= 1'b1;
    //         PHASE_DMEM_DATA_LO: uio_oe_all <= dmem_we;
    //         PHASE_DMEM_DATA_HI: uio_oe_all <= dmem_we;
    //     endcase
    // end

    // risc16 risc16 (
    //     .pc             (pc),
    //     .instr          (instr),
    //     .dmem_addr      (dmem_addr),
    //     .dmem_data_in   (dmem_data_in),
    //     .dmem_data_out  (dmem_data_out),
    //     .dmem_we        (dmem_we),
    //     .ena            (ena),
    //     .clk            (core_clk),
    //     .rst_n          (rst_n)
    // );

endmodule
