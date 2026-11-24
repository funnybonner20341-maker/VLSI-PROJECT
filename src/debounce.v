`timescale 1ns / 1ps

// Button debouncer: output changes only after input is stable for ~20 ms at 100 MHz
module debounce #(parameter [20:0] CNT_MAX = 21'd2_000_000)
(
    input  wire clk,
    input  wire noisy,
    output reg  clean = 1'b0
);
    reg s0 = 1'b0;
    reg s1 = 1'b0;
    reg [20:0] cnt = 21'd0;

    always @(posedge clk) begin
        s0 <= noisy;
        s1 <= s0;

        if (s1 == clean)
            cnt <= 21'd0;
        else begin
            cnt <= cnt + 1'b1;
            if (cnt == CNT_MAX - 1) begin
                clean <= s1;
                cnt   <= 21'd0;
            end
        end
    end
endmodule


module top (
    input  wire       clk,     // 100 MHz board clock
    input  wire       btnC,    // center button = enter
    input  wire       btnU,    // up button     = reset
    input  wire [3:0] sw,      // switches      = password
    output wire [3:0] led      // led[0]=unlocked, led[1]=alarm, led[3:2]=failed_count
);

    // Reset synchronizer
    reg [1:0] rst_sync = 2'b11;
    always @(posedge clk)
        rst_sync <= {rst_sync[0], btnU};
    wire reset = rst_sync[1];

    // Enter button: debounce, then make a single one-clock pulse
    wire enter_clean;
    reg  enter_d = 1'b0;

    debounce db_enter (
        .clk  (clk),
        .noisy(btnC),
        .clean(enter_clean)
    );

    always @(posedge clk)
        enter_d <= enter_clean;

    wire enter_pulse = enter_clean & ~enter_d;

    // The lock
    wire       unlocked;
    wire       alarm;
    wire [1:0] failed_count;

    digital_lock lock (
        .clk         (clk),
        .reset       (reset),
        .enter       (enter_pulse),
        .password_in (sw),
        .unlocked    (unlocked),
        .alarm       (alarm),
        .failed_count(failed_count)
    );

    assign led = {failed_count, alarm, unlocked};

endmodule