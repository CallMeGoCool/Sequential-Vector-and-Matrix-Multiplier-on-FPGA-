//make it pretty version (best version)
module top(

    input clk,

    input [15:0] sw,

    input btnC,
    input btnL,
    input btnR,
    input btnU,
    input btnD,

    output [15:0] led,

    output [6:0] seg,
    output [7:0] an,
    output dp

);

    // ==================================================
    // RESET
    // ==================================================
    wire reset = btnD;

    // ==================================================
    // SWITCH SPLIT
    // ==================================================
    wire [1:0] sw_mode = sw[1:0];
    wire [7:0] sw_data = sw[15:8];

    // ==================================================
    // INTERNAL WIRES
    // ==================================================
    wire [31:0] A, B;
    wire [2:0] cursor;
    wire compute_start;

    wire [79:0] result;
    wire result_ready;

    wire [15:0] led_input;
    wire [15:0] display_data;

    // ==================================================
    // INPUT CONTROLLER
    // ==================================================
    input_controller IC (
        .clk(clk),
        .reset(reset),

        .mode(sw_mode),
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

        .led(led_input)
    );

    // ==================================================
    // COMPUTE CORE
    // ==================================================
    compute_core CC (
        .clk(clk),
        .reset(reset),

        .mode(sw_mode),
        .compute_start(compute_start),

        .A(A),
        .B(B),

        .result(result),
        .result_ready(result_ready)
    );

    // ==================================================
    // DISPLAY CONTROLLER
    // ==================================================
    display_controller DC (
        .clk(clk),
        .reset(reset),

        .mode(sw_mode),
        .cursor(cursor),

        .A(A),
        .B(B),

        .result(result),
        .result_ready(result_ready),

        .display_data(display_data)
    );

    // ==================================================
    // UI (mode + cursor)
    // ==================================================
    wire [3:0] mode_ui =
        (sw_mode == 2'b01) ? 4'd1 :
        (sw_mode == 2'b10) ? 4'd2 :
        4'd0;

    wire [3:0] cursor_ui = {1'b0, cursor};

    // ==================================================
    // ✅ FIXED 7-SEG PACKING (CORRECT DIGIT ORDER)
    // ==================================================
    wire [15:0] seg_data =
    {
        display_data[15:12],
        display_data[11:8],
        display_data[7:4],
        display_data[3:0]
    };

    // ==================================================
    // 7-SEG DRIVER
    // ==================================================
    sevenseg_driver SSD (
        .clk(clk),
        .reset(reset),
        .data(seg_data),
        .seg(seg),
        .an(an),
        .dp(dp)
    );

    // ==================================================
    // LED OUTPUT
    // ==================================================
    assign led[14:0] = led_input[14:0];
    assign led[15]   = result_ready;

endmodule


/*
//works like intended version
module top(

    input clk,

    input [15:0] sw,

    input btnC,
    input btnL,
    input btnR,
    input btnU,
    input btnD,

    output [15:0] led,

    output [6:0] seg,
    output [7:0] an,
    output dp

);

    // ==================================================
    // RESET
    // ==================================================
    wire reset = btnD;

    // ==================================================
    // SWITCH SPLIT
    // ==================================================
    wire [1:0] sw_mode = sw[1:0];
    wire [7:0] sw_data = sw[15:8];

    // ==================================================
    // INTERNAL WIRES
    // ==================================================
    wire [31:0] A, B;
    wire [2:0] cursor;
    wire compute_start;

    wire [79:0] result;
    wire result_ready;

    wire [15:0] led_input;
    wire [15:0] display_data;

    // ==================================================
    // INPUT CONTROLLER
    // ==================================================
    input_controller IC (
        .clk(clk),
        .reset(reset),

        .mode(sw_mode),
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

        .led(led_input)
    );

    // ==================================================
    // COMPUTE CORE
    // ==================================================
    compute_core CC (
        .clk(clk),
        .reset(reset),

        .mode(sw_mode),
        .compute_start(compute_start),

        .A(A),
        .B(B),

        .result(result),
        .result_ready(result_ready)
    );

    // ==================================================
    // DISPLAY CONTROLLER
    // ==================================================
    display_controller DC (
        .clk(clk),
        .reset(reset),

        .mode(sw_mode),
        .cursor(cursor),

        .A(A),
        .B(B),

        .result(result),
        .result_ready(result_ready),

        .display_data(display_data)
    );

    // ==================================================
    // UI PACKING FOR 7-SEG
    // ==================================================
    wire [3:0] mode_ui =
        (sw_mode == 2'b01) ? 4'd1 :
        (sw_mode == 2'b10) ? 4'd2 :
        4'd0;

    wire [3:0] cursor_ui = {1'b0, cursor};

    wire [15:0] seg_data =
    {mode_ui, cursor_ui, display_data[7:0], display_data[15:8]};

    // ==================================================
    // 7-SEG DRIVER
    // ==================================================
    sevenseg_driver SSD (
        .clk(clk),
        .reset(reset),
        .data(seg_data),
        .seg(seg),
        .an(an),
        .dp(dp)
    );

    // ==================================================
    // LED OUTPUT
    // ==================================================
    assign led[14:0] = led_input[14:0];
    assign led[15]   = result_ready;

endmodule
*/

/* Working Version
module top(

    input clk,

    // 🔁 switches
    input [15:0] sw,

    // buttons
    input btnC,
    input btnL,
    input btnR,
    input btnU,
    input btnD,

    output [15:0] led,

    // 7-seg
    output [6:0] seg,
    output [7:0] an,
    output dp

);

    // ==================================================
    // RESET MAPPING (IMPORTANT FIX)
    // ==================================================
    wire reset = btnD;   // 🧠 use btnD as system reset

    // ==================================================
    // MODE + DATA SPLIT
    // ==================================================
    wire [1:0] sw_mode = sw[1:0];
    wire [7:0] sw_data = sw[15:8];

    // ==================================================
    // INTERNAL WIRES
    // ==================================================
    wire [31:0] A, B;
    wire [2:0] cursor;
    wire compute_start;

    wire [79:0] result;
    wire result_ready;

    wire [15:0] led_input;
    wire [15:0] display_data;

    // ==================================================
    // INPUT CONTROLLER
    // ==================================================
    input_controller IC (

        .clk(clk),
        .reset(reset),

        .mode(sw_mode),
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

        .led(led_input)

    );

    // ==================================================
    // COMPUTE CORE
    // ==================================================
    compute_core CC (

        .clk(clk),
        .reset(reset),

        .mode(sw_mode),
        .compute_start(compute_start),

        .A(A),
        .B(B),

        .result(result),
        .result_ready(result_ready)

    );

    // ==================================================
    // DISPLAY CONTROLLER
    // ==================================================
    display_controller DC (

        .clk(clk),
        .reset(reset),

        .mode(sw_mode),
        .cursor(cursor),

        .A(A),
        .B(B),

        .result(result),
        .result_ready(result_ready),

        .display_data(display_data)

    );

    // ==================================================
    // 7-SEG DRIVER
    // ==================================================
    sevenseg_driver SSD (

        .clk(clk),
        .reset(reset),

        .data(display_data),

        .seg(seg),
        .an(an),
        .dp(dp)

    );

    // ==================================================
    // LED OUTPUT
    // ==================================================
    assign led[14:0] = led_input[14:0];
    assign led[15]   = result_ready;

endmodule
*/

/*
module top(

    input clk,
    input reset,

    input [1:0] sw_mode,
    input [7:0] sw_data,

    input btnC,
    input btnL,
    input btnR,
    input btnU,
    input btnD,

    output [15:0] led

);

    // ==================================================
    // INTERNAL WIRES
    // ==================================================
    wire [31:0] A, B;
    wire [2:0] cursor;
    wire compute_start;

    wire [79:0] result;
    wire result_ready;

    wire [15:0] led_input;

    // ==================================================
    // INPUT CONTROLLER
    // ==================================================
    input_controller IC (

        .clk(clk),
        .reset(reset),

        .mode(sw_mode),
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

        .led(led_input)

    );

    // ==================================================
    // COMPUTE CORE (FIXED CONNECTION)
    // ==================================================
    compute_core CC (

        .clk(clk),
        .reset(reset),

        .mode(sw_mode),
        .compute_start(compute_start),

        .A(A),
        .B(B),

        .result(result),
        .result_ready(result_ready)

    );

    // ==================================================
    // LED OUTPUT LOGIC (TEMP DEBUG VISUALIZATION)
    // ==================================================

    // lower 15 LEDs show input controller state
    assign led[14:0] = led_input[14:0];

    // LED[15] shows computation done
    assign led[15] = result_ready;

endmodule
*/