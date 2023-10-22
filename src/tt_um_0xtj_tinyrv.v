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
