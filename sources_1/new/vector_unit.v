//best version
module vector_unit(
    input [7:0] A0,
    input [7:0] A1,
    input [7:0] B0,
    input [7:0] B1,

    output [19:0] result
);

    wire [15:0] p0;
    wire [15:0] p1;
    wire [19:0] sum;

    assign p0 = A0 * B0;
    assign p1 = A1 * B1;

    assign sum = p0 + p1;

    assign result = sum;

endmodule