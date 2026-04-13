//depend on the button
module set_hour_min(
    input wire clk, rst_n,
    input wire enable_set_hm,
    input wire bt2_set,
    input wire sw2_updown, //sw2
    input wire sw3_set_hourmin, //sw3
    output reg [5:0] set_hour, set_min
);
    always@(posedge clk or negedge rst_n) begin
        if(enable_set_hm) begin
            case(sw3_set_hourmin)
            //set_hour
                1'b0: begin
                    if(!rst_n) set_hour <= 6'd0;
                    else begin
                        //count up (1)
                        if(sw2_updown) begin
                            if(bt2_set) begin
                                if(set_hour >= 6'd23) set_hour <= 6'd0;
                                else set_hour <= set_hour + 6'd1;
                            end
                        end else begin
                        //count down (0)
                            if(bt2_set) begin
                                if(set_hour== 6'd0) set_hour <= 6'd23;
                                else set_hour <= set_hour - 6'd1;
                            end
                        end
                    end
                end
            //set_min 
                1'b1: begin
                    if(!rst_n) set_min <= 6'd0;
                    else begin
                        //count up (1)
                        if(sw2_updown) begin
                            if(bt2_set) begin
                                if(set_min >= 6'd59) set_min <= 6'd0;
                                else set_min <= set_min + 6'd1;
                            end
                        end else begin
                        //count down (0)
                            if(bt2_set) begin
                                if(set_min == 6'd0) set_min <= 6'd59;
                                else set_min <= set_min - 6'd1;
                            end
                        end
                    end
                end
            endcase
        end
        end
endmodule
//depend on the button
module set_min_sec(
    input wire enable_set_ms,
    input wire clk, rst_n,
    input wire bt2_set,
    input wire sw2_updown, //sw2
    input wire sw3_set_hourmin, //sw3
    output reg [5:0] set_min, set_sec
);
    always@(posedge clk or negedge rst_n) begin
        if(enable_set_ms) begin
            case(sw3_set_hourmin)
            //set_min
                1'b0: begin
                    if(!rst_n) set_min <= 6'd0;
                    else begin
                        //count up (1)
                        if(sw2_updown) begin
                            if(bt2_set) begin
                                if(set_min >= 6'd59) set_min <= 6'd0;
                                else set_min <= set_min + 6'd1;
                            end
                        end else begin
                        //count down (0)
                            if(bt2_set) begin
                                if(set_min== 6'd0) set_min <= 6'd59;
                                else set_min <= set_min - 6'd1;
                            end
                        end
                    end
                end
            //set_sec
                1'b1: begin
                    if(!rst_n) set_sec <= 6'd0;
                    else begin
                        //count up (1)
                        if(sw2_updown) begin
                            if(bt2_set) begin
                                if(set_sec >= 6'd59) set_sec <= 6'd0;
                                else set_sec <= set_sec + 6'd1;
                            end
                        end else begin
                        //count down (0)
                            if(bt2_set) begin
                                if(set_sec == 6'd0) set_sec <= 6'd59;
                                else set_sec <= set_sec - 6'd1;
                            end
                        end
                    end
                end
            endcase
        end
    end
endmodule
//divider clock for counter the real time
module Clock_divider_1Hz(
    input wire clk, rst_n,
    output reg clk_1Hz
);
    reg [5:0] count_1Hz;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            clk_1Hz <= 1'b0; 
            count_1Hz <= 6'd0;
        end else if(count_1Hz == 6'd49) begin
                count_1Hz <= 6'd0;
                clk_1Hz <= ~clk_1Hz;
        end else count_1Hz <= count_1Hz + 6'd1;
    end
endmodule 
// counter the real time and set enable 
module counter_realtime (
    input wire clk_1Hz, rst_n,
    input wire [5:0] set_hour, set_min,
    input wire enable_set_time,
    input wire sw3_set_hourmin, //sw3
    output reg [5:0] hour_real, min_real, sec_real
);
// counter real time
always@(posedge clk_1Hz or negedge rst_n) begin
    if(!rst_n) begin 
        hour_real <= 6'd0; 
        min_real <= 6'd0;
        sec_real <= 6'd0;
    end else if (enable_set_time) begin
        hour_real <= set_hour; 
        min_real <= set_min; 
        sec_real <= 6'd0;
    end else begin
        if(sec_real == 6'd59) begin 
            sec_real <= 6'd0;
            if(min_real == 6'd59) begin
                min_real <= 6'd0;
                if(hour_real == 6'd23) 
                    hour_real <= 6'd0; 
                else hour_real <= hour_real + 6'd1;
            end else min_real <= 6'd0; 
        end else sec_real <= sec_real + 6'd1;
    end
end
endmodule 

module alarm (
    input wire clk, rst_n,
    input wire [5:0] set_hour, set_min,
    input wire [5:0] hour_real, min_real,
    input wire enable_set_alarm,
    output wire alarm_match
);
    reg [5:0] hour_alarm, min_alarm;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            hour_alarm <= 6'd0;
            min_alarm <= 6'd0;
        end else if (enable_set_alarm) begin
            hour_alarm <= set_hour;
            min_alarm <= set_min;
        end 
    end
    assign alarm_match = (rst_n) && (hour_alarm == hour_real) && (min_alarm == min_real);
endmodule

module snooze(
    input wire clk, rst_n,
    input wire [5:0] set_hour, set_min,
    input wire enable_snooze,
    input wire sw5_snooze,
    input wire [5:0] hour_real, min_real, sec_real,
    output wire snooze_match
);
    reg [5:0] hour_snooze, min_snooze, sec_snooze;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            hour_snooze <= 6'd0; 
            min_snooze <= 6'd0;
            sec_snooze <= 6'd0;
        end else if (sw5_snooze && enable_snooze) begin
            sec_snooze <= sec_real; 
            min_snooze <= min_real + 6'd5;
            hour_snooze <= hour_real;
            if(min_snooze >= 6'd59) begin
                hour_snooze <= hour_snooze + 6'd1;
                min_snooze <= min_snooze - 6'd60;
            end
        end
    end
    assign snooze_match = (rst_n) && (sec_snooze == sec_real) && (min_snooze == min_real) && (hour_snooze == hour_real);
endmodule

module count_down (
    input wire clk_1Hz, rst_n,
    input wire [5:0] set_min, set_sec,
    input wire sw6_start_cdwn,
    input wire enable_count_down,
    output reg [5:0] min_cnt_down, sec_cnt_down,
    output wire countdown_done
);
    //hour gán cho min, min gán cho sec
    always @(posedge clk_1Hz or negedge rst_n) begin
        if (!rst_n) begin
            min_cnt_down <= 6'd0;
            sec_cnt_down <= 6'd0;
        end else if(enable_count_down) begin
            if(!sw6_start_cdwn) begin
            sec_cnt_down <= set_sec; 
            min_cnt_down <= set_min;
            end else begin 
                    if(sec_cnt_down == 6'd0 && min_cnt_down == 6'd0) begin
                        sec_cnt_down <= 6'd0; 
                        min_cnt_down <= 6'd0;
                    end else begin
                        if(sec_cnt_down==6'd0) begin
                            sec_cnt_down <= 6'd59; 
                            min_cnt_down <= min_cnt_down - 6'b1;
                        end else sec_cnt_down <= sec_cnt_down - 6'b1; 
                    end
                end
        end
        end
    assign countdown_done = sw6_start_cdwn && (sec_cnt_down == 6'd0) && (min_cnt_down == 6'd0);
endmodule

module count_up (
    input wire clk, clk_1Hz, rst_n,
    input wire enable_count_up,
    input wire bt2_set,
    output reg [5:0] min_cnt_up, sec_cnt_up
);
    reg [1:0] current, next; 
    localparam IDLE = 2'b00; 
    localparam RUN = 2'b01; 
    localparam STOP = 2'b10;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) current <= IDLE;
        else if(enable_count_up) begin
            current <= next;
        end
    end
    always@(*) begin
        if(enable_count_up) begin
            case (current)
                IDLE: if(bt2_set) next = RUN;
                        else next = IDLE;
                RUN: if(bt2_set) next = STOP;
                        else next = RUN;
                STOP: if(bt2_set) next = RUN; 
                        else next = STOP;
                default: next = IDLE;
            endcase
        end
    end 
    always@(posedge clk_1Hz or negedge rst_n) begin
        if(!rst_n) begin 
            min_cnt_up <= 6'd0; 
            sec_cnt_up <= 6'd0;
        end else if(enable_count_up) begin
                if(current == RUN) begin
                if(sec_cnt_up >= 6'd59) begin 
                    sec_cnt_up <= 6'd0; 
                    if(min_cnt_up >= 6'd59 ) begin 
                        min_cnt_up <= 6'd59; 
                        sec_cnt_up <= 6'd59;
                    end else min_cnt_up <= min_cnt_up + 6'd1;
                end else sec_cnt_up <= sec_cnt_up + 6'd1;
            end 
        end
    end
endmodule

module DATAPATH #(parameter WIDTH = 3)(
    input wire clk, rst_n,
    input wire [WIDTH-1: 0] stage, 
    output wire enable_set_hm,
    output wire enable_set_ms,
    output wire enable_set_time, 
    output wire enable_set_alarm,
    output wire enable_snooze, 
    output wire enable_count_down,
    output wire enable_count_up
);
    localparam IDLE = 3'b000;
    localparam SETTIME = 3'b001; 
    localparam SETALARM = 3'b010;
    localparam COUNTDOWN = 3'b011; 
    localparam COUNTUP = 3'b100; 
    localparam RINGING = 3'b101; 
    localparam SNOOZE = 3'b110;

    assign enable_set_hm = (stage == SETTIME) | (stage == SETALARM); 
    assign enable_set_ms = (stage == COUNTDOWN); 
    assign enable_set_time = (stage == SETTIME);
    assign enable_set_alarm = (stage == SETALARM);
    assign enable_snooze = (stage == SNOOZE);
    assign enable_count_down = (stage == COUNTDOWN);
    assign enable_count_up = (stage == COUNTUP);
    
endmodule 
