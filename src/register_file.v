module register_file (
    input  wire [2:0] src1,
    input  wire [2:0] src2,
    input  wire [2:0] tgt,
    output reg  [15:0] src1_dat,
    output reg  [15:0] src2_dat,
    input  wire [15:0] tgt_dat,
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    reg [15:0] reg_file_write [7:0];
    wire [15:0] reg_file_read [7:0];

    genvar i;
    generate
    for(i = 0; i < 8; i += 1) begin
        if (i == 0) begin
            assign reg_file_read[i] = 0;
        end else begin
            assign reg_file_read[i] = reg_file_write[i];
        end
    end
    endgenerate

    always @(src1) begin
        src1_dat <= reg_file_read[src1];
    end

    always @(src2) begin
        src2_dat <= reg_file_read[src2];
    end

    always @(posedge clk) begin
        reg_file_write[tgt] <= tgt_dat;
    end

endmodule
