module register_file (
    input  wire [1:0] mux_phase,
    input  wire [3:0] rs1,
    input  wire [3:0] rs2,
    input  wire [3:0] rd,
    output reg  [7:0] rs1_dat,
    output reg  [7:0] rs2_dat,
    input  wire [7:0] rd_dat,
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    reg [7:0] reg_file_write [15:0][3:0];
    wire [7:0] reg_file_read [15:0][3:0];

    genvar i, j;
    generate
    for(i = 0; i < 16; i += 1) begin
        for(j = 0; j < 4; j += 1) begin
            if (i == 0) begin
                assign reg_file_read[i][j] = 0;
            end else begin
                assign reg_file_read[i][j] = reg_file_write[i][j];
            end
        end
    end
    endgenerate

    always @(negedge clk) begin
        rs1_dat <= reg_file_read[rs1][mux_phase];
        rs2_dat <= reg_file_read[rs2][mux_phase];
    end

    always @(posedge clk) begin
        reg_file_write[rd][mux_phase] <= rd_dat;
    end

endmodule
