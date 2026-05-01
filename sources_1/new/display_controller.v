//works best
module display_controller(

    input clk,
    input reset,

    input [1:0] mode,
    input [2:0] cursor,

    input [31:0] A,
    input [31:0] B,

    input [79:0] result,
    input result_ready,

    output reg [15:0] display_data

);

    // ==================================================
    // MATRIX RESULT SPLIT (20-bit FIXED)
    // ==================================================
    wire [19:0] C00 = result[79:60];
    wire [19:0] C01 = result[59:40];
    wire [19:0] C10 = result[39:20];
    wire [19:0] C11 = result[19:0];

    reg [7:0] data_byte;

    always @(*) begin

        display_data = 16'd0;
        data_byte = 8'd0;

        // ==================================================
        // INPUT MODE (before compute)
        // ==================================================
        if (!result_ready) begin

            case (mode)

                // ---------------- VECTOR MODE ----------------
                2'b01: begin
                    case (cursor)
                        3'd0: data_byte = A[7:0];
                        3'd1: data_byte = A[15:8];
                        3'd2: data_byte = B[7:0];
                        3'd3: data_byte = B[15:8];
                        default: data_byte = 8'd0;
                    endcase
                end

                // ---------------- MATRIX MODE ----------------
                2'b10: begin
                    case (cursor)
                        3'd0: data_byte = A[7:0];
                        3'd1: data_byte = A[15:8];
                        3'd2: data_byte = A[23:16];
                        3'd3: data_byte = A[31:24];

                        3'd4: data_byte = B[7:0];
                        3'd5: data_byte = B[15:8];
                        3'd6: data_byte = B[23:16];
                        3'd7: data_byte = B[31:24];

                        default: data_byte = 8'd0;
                    endcase
                end

                default: data_byte = 8'd0;

            endcase

        end

        // ==================================================
        // RESULT MODE (after compute)
        // ==================================================
        else begin

            case (mode)

                // ---------------- VECTOR ----------------
                2'b01: begin
                    data_byte = result[7:0];
                end

                // ---------------- MATRIX ----------------
                2'b10: begin
                    case (cursor[1:0])
                        2'd0: data_byte = C00[7:0];
                        2'd1: data_byte = C01[7:0];
                        2'd2: data_byte = C10[7:0];
                        2'd3: data_byte = C11[7:0];
                        default: data_byte = 8'd0;
                    endcase
                end

                default: data_byte = 8'd0;

            endcase

        end

        // ==================================================
        // FINAL OUTPUT
        // ==================================================
        display_data = {8'd0, data_byte};

    end

endmodule

/* Working Version
module display_controller(

    input clk,
    input reset,

    input [1:0] mode,
    input [2:0] cursor,

    input [31:0] A,
    input [31:0] B,

    input [79:0] result,
    input result_ready,

    output reg [15:0] display_data

);

    // ============================================
    // MATRIX RESULT EXTRACTION
    // ============================================
    wire [19:0] C00 = result[79:60];
    wire [19:0] C01 = result[59:40];
    wire [19:0] C10 = result[39:20];
    wire [19:0] C11 = result[19:0];

    always @(*) begin

        display_data = 16'd0;

        // ============================================
        // BEFORE COMPUTE → SHOW INPUTS
        // ============================================
        if (!result_ready) begin

            case (mode)

                // ================= VECTOR =================
                2'b01: begin
                    case (cursor)
                        3'd0: display_data = A[7:0];
                        3'd1: display_data = A[15:8];
                        3'd2: display_data = B[7:0];
                        3'd3: display_data = B[15:8];
                        default: display_data = 16'd0;
                    endcase
                end

                // ================= MATRIX =================
                2'b10: begin
                    case (cursor)
                        3'd0: display_data = A[7:0];
                        3'd1: display_data = A[15:8];
                        3'd2: display_data = A[23:16];
                        3'd3: display_data = A[31:24];

                        3'd4: display_data = B[7:0];
                        3'd5: display_data = B[15:8];
                        3'd6: display_data = B[23:16];
                        3'd7: display_data = B[31:24];

                        default: display_data = 16'd0;
                    endcase
                end

                default: display_data = 16'd0;

            endcase

        end

        // ============================================
        // AFTER COMPUTE → SHOW RESULT
        // ============================================
        else begin

            case (mode)

                // ================= VECTOR =================
                2'b01: begin
                    display_data = result[15:0]; // dot product
                end

                // ================= MATRIX =================
                2'b10: begin
                    case (cursor[1:0]) // reuse cursor for navigation
                        2'd0: display_data = C00[15:0];
                        2'd1: display_data = C01[15:0];
                        2'd2: display_data = C10[15:0];
                        2'd3: display_data = C11[15:0];
                    endcase
                end

                default: display_data = 16'd0;

            endcase

        end

    end

endmodule
*/