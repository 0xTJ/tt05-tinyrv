module lpc (
    input  wire [3:0]   lad_in,
    output reg  [3:0]   lad_out,
    output reg          lad_oe,
    output reg          lframe,
    input  wire         lreset,
    input  wire         lclk,

    input  wire         go,
    input  wire         dir,
    input  wire [31:0]  addr,
    output reg [7:0]    read_data,
    input  wire [7:0]   write_data,
    output reg          done
);
    reg [1:0] cyctype = CYCTYPE_MEMORY;

    localparam CYCLE_START          = 4'd0;
    localparam CYCLE_CYCTYPE_DIR    = 4'd1;
    // localparam CYCLE_SIZE           = 3'd2;
    localparam CYCLE_TAR_0            = 4'd3;
    localparam CYCLE_TAR_1            = 4'd8;
    localparam CYCLE_ADDR           = 4'd4;
    // localparam CYCLE_CHANNEL        = 3'd5;
    localparam CYCLE_DATA           = 4'd6;
    localparam CYCLE_SYNC           = 4'd7;

    // localparam CYCTYPE_IO       = 2'b00;
    localparam CYCTYPE_MEMORY   = 2'b01;
    // localparam CYCTYPE_DMA      = 2'b10;

    reg [3:0] cycle;
    reg [3:0] cycle_count_left;
    reg [3:0] next_cycle;
    reg [3:0] next_cycle_count_left;
    reg next_lframe;

    always @(negedge go) begin
        done <= 1'b0;
    end

    always @(*) begin
        case (cycle)
            CYCLE_START: begin
                if (lframe != 1'b1) begin
                    next_lframe = 1'b1;
                    next_cycle = CYCLE_START;
                end else if (go) begin
                    next_cycle = CYCLE_CYCTYPE_DIR;
                    next_lframe = 1'b0;
                end else begin
                    next_cycle = CYCLE_START;
                end
            end

            CYCLE_CYCTYPE_DIR: begin
                next_cycle = CYCLE_ADDR;
            end

            CYCLE_ADDR: begin
                if (cycle_count_left == 0) begin
                    if (dir == 1'b0)    next_cycle = CYCLE_TAR_0;   // Read
                    else                next_cycle = CYCLE_DATA;    // Write
                end else begin
                    next_cycle = CYCLE_ADDR;
                end
            end

            CYCLE_DATA: begin
                if (cycle_count_left == 0) begin
                    if (dir == 1'b0)    next_cycle = CYCLE_TAR_1;   // Read
                    else                next_cycle = CYCLE_TAR_0;   // Write
                end else begin
                    next_cycle = CYCLE_DATA;
                end
            end

            CYCLE_TAR_0: begin
                if (cycle_count_left == 4'h0)   next_cycle = CYCLE_SYNC;
                else                            next_cycle = CYCLE_TAR_0;
            end

            CYCLE_TAR_1: begin
                if (cycle_count_left == 4'h0)   next_cycle = CYCLE_START;
                else                            next_cycle = CYCLE_TAR_1;
            end

            CYCLE_SYNC: begin
                case (lad_in)
                    4'b0000: next_cycle = (dir ? CYCLE_TAR_1 : CYCLE_DATA);
                    default: next_cycle = CYCLE_SYNC;
                endcase
            end
        endcase

        if (next_cycle != cycle) case (next_cycle)
            // Only assign for cycles that care about the count
            CYCLE_ADDR: next_cycle_count_left = 4'h7;
            CYCLE_DATA: next_cycle_count_left = 4'h1;
            CYCLE_TAR_0: next_cycle_count_left = 4'h1;
            CYCLE_TAR_1: next_cycle_count_left = 4'h1;
        endcase else begin
            next_cycle_count_left = cycle_count_left - 1;
        end
    end

    always @(posedge lclk, lreset) begin
        if (lreset == 1'b1) begin
            cycle <= CYCLE_START;
            cycle_count_left <= 4'h0;
            done <= 1'b0;
            lframe <= 1'b0;
        end else begin
            cycle <= next_cycle;
            cycle_count_left <= next_cycle_count_left;
            lframe <= next_lframe;
        end
    end

    always @(cycle, cycle_count_left) begin
        case (cycle)
            CYCLE_START: begin
                lad_oe = 1'b1;
                lad_out = 4'b0000;
            end

            CYCLE_CYCTYPE_DIR: begin
                lad_out = {cyctype, dir, 1'b0};
            end

            CYCLE_ADDR: begin
                case (cycle_count_left)
                    7: lad_out = addr[31:28];
                    6: lad_out = addr[27:24];
                    5: lad_out = addr[23:20];
                    4: lad_out = addr[19:16];
                    3: lad_out = addr[15:12];
                    2: lad_out = addr[11:8];
                    1: lad_out = addr[7:4];
                    0: lad_out = addr[3:0];
                endcase
            end

            CYCLE_DATA: begin
                case (cycle_count_left)
                    1: lad_out = write_data[3:0];
                    0: lad_out = write_data[7:4];
                endcase
            end

            CYCLE_TAR_0: begin
                if (cycle_count_left == 0) lad_oe = 1'b0;
                else lad_out = 4'b1111;
            end

            CYCLE_TAR_1: begin
            end

            CYCLE_SYNC: begin
                lad_out = 4'b0000;
            end
        endcase
    end

endmodule
