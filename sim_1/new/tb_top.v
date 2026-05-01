`timescale 1ns / 1ps

module tb_top;

    reg clk;
    reg reset;

    reg [1:0] sw_mode;
    reg [7:0] sw_data;

    reg btnC, btnL, btnR, btnU, btnD;

    wire [15:0] led;

    // DUT
    top uut (
        .clk(clk),
        .reset(reset),
        .sw_mode(sw_mode),
        .sw_data(sw_data),
        .btnC(btnC),
        .btnL(btnL),
        .btnR(btnR),
        .btnU(btnU),
        .btnD(btnD),
        .led(led)
    );

    // CLOCK
    always #5 clk = ~clk;

    // BUTTON TASKS
    task pressC; begin btnC=1; #40; btnC=0; #40; end endtask
    task pressR; begin btnR=1; #40; btnR=0; #40; end endtask
    task pressU; begin btnU=1; #40; btnU=0; #40; end endtask

    // RESULT PRINT
    always @(posedge led[15]) begin
        #1;
        $display("\n>>> RESULT READY @ %0t", $time);
        $display(">>> RESULT = %d\n", uut.CC.result[31:0]);
    end

    initial begin

        $display("========== TB FINAL CLEAN ==========");

        clk = 0;
        reset = 1;

        sw_mode = 0;
        sw_data = 0;

        btnC=0; btnL=0; btnR=0; btnU=0; btnD=0;

        #50;
        reset = 0;

        // ================= VECTOR =================
        $display("\n--- VECTOR MODE ---");

        sw_mode = 2'b01;
        #100;

        // A0 = 3
        sw_data = 8'd3; pressC();
        pressR();

        // A1 = 0
        sw_data = 8'd0; pressC();
        pressR();

        // B0 = 2
        sw_data = 8'd2; pressC();
        pressR();

        // B1 = 1
        sw_data = 8'd1; pressC();

        $display("VECTOR INPUT DONE");

        #100;

        // COMPUTE
        pressU();

        #300;

        $display("========== END ==========");
        $stop;

    end

endmodule