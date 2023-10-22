module alu (
    input  wire [1:0]  func,
    input  wire [15:0] operand1,
    input  wire [15:0] operand2,
    output reg  [15:0] result,
    output reg         eq
);

    localparam FUNC_ALU_ADD   = 2'b00;
    localparam FUNC_ALU_NAND  = 2'b01;
    localparam FUNC_ALU_PASS1 = 2'b10;
    localparam FUNC_ALU_EQ    = 2'b11;

    always @(*) begin
        case (func)
            FUNC_ALU_ADD:   result = operand1 + operand2;
            FUNC_ALU_NAND:  result = ~(operand1 & operand2);
            FUNC_ALU_PASS1: result = operand1;
            FUNC_ALU_EQ:    eq = (operand1 == operand2);
        endcase
    end

endmodule
