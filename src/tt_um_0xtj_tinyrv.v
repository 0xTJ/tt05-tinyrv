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

    wire [15:0] instr;
    assign instr = {ui_in,uio_in};

    assign uo_out = imem_addr[7:0];
    assign uio_out = dmem_addr[7:0];
    assign uio_oe = dmem_data_in[7:0];

    wire [15:0] imem_addr;
    wire [15:0] imem_data_out;
    wire [15:0] dmem_addr;
    wire [15:0] dmem_data_in;
    wire [15:0] dmem_data_out;

    assign imem_data_out = instr;
    assign dmem_data_out = {uio_in,ui_in};

    risc16 risc16 (
        .imem_addr     (imem_addr),
        .imem_data_out (imem_data_out),
        .dmem_addr     (dmem_addr),
        .dmem_data_in  (dmem_data_in),
        .dmem_data_out (dmem_data_out),
        .ena           (ena),
        .clk           (clk),
        .rst_n         (rst_n)
    );

endmodule
