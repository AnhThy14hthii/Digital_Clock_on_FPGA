
`timescale 1ns / 1ps

module testbench();
    reg clk_in, rst_n;
    reg [1:0] bt;
    reg [2:0] switch;
    reg sw2_updown, sw3_set_hourmin;
    wire [5:0] bin1, bin2;

    top uut_top (.clk_in(clk_in), .rst_n(rst_n), .bt(bt), .switch(switch) ,.sw2_updown(sw2_updown),
    .sw3_set_hourmin(sw3_set_hourmin),.bin1(bin1),.bin2(bin2));


    task press_bt2;
        begin
            @(posedge uut_top.clk);
            bt[1] = 0;
            @(posedge uut_top.clk);
            bt[1] = 1;
            repeat(2) @(posedge uut_top.clk); 
        end
    endtask

    task press_bt1;
        begin
            @(posedge uut_top.clk);
            bt[0] = 0;
            @(posedge uut_top.clk);
            bt[0] = 1;
            repeat(2) @(posedge uut_top.clk); 
        end
    endtask
    //task test set over time
    task test_set_time;
        begin 
            #10 press_bt1;
            #10 press_bt2;
        // HOUR
        #100 sw3_set_hourmin = 1'b0;
            // increase hour to 5
            #50 sw2_updown = 1'b1;
            repeat(5) press_bt2;
            // decrease hour 5-0-23
            #50 sw2_updown = 1'b0;
            repeat(6) press_bt2;
        // MIN 
            #100 sw3_set_hourmin = 1'b1;
            #50  sw2_updown = 1'b1;
            repeat(2) press_bt2;

            #10 press_bt1;
        end
    endtask

    //task set time with target hour and min
    task set_time_to(input [5:0] target_h, input [5:0] target_m);
        integer i;
        begin
            #10 press_bt1; 
        //SET HOUR
            #50 sw3_set_hourmin = 1'b0;
            #50 sw2_updown = 1'b1;      // increase
            for(i = 0; i < target_h; i = i + 1) begin
                press_bt2;
            end
        // SET MIN
            #100 sw3_set_hourmin = 1'b1; 
            #50  sw2_updown = 1'b1; //increase
            for(i = 0; i < target_m; i = i + 1) begin
                press_bt2;
            end
            #50 press_bt1;
        end
    endtask
    //task test set alarm
    task test_set_alarm;  
        begin 
            #20 repeat (2) press_bt1;
            #10 press_bt2;
            force uut_top.uut_datapath.uut_alarm.hour_alarm = 6'd1;
            force uut_top.uut_datapath.uut_alarm.min_alarm = 6'd5;
            #20;
            release uut_top.uut_datapath.uut_alarm.hour_alarm;
            release uut_top.uut_datapath.uut_alarm.min_alarm;
            #10 press_bt1;
            force uut_top.uut_datapath.uut_realtime.hour_real = 6'd1;
            force uut_top.uut_datapath.uut_realtime.min_real = 6'd4;
            force uut_top.uut_datapath.uut_realtime.sec_real = 6'd50;
            #20;
            release uut_top.uut_datapath.uut_realtime.hour_real;
            release uut_top.uut_datapath.uut_realtime.min_real;
            release uut_top.uut_datapath.uut_realtime.sec_real;
            wait(uut_top.alarm_match == 1'b1);
            $display("ALARM MATCH! state: %d", uut_top.state);
            #500;
        end
    endtask

    //task test snooze
    task test_snooze;
        begin
            #30 repeat (3) press_bt1;
            #10 press_bt2;
        end
    endtask

    initial begin
        clk_in = 1'b0;
        rst_n = 1'b1;
        bt = 2'b11;
        switch = 3'd0;
        sw2_updown = 1'b0;
        sw3_set_hourmin = 1'b0;
    end
    always #10 clk_in = ~clk_in;
    initial begin 
        //reset
        rst_n = 1'b0;
        #100 rst_n = 1'b1;

        //CASE1: SETTIME
        test_set_time();
        #1000;

        //CASE2: SETALARM
        test_set_alarm();
        #500 switch[0] = 1'b1; 
        #200; 
        if (uut_top.state == 3'd0) 
            $display("[SUCCESS] Da ve trang thai IDLE.");
        else 
            $display("[ERROR] Chua ve IDLE, state hien tai: %d", uut_top.state);
        #1000;

        //CASE3: SNOOZE
        test_set_alarm(); 
        #50 switch[1] = 1'b1; 
      #200 switch[1] = 1'b0;
        #5000;  
        $finish;
    end
endmodule
