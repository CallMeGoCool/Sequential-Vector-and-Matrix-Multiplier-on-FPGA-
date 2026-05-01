`timescale 1ns/1ps

module tb_vector_unit;

    reg [7:0] A0, A1, B0, B1;
    wire [19:0] result;

    vector_unit DUT (
        .A0(A0),
        .A1(A1),
        .B0(B0),
        .B1(B1),
        .result(result)
    );

    initial begin

        $display("===== VECTOR UNIT TEST START =====");

        // Test 1
        A0 = 8'd10;
        A1 = 8'd5;
        B0 = 8'd2;
        B1 = 8'd3;

        #10;
        $display("A=[10,5], B=[2,3] => RESULT=%d", result);

        // Test 2
        A0 = 8'd20;
        A1 = 8'd4;
        B0 = 8'd3;
        B1 = 8'd6;

        #10;
        $display("A=[20,4], B=[3,6] => RESULT=%d", result);

        // Test 3 (edge case)
        A0 = 8'd255;
        A1 = 8'd255;
        B0 = 8'd255;
        B1 = 8'd255;

        #10;
        $display("MAX CASE => RESULT=%d", result);

        $display("===== TEST COMPLETE =====");

        $finish;
    end

endmodule