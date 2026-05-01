`timescale 1ns/1ps

module tb_input_controller;

    // ---------------- DUT SIGNALS ----------------
    reg clk;
    reg reset;

    reg [1:0] mode;
    reg [7:0] sw_data;

    reg btnC, btnL, btnR, btnU, btnD;

    wire [31:0] A, B;
    wire [2:0] cursor;
    wire compute_start;
    wire [15:0] led;

    // ---------------- DUT ----------------
    input_controller DUT (
        .clk(clk),
        .reset(reset),
        .mode(mode),
        .sw_data(sw_data),
        .btnC(btnC),
        .btnL(btnL),
        .btnR(btnR),
        .btnU(btnU),
        .btnD(btnD),
        .A(A),
        .B(B),
        .cursor(cursor),
        .compute_start(compute_start),
        .led(led)
    );

    // ---------------- CLOCK ----------------
    always #5 clk = ~clk;

    // ---------------- EVENT MONITOR ----------------
    always @(posedge clk) begin

        if (btnC || btnR || btnL || btnU || btnD || reset) begin
            $display("t=%0t | mode=%b | cursor=%0d | A=%h | B=%h | led=%b | start=%b",
                     $time, mode, cursor, A, B, led, compute_start);
        end

    end

    // ---------------- STIMULUS ----------------
    initial begin

        $display("===== INPUT CONTROLLER TEST START =====");

        clk = 0;
        reset = 1;

        mode = 0;
        sw_data = 0;

        btnC = 0;
        btnL = 0;
        btnR = 0;
        btnU = 0;
        btnD = 0;

        #20;
        reset = 0;

        // ==================================================
        // VECTOR MODE TEST
        // ==================================================
        mode = 2'b01;

        sw_data = 8'd10;
        btnC = 1; #10; btnC = 0;

        btnR = 1; #10; btnR = 0;

        sw_data = 8'd20;
        btnC = 1; #10; btnC = 0;

        btnR = 1; #10; btnR = 0;

        sw_data = 8'd2;
        btnC = 1; #10; btnC = 0;

        btnR = 1; #10; btnR = 0;

        sw_data = 8'd3;
        btnC = 1; #10; btnC = 0;

        $display("VECTOR DONE => A=%h B=%h", A, B);

        // ==================================================
        // MATRIX MODE TEST
        // ==================================================
        mode = 2'b10;
        #20;

        sw_data = 8'd1;  btnC = 1; #10; btnC = 0;
        btnR = 1; #10; btnR = 0;

        sw_data = 8'd2;  btnC = 1; #10; btnC = 0;
        btnR = 1; #10; btnR = 0;

        sw_data = 8'd3;  btnC = 1; #10; btnC = 0;
        btnR = 1; #10; btnR = 0;

        sw_data = 8'd4;  btnC = 1; #10; btnC = 0;
        btnR = 1; #10; btnR = 0;

        sw_data = 8'd5;  btnC = 1; #10; btnC = 0;
        btnR = 1; #10; btnR = 0;

        sw_data = 8'd6;  btnC = 1; #10; btnC = 0;
        btnR = 1; #10; btnR = 0;

        sw_data = 8'd7;  btnC = 1; #10; btnC = 0;
        btnR = 1; #10; btnR = 0;

        sw_data = 8'd8;  btnC = 1; #10; btnC = 0;

        $display("MATRIX DONE => A=%h B=%h", A, B);

        // ==================================================
        // COMPUTE TEST
        // ==================================================
        btnU = 1; #10; btnU = 0;

        $display("COMPUTE STARTED");

        #50;

        $display("===== TEST COMPLETE =====");

        $finish;

    end

endmodule