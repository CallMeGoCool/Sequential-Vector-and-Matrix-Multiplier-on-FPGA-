`timescale 1ns/1ps

module tb_compute_core;

    reg clk;
    reg reset;
    reg [1:0] mode;
    reg compute_start;

    reg [31:0] A;
    reg [31:0] B;

    wire [79:0] result;
    wire result_ready;

    // DUT
    compute_core DUT (
        .clk(clk),
        .reset(reset),
        .mode(mode),
        .compute_start(compute_start),
        .A(A),
        .B(B),
        .result(result),
        .result_ready(result_ready)
    );

    // -------------------------
    // CLOCK (10ns period)
    // -------------------------
    always #5 clk = ~clk;

    // -------------------------
    // DEBUG TASK
    // -------------------------
    task show_state;
    begin
        $display("\nTIME=%0t", $time);
        $display("MODE=%b START=%b READY=%b", mode, compute_start, result_ready);
        $display("A=%h B=%h", A, B);
        $display("RESULT=%h", result);
    end
    endtask

    // -------------------------
    // STIMULUS
    // -------------------------
    initial begin

        $display("===== COMPUTE CORE TEST START =====");

        clk = 0;
        reset = 1;
        mode = 0;
        compute_start = 0;
        A = 0;
        B = 0;

        #20;
        reset = 0;

        // =====================================================
        // TEST 1: VECTOR MODE
        // =====================================================
        $display("\n--- VECTOR TEST ---");

        mode = 2'b01;

        // A = [10, 5]
        // B = [2, 3]
        A = {16'd0, 8'd5, 8'd10};
        B = {16'd0, 8'd3, 8'd2};

        #10;
        compute_start = 1;
        #10;
        compute_start = 0;

        #50;
        show_state();

        // =====================================================
        // TEST 2: MATRIX MODE
        // =====================================================
        $display("\n--- MATRIX TEST ---");

        mode = 2'b10;

        // A =
        // [1 2]
        // [3 4]
        A = {8'd4, 8'd3, 8'd2, 8'd1};

        // B =
        // [5 6]
        // [7 8]
        B = {8'd8, 8'd7, 8'd6, 8'd5};

        #10;
        compute_start = 1;
        #10;
        compute_start = 0;

        #50;
        show_state();

        // =====================================================
        // TEST 3: STICKY MODE CHECK
        // =====================================================
        $display("\n--- MODE STICKY TEST ---");

        mode = 2'b01; // change mode
        #10;

        mode = 2'b10; // change again BEFORE compute finishes

        A = {32'd1};
        B = {32'd1};

        compute_start = 1;
        #10;
        compute_start = 0;

        #50;
        show_state();
$display("READY=%b RESULT=%h", result_ready, result);
        $display("\n===== TEST COMPLETE =====");
        $finish;

    end

endmodule