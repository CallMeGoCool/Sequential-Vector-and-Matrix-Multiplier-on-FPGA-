//best version
module sevenseg_driver(

    input clk,
    input reset,

    input [15:0] data,

    output reg [7:0] an,
    output reg [6:0] seg,
    output reg dp

);

    // ============================================
    // CLOCK DIVIDER
    // ============================================
    reg [16:0] counter;
    reg [1:0] digit_sel;   // FIX: only 0-3 needed

    always @(posedge clk) begin
        if (reset) begin
            counter   <= 0;
            digit_sel <= 0;
        end else begin
            counter <= counter + 1;

            // slow scan
            digit_sel <= counter[16:15];
        end
    end

    // ============================================
    // DIGIT SELECT
    // ============================================
    reg [3:0] digit;

    always @(*) begin

        an    = 8'b11111111;
        digit = 4'd0;

        case (digit_sel)

            2'b00: begin an = 8'b11111110; digit = data[3:0];   end
            2'b01: begin an = 8'b11111101; digit = data[7:4];   end
            2'b10: begin an = 8'b11111011; digit = data[11:8];  end
            2'b11: begin an = 8'b11110111; digit = data[15:12]; end

        endcase

    end

    // ============================================
    // HEX DECODER
    // ============================================
    always @(*) begin
        case (digit)

            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;

            default: seg = 7'b1111111;

        endcase
    end

    always @(*) begin
        dp = 1'b1;
    end

endmodule

/*
module sevenseg_driver(

    input clk,
    input reset,

    input [15:0] data,

    output reg [7:0] an,   // ✅ 8 digits now
    output reg [6:0] seg,
    output reg dp

);

    // ============================================
    // CLOCK DIVIDER
    // ============================================
    reg [16:0] counter;
    reg [2:0] digit_sel;

    always @(posedge clk) begin
        if (reset) begin
            counter   <= 0;
            digit_sel <= 0;
        end else begin
            counter   <= counter + 1;
            digit_sel <= counter[16:14]; // slower refresh for 8 digits
        end
    end

    // ============================================
    // SELECT DIGIT
    // ============================================
    reg [3:0] digit;

    always @(*) begin

        // default (all OFF)
        an    = 8'b11111111;
        digit = 4'd0;

        case (digit_sel)

            // ---- USE ONLY 4 RIGHTMOST DIGITS ----
            3'b000: begin an = 8'b11111110; digit = data[3:0];   end
            3'b001: begin an = 8'b11111101; digit = data[7:4];   end
            3'b010: begin an = 8'b11111011; digit = data[11:8];  end
            3'b011: begin an = 8'b11110111; digit = data[15:12]; end

            // ---- UNUSED DIGITS OFF ----
            default: begin
                an    = 8'b11111111;
                digit = 4'd0;
            end

        endcase
    end

    // ============================================
    // HEX → 7 SEG
    // ============================================
    always @(*) begin
        case (digit)

            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;

            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;

            default: seg = 7'b1111111;

        endcase
    end

    // ============================================
    // DECIMAL POINT
    // ============================================
    always @(*) begin
        dp = 1'b1; // OFF
    end

endmodule
*/


/*
module sevenseg_driver(

    input clk,
    input reset,

    input [15:0] data,

    output reg [3:0] an,
    output reg [6:0] seg

);

    reg [1:0] digit_sel;
    reg [3:0] digit;

    // Clock divider (slow refresh)
    reg [15:0] counter;

    always @(posedge clk) begin
        counter <= counter + 1;
        digit_sel <= counter[15:14];
    end

    // Digit select
    always @(*) begin
        case (digit_sel)
            2'b00: begin an = 4'b1110; digit = data[3:0]; end
            2'b01: begin an = 4'b1101; digit = data[7:4]; end
            2'b10: begin an = 4'b1011; digit = data[11:8]; end
            2'b11: begin an = 4'b0111; digit = data[15:12]; end
        endcase
    end

    // 7-seg decoder (hex)
    always @(*) begin
        case (digit)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
        endcase
    end

endmodule
*/