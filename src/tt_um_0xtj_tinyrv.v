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

    reg [1:0] mux_phase;

    register_file register_file (
        .mux_phase  (mux_phase),
        .rs1        (ui_in[3:0]),
        .rs2        (ui_in[7:4]),
        .rd         (ui_in[3:0]),
        .rs1_dat    (uio_out),
        .rs2_dat    (uio_oe),
        .rd_dat     (uio_in),
        .clk        (clk),      // clock
        .rst_n      (rst_n)     // not reset
    );


    always @(posedge clk) begin
        if (!rst_n) begin
            mux_phase <= 0;
        end else begin
            mux_phase <= mux_phase + 1;
        end
    end

endmodule
