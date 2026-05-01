//best version
module input_controller(

    input clk,
    input reset,

    input [1:0] mode,
    input [7:0] sw_data,

    input btnC,
    input btnL,
    input btnR,
    input btnU,
    input btnD,

    output reg [31:0] A,
    output reg [31:0] B,

    output reg [2:0] cursor,
    output reg compute_start,

    output reg [15:0] led
);

    reg btnC_d, btnL_d, btnR_d, btnU_d, btnD_d;

    wire btnC_pulse = btnC & ~btnC_d;
    wire btnL_pulse = btnL & ~btnL_d;
    wire btnR_pulse = btnR & ~btnR_d;
    wire btnU_pulse = btnU & ~btnU_d;
    wire btnD_pulse = btnD & ~btnD_d;

    reg [1:0] mode_reg;

    // KEEP FULL INPUT RANGE (IMPORTANT)
    wire [2:0] max_index =
        (mode_reg == 2'b01) ? 3 :
        (mode_reg == 2'b10) ? 7 : 0;

    reg compute_req;

    always @(posedge clk) begin

        btnC_d <= btnC;
        btnL_d <= btnL;
        btnR_d <= btnR;
        btnU_d <= btnU;
        btnD_d <= btnD;

        if (reset || btnD_pulse) begin
            A <= 0;
            B <= 0;
            cursor <= 0;
            compute_start <= 0;
            compute_req <= 0;
            led <= 0;
            mode_reg <= mode;
        end

        else begin

            mode_reg <= mode;

            led[1:0] <= mode_reg;
            led[4:2] <= cursor;

            // cursor movement (INPUT SIDE ONLY)
            if (btnR_pulse && cursor < max_index)
                cursor <= cursor + 1;

            if (btnL_pulse && cursor > 0)
                cursor <= cursor - 1;

            // STORE INPUT
            if (btnC_pulse) begin

                led[0] <= 1'b1;

                case (mode_reg)

                    2'b01: begin
                        case (cursor)
                            3'd0: A[7:0]  <= sw_data;
                            3'd1: A[15:8] <= sw_data;
                            3'd2: B[7:0]  <= sw_data;
                            3'd3: B[15:8] <= sw_data;
                        endcase
                    end

                    2'b10: begin
                        case (cursor)
                            3'd0: A[7:0]    <= sw_data;
                            3'd1: A[15:8]   <= sw_data;
                            3'd2: A[23:16]  <= sw_data;
                            3'd3: A[31:24]  <= sw_data;

                            3'd4: B[7:0]    <= sw_data;
                            3'd5: B[15:8]   <= sw_data;
                            3'd6: B[23:16]  <= sw_data;
                            3'd7: B[31:24]  <= sw_data;
                        endcase
                    end

                endcase
            end
            else begin
                led[0] <= 0;
            end

            // compute trigger
            if (btnU_pulse)
                compute_req <= 1'b1;

            compute_start <= compute_req;

            if (compute_start)
                compute_req <= 1'b0;

            // ⭐ IMPORTANT FIX: reset cursor AFTER compute
            if (compute_start && mode_reg == 2'b10)
                cursor <= 3'd0;

        end
    end

endmodule


/*
 Works really well
module input_controller(

    input clk,
    input reset,

    input [1:0] mode,
    input [7:0] sw_data,

    input btnC,
    input btnL,
    input btnR,
    input btnU,
    input btnD,

    output reg [31:0] A,
    output reg [31:0] B,

    output reg [2:0] cursor,
    output reg compute_start,

    output reg [15:0] led
);

    reg btnC_d, btnL_d, btnR_d, btnU_d, btnD_d;

    wire btnC_pulse = btnC & ~btnC_d;
    wire btnL_pulse = btnL & ~btnL_d;
    wire btnR_pulse = btnR & ~btnR_d;
    wire btnU_pulse = btnU & ~btnU_d;
    wire btnD_pulse = btnD & ~btnD_d;

    reg [1:0] mode_reg;

    wire [2:0] max_index =
        (mode_reg == 2'b01) ? 3 :
        (mode_reg == 2'b10) ? 7 : 0;

    // 🔥 NEW: compute staging register
    reg compute_req;

    always @(posedge clk) begin

        // store previous states
        btnC_d <= btnC;
        btnL_d <= btnL;
        btnR_d <= btnR;
        btnU_d <= btnU;
        btnD_d <= btnD;

        if (reset || btnD_pulse) begin
            A <= 0;
            B <= 0;
            cursor <= 0;
            compute_start <= 0;
            compute_req <= 0;
            led <= 0;
            mode_reg <= mode;
        end

        else begin

            // stable mode latch
            mode_reg <= mode;

            led[1:0] <= mode_reg;
            led[4:2] <= cursor;

            // cursor control
            if (btnR_pulse && cursor < max_index)
                cursor <= cursor + 1;

            if (btnL_pulse && cursor > 0)
                cursor <= cursor - 1;

            // input store
            if (btnC_pulse) begin

                led[0] <= 1'b1;

                case (mode_reg)

                    2'b01: begin
                        case (cursor)
                            3'd0: A[7:0]  <= sw_data;
                            3'd1: A[15:8] <= sw_data;
                            3'd2: B[7:0]  <= sw_data;
                            3'd3: B[15:8] <= sw_data;
                        endcase
                    end

                    2'b10: begin
                        case (cursor)
                            3'd0: A[7:0]    <= sw_data;
                            3'd1: A[15:8]   <= sw_data;
                            3'd2: A[23:16]  <= sw_data;
                            3'd3: A[31:24]  <= sw_data;

                            3'd4: B[7:0]    <= sw_data;
                            3'd5: B[15:8]   <= sw_data;
                            3'd6: B[23:16]  <= sw_data;
                            3'd7: B[31:24]  <= sw_data;
                        endcase
                    end

                endcase
            end
            else begin
                led[0] <= 0;
            end

            // 🔥 FIX: buffered compute request
            if (btnU_pulse)
                compute_req <= 1'b1;

            // single-cycle output
            compute_start <= compute_req;

            // reset after trigger
            if (compute_start)
                compute_req <= 1'b0;

        end
    end

endmodule
*/


/* Working Version
module input_controller(

    input clk,
    input reset,

    input [1:0] mode,
    input [7:0] sw_data,

    input btnC,
    input btnL,
    input btnR,
    input btnU,
    input btnD,

    output reg [31:0] A,
    output reg [31:0] B,

    output reg [2:0] cursor,
    output reg compute_start,

    output reg [15:0] led

);

    // -------------------------------------------------
    // EDGE DETECTION REGISTERS
    // -------------------------------------------------
    reg btnC_d, btnL_d, btnR_d, btnU_d, btnD_d;

    wire btnC_pulse = btnC & ~btnC_d;
    wire btnL_pulse = btnL & ~btnL_d;
    wire btnR_pulse = btnR & ~btnR_d;
    wire btnU_pulse = btnU & ~btnU_d;
    wire btnD_pulse = btnD & ~btnD_d;

    // -------------------------------------------------
    // MODE REGISTER (kept for display stability)
    // -------------------------------------------------
    reg [1:0] mode_reg;

    // -------------------------------------------------
    // ✅ FIX: USE DIRECT MODE (NOT mode_reg)
    // -------------------------------------------------
    wire [2:0] max_index =
        (mode == 2'b01) ? 3 :
        (mode == 2'b10) ? 7 : 0;

    // -------------------------------------------------
    // MAIN LOGIC
    // -------------------------------------------------
    always @(posedge clk) begin

        // Store previous button states
        btnC_d <= btnC;
        btnL_d <= btnL;
        btnR_d <= btnR;
        btnU_d <= btnU;
        btnD_d <= btnD;

        // -------------------------------------------------
        // RESET
        // -------------------------------------------------
        if (reset || btnD_pulse) begin
            A <= 32'd0;
            B <= 32'd0;
            cursor <= 0;
            compute_start <= 0;
            led <= 16'd0;
            mode_reg <= mode;
        end

        else begin

            // latch mode for display
            mode_reg <= mode;

            // -------------------------------------------------
            // LED MODE DISPLAY
            // -------------------------------------------------
            led[1:0] <= mode_reg;

            // -------------------------------------------------
            // CURSOR NAVIGATION
            // -------------------------------------------------
            if (btnR_pulse && cursor < max_index)
                cursor <= cursor + 1;

            if (btnL_pulse && cursor > 0)
                cursor <= cursor - 1;

            // -------------------------------------------------
            // STORE INPUT (btnC)
            // -------------------------------------------------
            if (btnC_pulse) begin

                led[0] <= 1'b1; // blink

                case (mode_reg)

                    // ---------------- VECTOR ----------------
                    2'b01: begin
                        case (cursor)
                            3'd0: A[7:0]   <= sw_data;
                            3'd1: A[15:8]  <= sw_data;
                            3'd2: B[7:0]   <= sw_data;
                            3'd3: B[15:8]  <= sw_data;
                        endcase
                    end

                    // ---------------- MATRIX ----------------
                    2'b10: begin
                        case (cursor)
                            3'd0: A[7:0]   <= sw_data;
                            3'd1: A[15:8]  <= sw_data;
                            3'd2: A[23:16] <= sw_data;
                            3'd3: A[31:24] <= sw_data;

                            3'd4: B[7:0]   <= sw_data;
                            3'd5: B[15:8]  <= sw_data;
                            3'd6: B[23:16] <= sw_data;
                            3'd7: B[31:24] <= sw_data;
                        endcase
                    end

                endcase
            end
            else begin
                led[0] <= 1'b0;
            end

            // -------------------------------------------------
            // COMPUTE START (1-cycle pulse)
            // -------------------------------------------------
            if (btnU_pulse)
                compute_start <= 1'b1;
            else
                compute_start <= 1'b0;

            // -------------------------------------------------
            // CURSOR DISPLAY
            // -------------------------------------------------
            led[4:2] <= cursor;

        end
    end

endmodule
*/
/*
module input_controller(

    input clk,
    input reset,

    input [1:0] mode,
    input [7:0] sw_data,

    input btnC,
    input btnL,
    input btnR,
    input btnU,
    input btnD,

    output reg [31:0] A,
    output reg [31:0] B,

    output reg [2:0] cursor,
    output reg compute_start,

    output reg [15:0] led

);

    // =====================================================
    // BUTTON SYNCHRONIZATION (2-STAGE)
    // =====================================================
    reg btnC_s0, btnC_s1;
    reg btnL_s0, btnL_s1;
    reg btnR_s0, btnR_s1;
    reg btnU_s0, btnU_s1;
    reg btnD_s0, btnD_s1;

    always @(posedge clk) begin
        btnC_s0 <= btnC;  btnC_s1 <= btnC_s0;
        btnL_s0 <= btnL;  btnL_s1 <= btnL_s0;
        btnR_s0 <= btnR;  btnR_s1 <= btnR_s0;
        btnU_s0 <= btnU;  btnU_s1 <= btnU_s0;
        btnD_s0 <= btnD;  btnD_s1 <= btnD_s0;
    end

    // =====================================================
    // EDGE DETECTION (PULSES)
    // =====================================================
    wire btnC_pulse = btnC_s1 & ~btnC_s0;
    wire btnL_pulse = btnL_s1 & ~btnL_s0;
    wire btnR_pulse = btnR_s1 & ~btnR_s0;
    wire btnU_pulse = btnU_s1 & ~btnU_s0;
    wire btnD_pulse = btnD_s1 & ~btnD_s0;

    // =====================================================
    // MODE REGISTER (LOCKED DURING COMPUTE)
    // =====================================================
    reg [1:0] mode_reg;

    // =====================================================
    // CURSOR LIMIT
    // =====================================================
    wire [2:0] max_index =
        (mode_reg == 2'b01) ? 3 :   // vector (4 values)
        (mode_reg == 2'b10) ? 7 : 0; // matrix (8 values)

    // =====================================================
    // MAIN LOGIC
    // =====================================================
    always @(posedge clk) begin

        // ---------------- RESET ----------------
        if (reset || btnD_pulse) begin

            A <= 32'd0;
            B <= 32'd0;
            cursor <= 0;
            compute_start <= 0;
            led <= 16'd0;

            mode_reg <= mode;

        end

        else begin

            // ---------------- MODE DISPLAY ----------------
            led[1:0] <= mode;

            // ---------------- CURSOR NAVIGATION ----------------
            if (btnR_pulse && cursor < max_index)
                cursor <= cursor + 1;

            if (btnL_pulse && cursor > 0)
                cursor <= cursor - 1;

            // ---------------- STORE INPUT ----------------
            if (btnC_pulse) begin

                // quick blink indicator
                led[0] <= 1'b1;

                case (mode_reg)

                    // -------- VECTOR MODE --------
                    2'b01: begin
                        case (cursor)
                            3'd0: A[7:0]   <= sw_data;
                            3'd1: A[15:8]  <= sw_data;
                            3'd2: B[7:0]   <= sw_data;
                            3'd3: B[15:8]  <= sw_data;
                        endcase
                    end

                    // -------- MATRIX MODE --------
                    2'b10: begin
                        case (cursor)
                            3'd0: A[7:0]   <= sw_data;   // A00
                            3'd1: A[15:8]  <= sw_data;   // A01
                            3'd2: A[23:16] <= sw_data;   // A10
                            3'd3: A[31:24] <= sw_data;   // A11

                            3'd4: B[7:0]   <= sw_data;   // B00
                            3'd5: B[15:8]  <= sw_data;   // B01
                            3'd6: B[23:16] <= sw_data;   // B10
                            3'd7: B[31:24] <= sw_data;   // B11
                        endcase
                    end

                endcase

            end
            else begin
                led[0] <= 1'b0;
            end

            // ---------------- COMPUTE START ----------------
            if (btnU_pulse) begin
                compute_start <= 1'b1;
                mode_reg <= mode;   // LOCK mode at start
            end
            else begin
                compute_start <= 1'b0;
            end

            // ---------------- CURSOR DISPLAY ----------------
            led[4:2] <= cursor;

            // led[15] reserved for result_ready (from compute_core)

        end
    end

endmodule
*/
/*
module input_controller(

    input clk,
    input reset,

    input [1:0] mode,
    input [7:0] sw_data,

    input btnC,
    input btnL,
    input btnR,
    input btnU,
    input btnD,

    output reg [31:0] A,
    output reg [31:0] B,

    output reg [2:0] cursor,
    output reg compute_start,

    output reg [15:0] led

);

    // -------------------------------------------------
    // EDGE DETECTION REGISTERS (IMPORTANT FOR FPGA)
    // -------------------------------------------------
    reg btnC_d, btnL_d, btnR_d, btnU_d, btnD_d;

    wire btnC_pulse = btnC & ~btnC_d;
    wire btnL_pulse = btnL & ~btnL_d;
    wire btnR_pulse = btnR & ~btnR_d;
    wire btnU_pulse = btnU & ~btnU_d;
    wire btnD_pulse = btnD & ~btnD_d;

    // -------------------------------------------------
    // MODE REGISTER (STABLE DURING OPERATION)
    // -------------------------------------------------
    reg [1:0] mode_reg;

    // -------------------------------------------------
    // CURSOR LIMIT LOGIC
    // -------------------------------------------------
    wire [2:0] max_index =
        (mode_reg == 2'b01) ? 3 :   // vector
        (mode_reg == 2'b10) ? 7 : 0;

    // -------------------------------------------------
    // RESET + STATE UPDATE
    // -------------------------------------------------
    integer i;

    always @(posedge clk) begin

        // -------------------------------------------------
        // STORE OLD BUTTON STATES
        // -------------------------------------------------
        btnC_d <= btnC;
        btnL_d <= btnL;
        btnR_d <= btnR;
        btnU_d <= btnU;
        btnD_d <= btnD;

        // -------------------------------------------------
        // RESET
        // -------------------------------------------------
        if (reset || btnD_pulse) begin

            A <= 32'd0;
            B <= 32'd0;
            cursor <= 0;
            compute_start <= 0;

            led <= 16'd0;
            mode_reg <= mode;

        end

        else begin

            // -------------------------------------------------
            // LATCH MODE (IMPORTANT)
            // -------------------------------------------------
            mode_reg <= mode;

            // -------------------------------------------------
            // LED MODE DISPLAY
            // -------------------------------------------------
            led[1:0] <= mode_reg;

            // -------------------------------------------------
            // CURSOR NAVIGATION
            // -------------------------------------------------
            if (btnR_pulse && cursor < max_index)
                cursor <= cursor + 1;

            if (btnL_pulse && cursor > 0)
                cursor <= cursor - 1;

            // -------------------------------------------------
            // STORE INPUT (btnC)
            // -------------------------------------------------
            if (btnC_pulse) begin

                // blink indicator
                led[0] <= 1'b1;

                case (mode_reg)

                    // ---------------- VECTOR MODE ----------------
                    2'b01: begin
                        case (cursor)
                            3'd0: A[7:0]   <= sw_data;
                            3'd1: A[15:8]  <= sw_data;
                            3'd2: B[7:0]   <= sw_data;
                            3'd3: B[15:8]  <= sw_data;
                        endcase
                    end

                    // ---------------- MATRIX MODE ----------------
                    2'b10: begin
                        case (cursor)
                            3'd0: A[7:0]   <= sw_data;   // A00
                            3'd1: A[15:8]  <= sw_data;   // A01
                            3'd2: A[23:16] <= sw_data;   // A10
                            3'd3: A[31:24] <= sw_data;   // A11

                            3'd4: B[7:0]   <= sw_data;   // B00
                            3'd5: B[15:8]  <= sw_data;   // B01
                            3'd6: B[23:16] <= sw_data;   // B10
                            3'd7: B[31:24] <= sw_data;   // B11
                        endcase
                    end

                endcase
            end
            else begin
                led[0] <= 1'b0;
            end

            // -------------------------------------------------
            // COMPUTE START (PULSE)
            // -------------------------------------------------
            if (btnU_pulse)
                compute_start <= 1'b1;
            else
                compute_start <= 1'b0;

            // -------------------------------------------------
            // CURSOR DISPLAY ON LEDS
            // -------------------------------------------------
            led[4:2] <= cursor;

            // result_ready will be wired from compute_core later
            // led[15] reserved

        end
    end

endmodule
*/