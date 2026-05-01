`timescale 1ns/1ps

module tb_matrix_unit;

    reg [7:0] A00, A01, A10, A11;
    reg [7:0] B00, B01, B10, B11;

    wire [19:0] C00, C01, C10, C11;

    // DUT
    matrix_unit DUT (
        .A00(A00), .A01(A01), .A10(A10), .A11(A11),
        .B00(B00), .B01(B01), .B10(B10), .B11(B11),
        .C00(C00), .C01(C01), .C10(C10), .C11(C11)
    );

    // -----------------------------
    // MONITOR TASK (CLEAN OUTPUT)
    // -----------------------------
    task show_state;
    begin
        $display("\nTIME=%0t", $time);
        $display("A = [%0d %0d; %0d %0d]", A00, A01, A10, A11);
        $display("B = [%0d %0d; %0d %0d]", B00, B01, B10, B11);

        $display("C00 = %0d", C00);
        $display("C01 = %0d", C01);
        $display("C10 = %0d", C10);
        $display("C11 = %0d", C11);
    end
    endtask

    // -----------------------------
    // TEST VECTOR PROCEDURE
    // -----------------------------
    initial begin

        $display("===== MATRIX UNIT 2x2 TEST START =====");

        // ---------------- TEST 1 ----------------
        A00 = 1; A01 = 2;
        A10 = 3; A11 = 4;

        B00 = 5; B01 = 6;
        B10 = 7; B11 = 8;

        #10;
        $display("\n--- TEST 1 ---");
        show_state();

        // Expected:
        // C00 = 1*5 + 2*7 = 19
        // C01 = 1*6 + 2*8 = 22
        // C10 = 3*5 + 4*7 = 43
        // C11 = 3*6 + 4*8 = 50

        // ---------------- TEST 2 ----------------
        #10;
        A00 = 10; A01 = 20;
        A10 = 30; A11 = 40;

        B00 = 1; B01 = 2;
        B10 = 3; B11 = 4;

        #10;
        $display("\n--- TEST 2 ---");
        show_state();

        // ---------------- TEST 3 (EDGE CASE) ----------------
        #10;
        A00 = 8'd255; A01 = 8'd255;
        A10 = 8'd255; A11 = 8'd255;

        B00 = 8'd255; B01 = 8'd255;
        B10 = 8'd255; B11 = 8'd255;

        #10;
        $display("\n--- TEST 3 (MAX CASE) ---");
        show_state();

        $display("\n===== TEST COMPLETE =====");
        $finish;

    end

endmodule