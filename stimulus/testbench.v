
`timescale 1ns / 1ps

module testbench();
    reg clk, rst_n;
    reg [1:0] bt;
    reg [2:0] switch;
    reg sw2_updown, sw3_set_hourmin;
    wire [5:0] bin1, bin2;

    always #20 clk = ~clk; //T=20ns, f=50MHz

    top uut_top (.clk(clk), .rst_n(rst_n), .bt(bt), .switch(switch) ,.sw2_updown(sw2_updown),
    .sw3_set_hourmin(sw3_set_hourmin),.bin1(bin1),.bin2(bin2));

    task press_bt2;
        begin
            @(negedge clk);
            bt <= 2'b10;
            repeat(50)@(posedge clk);
            bt <= 2'b11;
            repeat(50) @(posedge clk); 
        end
    endtask

    task press_bt1;
        begin
            @(negedge clk);
            bt <= 2'b01;
            repeat(50)@(posedge clk);
            bt <= 2'b11;
            repeat(50) @(posedge clk); 
        end
    endtask
    //task test set over time
    task test_set_time;
        begin 
            press_bt1;
            press_bt2;
        // HOUR
            @(negedge clk);
            sw3_set_hourmin = 1'b0;
            repeat(50) @(posedge clk);

            // increase hour to 5
            sw2_updown = 1'b1;
            repeat(50) @(posedge clk);
            repeat(5) press_bt2;

            // decrease hour 5-0-23
            sw2_updown = 1'b0;
            repeat(50) @(posedge clk);
            repeat(6) press_bt2;
        // MIN 
            repeat(100) @(posedge clk);
            sw3_set_hourmin = 1'b1;
            sw2_updown = 1'b1;
            repeat(50) @(posedge clk);

            repeat(2) press_bt2;
        //IDLE
            repeat(100) @(posedge clk);
            press_bt1;
        end
    endtask

    //task test set alarm
    task test_set_alarm;  
        begin 
            repeat(2) press_bt1;
            press_bt2;
            
            // HOUR
                @(negedge clk);
                sw3_set_hourmin = 1'b0;
                // increase hour to 5
                sw2_updown = 1'b1;
                repeat(50) @(posedge clk);
                repeat(6) press_bt2;
            // MIN 
                repeat(70) @(posedge clk);
                sw3_set_hourmin = 1'b1;
                repeat(50) @(posedge clk);
                repeat(5) press_bt2;

            press_bt1;

            @(negedge clk);
            force uut_top.uut_datapath.uut_realtime.hour_real = 6'd6;
            force uut_top.uut_datapath.uut_realtime.min_real = 6'd4;
            force uut_top.uut_datapath.uut_realtime.sec_real = 6'd59;
            repeat(70) @(posedge clk);
            
            force uut_top.uut_datapath.uut_realtime.sec_real = 6'd0; // Ép giây nhảy sang 0 để khớp phút

            release uut_top.uut_datapath.uut_realtime.hour_real;
            release uut_top.uut_datapath.uut_realtime.min_real;
            release uut_top.uut_datapath.uut_realtime.sec_real;
            repeat(100) @(posedge clk);
            wait(uut_top.alarm_match == 1'b1);
        end
    endtask

    //task test snooze
    task test_snooze;
        begin
            repeat(200) @(posedge clk);
            @(negedge clk);
            switch[1] = 1'b1;
            repeat(50) @(posedge clk);
            //force time
            @(negedge clk);
            force uut_top.uut_datapath.uut_realtime.hour_real = 6'd6;
            force uut_top.uut_datapath.uut_realtime.min_real = 6'd9;
            force uut_top.uut_datapath.uut_realtime.sec_real = 6'd59;

            repeat(50) @(posedge clk); 
            force uut_top.uut_datapath.uut_realtime.sec_real = 6'd0;

            release uut_top.uut_datapath.uut_realtime.hour_real;
            release uut_top.uut_datapath.uut_realtime.min_real;
            release uut_top.uut_datapath.uut_realtime.sec_real;

            wait(uut_top.snooze_match == 1'b1);
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b1;
        bt = 2'b11;
        switch = 3'd0;
        sw2_updown = 1'b0;
        sw3_set_hourmin = 1'b0;
    end

    initial begin 
        //reset
        rst_n = 1'b0;
        #100 rst_n = 1'b1;
        repeat(50) @(posedge clk);

        //CASE1: SETTIME
        test_set_time();
        repeat(1000) @(posedge clk);

        $finish;
    end
endmodule
