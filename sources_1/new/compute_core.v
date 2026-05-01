//best version
module compute_core(

    input clk,
    input reset,

    input [1:0] mode,
    input compute_start,

    input [31:0] A,
    input [31:0] B,

    output reg [79:0] result,
    output reg result_ready
);

    // -----------------------------
    // MODE + FSM
    // -----------------------------
    reg [1:0] mode_reg;

    localparam IDLE = 2'b00;
    localparam BUSY = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state;

    // -----------------------------
    // VECTOR UNIT
    // -----------------------------
    wire [19:0] v_result;

    vector_unit VU (
        .A0(A[7:0]),
        .A1(A[15:8]),
        .B0(B[7:0]),
        .B1(B[15:8]),
        .result(v_result)
    );

    // -----------------------------
    // MATRIX UNIT
    // -----------------------------
    wire [19:0] C00, C01, C10, C11;

    matrix_unit MU (
        .A00(A[7:0]),
        .A01(A[15:8]),
        .A10(A[23:16]),
        .A11(A[31:24]),

        .B00(B[7:0]),
        .B01(B[15:8]),
        .B10(B[23:16]),
        .B11(B[31:24]),

        .C00(C00),
        .C01(C01),
        .C10(C10),
        .C11(C11)
    );

    // -----------------------------
    // FSM
    // -----------------------------
    always @(posedge clk) begin

        if (reset) begin
            state <= IDLE;
            result <= 80'd0;
            result_ready <= 1'b0;
            mode_reg <= 2'd0;
        end

        else begin

            case (state)

                // ================= IDLE =================
                IDLE: begin
                    result_ready <= 1'b0;

                    if (compute_start) begin
                        mode_reg <= mode;
                        state <= BUSY;
                    end
                end

                // ================= BUSY =================
                BUSY: begin

                    if (mode_reg == 2'b01) begin
                        result <= {60'd0, v_result};
                    end

                    else if (mode_reg == 2'b10) begin
                        result <= {
                            C00[19:0],
                            C01[19:0],
                            C10[19:0],
                            C11[19:0]
                        };
                    end

                    else begin
                        result <= 80'd0;
                    end

                    state <= DONE;
                end

                // ================= DONE =================
                DONE: begin
                    result_ready <= 1'b1;

                    if (compute_start) begin
                        result_ready <= 1'b0;
                        state <= BUSY;
                        mode_reg <= mode;
                    end
                end

            endcase

        end
    end

endmodule

/*
module compute_core(

    input clk,
    input reset,

    input [1:0] mode,
    input compute_start,

    input [31:0] A,
    input [31:0] B,

    output reg [79:0] result,
    output reg result_ready
);

    reg [1:0] mode_reg;

    localparam IDLE = 2'b00;
    localparam BUSY = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state;

    wire [19:0] v_result;

    vector_unit VU (
        .A0(A[7:0]),
        .A1(A[15:8]),
        .B0(B[7:0]),
        .B1(B[15:8]),
        .result(v_result)
    );

    wire [19:0] C00, C01, C10, C11;

    matrix_unit MU (
        .A00(A[7:0]),
        .A01(A[15:8]),
        .A10(A[23:16]),
        .A11(A[31:24]),

        .B00(B[7:0]),
        .B01(B[15:8]),
        .B10(B[23:16]),
        .B11(B[31:24]),

        .C00(C00),
        .C01(C01),
        .C10(C10),
        .C11(C11)
    );

    always @(posedge clk) begin

        if (reset) begin
            state <= IDLE;
            result <= 0;
            result_ready <= 0;
            mode_reg <= 0;
        end

        else begin

            case (state)

                IDLE: begin
                    result_ready <= 0;

                    if (compute_start) begin
                        mode_reg <= mode;
                        state <= BUSY;
                    end
                end

                BUSY: begin

                    if (mode_reg == 2'b01) begin
                        result <= {60'd0, v_result};
                    end

                    else if (mode_reg == 2'b10) begin
                        result <= {C00, C01, C10, C11}; // ✅ FIXED
                    end

                    else begin
                        result <= 0;
                    end

                    state <= DONE;
                end

                DONE: begin
                    result_ready <= 1'b1;

                    if (compute_start) begin
                        result_ready <= 0;
                        state <= BUSY;
                        mode_reg <= mode;
                    end
                end

            endcase

        end
    end

endmodule
*/

/*
module compute_core(

    input clk,
    input reset,

    input [1:0] mode,
    input compute_start,

    input [31:0] A,
    input [31:0] B,

    output reg [79:0] result,
    output reg result_ready

);

    reg [1:0] mode_reg;

    localparam IDLE = 2'b00;
    localparam BUSY = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state;

    wire [19:0] v_result;

    vector_unit VU (
        .A0(A[7:0]),
        .A1(A[15:8]),
        .B0(B[7:0]),
        .B1(B[15:8]),
        .result(v_result)
    );

    wire [19:0] C00, C01, C10, C11;

    matrix_unit MU (
        .A00(A[7:0]),
        .A01(A[15:8]),
        .A10(A[23:16]),
        .A11(A[31:24]),

        .B00(B[7:0]),
        .B01(B[15:8]),
        .B10(B[23:16]),
        .B11(B[31:24]),

        .C00(C00),
        .C01(C01),
        .C10(C10),
        .C11(C11)
    );

    always @(posedge clk) begin

        if (reset) begin
            state <= IDLE;
            result <= 0;
            result_ready <= 0;
            mode_reg <= 0;
        end

        else begin

            case (state)

                // ================= IDLE =================
                IDLE: begin
                    result_ready <= 0;

                    if (compute_start) begin
                        mode_reg <= mode;
                        state <= BUSY;
                    end
                end

                // ================= BUSY =================
                BUSY: begin

                    // latch result AFTER combinational stabilizes
                    if (mode_reg == 2'b01) begin
                        result <= {60'd0, v_result};
                    end
                    else if (mode_reg == 2'b10) begin
                        result <= {
                            16'd0, C00,
                            16'd0, C01,
                            16'd0, C10,
                            16'd0, C11
                        };
                    end
                    else begin
                        result <= 0;
                    end

                    state <= DONE;
                end

                // ================= DONE =================
                DONE: begin
                    result_ready <= 1'b1;

                    if (compute_start) begin
                        result_ready <= 0;
                        state <= BUSY;
                        mode_reg <= mode;
                    end
                end

            endcase

        end
    end

endmodule
*/

/* Was working
module compute_core(

    input clk,
    input reset,

    input [1:0] mode,
    input compute_start,

    input [31:0] A,
    input [31:0] B,

    output reg [79:0] result,
    output reg result_ready

);

    // -----------------------------
    // MODE REGISTER (STABLE)
    // -----------------------------
    reg [1:0] mode_reg;

    // FSM STATES
    localparam IDLE = 2'b00;
    localparam BUSY = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state;

    // -----------------------------
    // VECTOR UNIT
    // -----------------------------
    wire [19:0] v_result;

    vector_unit VU (
        .A0(A[7:0]),
        .A1(A[15:8]),
        .B0(B[7:0]),
        .B1(B[15:8]),
        .result(v_result)
    );

    // -----------------------------
    // MATRIX UNIT
    // -----------------------------
    wire [19:0] C00, C01, C10, C11;

    matrix_unit MU (
        .A00(A[7:0]),
        .A01(A[15:8]),
        .A10(A[23:16]),
        .A11(A[31:24]),

        .B00(B[7:0]),
        .B01(B[15:8]),
        .B10(B[23:16]),
        .B11(B[31:24]),

        .C00(C00),
        .C01(C01),
        .C10(C10),
        .C11(C11)
    );

    // -----------------------------
    // FSM LOGIC
    // -----------------------------
    always @(posedge clk) begin

        if (reset) begin
            state <= IDLE;
            result <= 0;
            result_ready <= 0;
            mode_reg <= 0;
        end

        else begin

            case (state)

                // ================= IDLE =================
                IDLE: begin
                    result_ready <= 0;

                    if (compute_start) begin
                        mode_reg <= mode;   // ✅ latch mode ONLY here
                        state <= BUSY;
                    end
                end

                // ================= BUSY =================
                BUSY: begin

                    // Perform computation
                    if (mode_reg == 2'b01) begin
                        result <= {60'b0, v_result};
                    end
                    else if (mode_reg == 2'b10) begin
                        result <= {
                            20'b0, C00,
                            20'b0, C01,
                            20'b0, C10,
                            20'b0, C11
                        };
                    end
                    else begin
                        result <= 0; // safety
                    end

                    state <= DONE;
                end

                // ================= DONE =================
                DONE: begin
                    result_ready <= 1'b1;

                    // Restart computation if button pressed again
                    if (compute_start) begin
                        result_ready <= 0;
                        mode_reg <= mode;   // latch new mode again
                        state <= BUSY;
                    end
                end

            endcase

        end
    end

endmodule
*/