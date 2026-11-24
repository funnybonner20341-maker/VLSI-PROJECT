`timescale 1ns / 1ps

module digital_lock (
    input  wire       clk,
    input  wire       reset,
    input  wire       enter,
    input  wire [3:0] password_in,

    output reg        unlocked,
    output reg        alarm,
    output reg [1:0]  failed_count
);

    // Correct password = 1011
    parameter [3:0] CORRECT_PASSWORD = 4'b1011;

    // FSM states
    parameter LOCKED   = 2'b00;
    parameter UNLOCKED = 2'b01;
    parameter ALARM    = 2'b10;

    reg [1:0] state;

    always @(posedge clk or posedge reset) begin

        if (reset) begin
            state        <= LOCKED;
            failed_count <= 2'b00;
            unlocked     <= 1'b0;
            alarm        <= 1'b0;
        end

        else begin

            case (state)

                // LOCKED STATE
                LOCKED: begin
                    unlocked <= 1'b0;
                    alarm    <= 1'b0;

                    if (enter) begin

                        if (password_in == CORRECT_PASSWORD) begin
                            // Correct password
                            state    <= UNLOCKED;
                            unlocked <= 1'b1;
                        end

                        else begin
                            // Wrong password
                            if (failed_count == 2'd2) begin
                                // Third failed attempt
                                failed_count <= 2'd3;
                                state        <= ALARM;
                                alarm        <= 1'b1;
                            end

                            else begin
                                failed_count <= failed_count + 1'b1;
                            end
                        end
                    end
                end

                // UNLOCKED STATE
                UNLOCKED: begin
                    unlocked <= 1'b1;
                    alarm    <= 1'b0;
                end

                // ALARM STATE
                ALARM: begin
                    unlocked <= 1'b0;
                    alarm    <= 1'b1;
                end

                default: begin
                    state        <= LOCKED;
                    failed_count <= 2'b00;
                    unlocked     <= 1'b0;
                    alarm        <= 1'b0;
                end

            endcase
        end
    end

endmodule