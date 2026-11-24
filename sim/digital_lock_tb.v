`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.09.2026 10:40:28
// Design Name: 
// Module Name: digital_lock_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module digital_lock_tb;

    reg clk;
    reg reset;
    reg enter;
    reg [3:0] password_in;

    wire unlocked;
    wire alarm;
    wire [1:0] failed_count;

    // Instantiate the Digital Lock
    digital_lock uut (
        .clk(clk),
        .reset(reset),
        .enter(enter),
        .password_in(password_in),
        .unlocked(unlocked),
        .alarm(alarm),
        .failed_count(failed_count)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin

        // Initial values
        clk         = 0;
        reset       = 1;
        enter       = 0;
        password_in = 4'b0000;

        // Reset the system
        #10;
        reset = 0;

        // --------------------------------
        // TEST 1: Wrong password
        // --------------------------------
        #10;
        password_in = 4'b0110;
        enter = 1;

        #10;
        enter = 0;

        // --------------------------------
        // TEST 2: Wrong password
        // --------------------------------
        #10;
        password_in = 4'b1000;
        enter = 1;

        #10;
        enter = 0;

        // --------------------------------
        // TEST 3: Wrong password
        // Should activate ALARM
        // --------------------------------
        #10;
        password_in = 4'b0010;
        enter = 1;

        #10;
        enter = 0;

        // Wait
        #20;

        // --------------------------------
        // RESET
        // --------------------------------
        reset = 1;

        #10;
        reset = 0;

        // --------------------------------
        // TEST 4: Correct password
        // --------------------------------
        #10;
        password_in = 4'b1011;
        enter = 1;

        #10;
        enter = 0;

        // Wait
        #30;

        $finish;

    end

endmodule
