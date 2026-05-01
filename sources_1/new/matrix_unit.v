//best version
module matrix_unit(

    input [7:0] A00,
    input [7:0] A01,
    input [7:0] A10,
    input [7:0] A11,

    input [7:0] B00,
    input [7:0] B01,
    input [7:0] B10,
    input [7:0] B11,

    output [19:0] C00,
    output [19:0] C01,
    output [19:0] C10,
    output [19:0] C11

);

    // -------------------------
    // INTERNAL MULTIPLICATIONS
    // -------------------------
    wire [15:0] m00 = A00 * B00;
    wire [15:0] m01 = A01 * B10;

    wire [15:0] m02 = A00 * B01;
    wire [15:0] m03 = A01 * B11;

    wire [15:0] m10 = A10 * B00;
    wire [15:0] m11 = A11 * B10;

    wire [15:0] m12 = A10 * B01;
    wire [15:0] m13 = A11 * B11;

    // -------------------------
    // SUMS (DOT PRODUCTS)
    // -------------------------
    assign C00 = m00 + m01;
    assign C01 = m02 + m03;
    assign C10 = m10 + m11;
    assign C11 = m12 + m13;

endmodule