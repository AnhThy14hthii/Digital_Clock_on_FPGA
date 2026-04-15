//depend on the button
module set_hour_min(
    input wire clk, rst_n,
    input wire enable_set_hm,
    input wire bt2_set,
    input wire sw2_updown, //sw2
    input wire sw3_set_hourmin, //sw3
    output reg [5:0] set1_hour, set1_min
);
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            set1_hour <= 6'd0;
            set1_min <= 6'd0;
        end else if(enable_set_hm) begin
            case(sw3_set_hourmin)
            //set_hour
                1'b0: begin
                        //count up (1)
                        if(sw2_updown) begin
                            if(bt2_set) begin
                                if(set1_hour >= 6'd23) set1_hour <= 6'd0;
                                else set1_hour <= set1_hour + 6'd1;
                            end
                        end else begin
                        //count down (0)
                            if(bt2_set) begin
                                if(set1_hour== 6'd0) set1_hour <= 6'd23;
                                else set1_hour <= set1_hour - 6'd1;
                            end
                        end
                    end
            //set_min 
                1'b1: begin
                        //count up (1)
                        if(sw2_updown) begin
                            if(bt2_set) begin
                                if(set1_min >= 6'd59) set1_min <= 6'd0;
                                else set1_min <= set1_min + 6'd1;
                            end
                        end else begin
                        //count down (0)
                            if(bt2_set) begin
                                if(set1_min == 6'd0) set1_min <= 6'd59;
                                else set1_min <= set1_min - 6'd1;
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
    output reg [5:0] set2_min, set2_sec
);
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            set2_min<=6'd0;
            set2_sec <= 6'd0;
        end else if(enable_set_ms) begin
            case(sw3_set_hourmin)
            //set_min
                1'b0: begin
                        //count up (1)
                        if(sw2_updown) begin
                            if(bt2_set) begin
                                if(set2_min >= 6'd59) set2_min <= 6'd0;
                                else set2_min <= set2_min + 6'd1;
                            end
                        end else begin
                        //count down (0)
                            if(bt2_set) begin
                                if(set2_min== 6'd0) set2_min <= 6'd59;
                                else set2_min <= set2_min - 6'd1;
                            end
                        end
                    end
            //set_sec
                1'b1: begin
                        //count up (1)
                        if(sw2_updown) begin
                            if(bt2_set) begin
                                if(set2_sec >= 6'd59) set2_sec <= 6'd0;
                                else set2_sec <= set2_sec + 6'd1;
                            end
                        end else begin
                        //count down (0)
                            if(bt2_set) begin
                                if(set2_sec == 6'd0) set2_sec <= 6'd59;
                                else set2_sec <= set2_sec - 6'd1;
                            end
                        end
                    end
            endcase
        end
    end
endmodule

// counter the real time and set enable 
module counter_realtime (
    input wire clk, tick_1Hz, rst_n,
    input wire [5:0] set1_hour, set1_min,
    input wire enable_set_time,
    output reg [5:0] hour_real, min_real, sec_real
);
// counter real time
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin 
        hour_real <= 6'd0; 
        min_real <= 6'd0;
        sec_real <= 6'd0;
    end else if (enable_set_time) begin
        hour_real <= set1_hour; 
        min_real <= set1_min; 
        sec_real <= 6'd0;
    end else if(tick_1Hz)begin
        if(sec_real == 6'd59) begin 
            sec_real <= 6'd0;
            if(min_real == 6'd59) begin
                min_real <= 6'd0;
                if(hour_real == 6'd23) 
                    hour_real <= 6'd0; 
                else hour_real <= hour_real + 6'd1;
            end else min_real <= min_real + 6'd1; 
        end else sec_real <= sec_real + 6'd1;
    end
end
endmodule 

module alarm (
    input wire clk, rst_n,
    input wire [5:0] set1_hour, set1_min,
    input wire [5:0] hour_real, min_real,sec_real,
    input wire enable_set_alarm,
    output reg [5:0] hour_alarm, min_alarm,
    output wire alarm_match
);
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            hour_alarm <= 6'd12;
            min_alarm <= 6'd0;
        end else if (enable_set_alarm) begin
            hour_alarm <= set1_hour;
            min_alarm <= set1_min;
        end 
    end
    assign alarm_match = (rst_n) && (hour_alarm == hour_real) && (min_alarm == min_real) && (sec_real == 6'd0);
endmodule

module snooze(
    input wire clk, rst_n,
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
    input wire clk, rst_n,
    input wire [5:0] set2_min, set2_sec,
    input wire tick_1Hz,
    input wire sw6_start_cdwn,
    input wire enable_count_down,
    output reg [5:0] min_cnt_down, sec_cnt_down,
    output wire countdown_done
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            min_cnt_down <= 6'd0;
            sec_cnt_down <= 6'd0;
        end else if(enable_count_down) begin
            if(!sw6_start_cdwn) begin
            sec_cnt_down <= set2_sec; 
            min_cnt_down <= set2_min;
            end else begin 
                    if(sec_cnt_down == 6'd0 && min_cnt_down == 6'd0) begin
                        sec_cnt_down <= 6'd0; 
                        min_cnt_down <= 6'd0;
                    end else if(tick_1Hz) begin
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
    input wire clk, rst_n,
    input wire tick_1Hz,
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
            next = current;
            case (current)
                IDLE: if(bt2_set) next = RUN;
                        else next = IDLE;
                RUN: if(bt2_set) next = STOP;
                        else next = RUN;
                STOP: if(bt2_set) next = RUN; 
                        else next = STOP;
                default: next = IDLE;
            endcase
        end else next = IDLE;
    end 
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            min_cnt_up <= 6'd0; 
            sec_cnt_up <= 6'd0;
        end else if (!enable_count_up || current == IDLE) begin
            min_cnt_up <= 6'd0; 
            sec_cnt_up <= 6'd0;
        end else if(tick_1Hz && (current == RUN) ) begin
                if(sec_cnt_up >= 6'd59) begin 
                    sec_cnt_up <= 6'd0; 
                    if(min_cnt_up >= 6'd59 ) begin 
                        min_cnt_up <= 6'd59; 
                        sec_cnt_up <= 6'd59;
                    end else min_cnt_up <= min_cnt_up + 6'd1;
                end else sec_cnt_up <= sec_cnt_up + 6'd1;
        end 
    end
endmodule

module control #(parameter WIDTH = 3)(
    input wire [WIDTH-1: 0] state, 
    input wire [5:0] set1_hour, set1_min,
    input wire [5:0] hour_alarm, min_alarm,
    input wire [5:0] hour_real, min_real,
    input wire [5:0] min_cnt_down, sec_cnt_down,
    input wire [5:0] min_cnt_up, sec_cnt_up, 
    output reg [5:0] bin1, bin2,
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

    assign enable_set_hm = (state == SETTIME) | (state == SETALARM); 
    assign enable_set_ms = (state == COUNTDOWN); 
    assign enable_set_time = (state == SETTIME);
    assign enable_set_alarm = (state == SETALARM);
    assign enable_snooze = (state == SNOOZE);
    assign enable_count_down = (state == COUNTDOWN);
    assign enable_count_up = (state == COUNTUP);
    
    always@(*) begin
        case(state) 
            IDLE: begin
                bin1 = hour_real; 
                bin2 = min_real;
            end
            SETTIME: begin
                bin1 = set1_hour;
                bin2 = set1_min;
            end
            SETALARM: begin
                bin1 = hour_alarm;
                bin2 = min_alarm; 
            end
            COUNTDOWN: begin
                bin1 = min_cnt_down; 
                bin2 = sec_cnt_down;
            end
            COUNTUP: begin
                bin1 = min_cnt_up;
                bin2 = sec_cnt_up;
            end
            SNOOZE: begin
                bin1 = hour_real;
                bin2 = min_real;
            end
            RINGING: begin
                bin1 = hour_real;
                bin2 = min_real;
            end
            default: begin
                bin1 = hour_real; 
                bin2 = min_real;
            end
        endcase
    end
endmodule 

module DATAPATH(
    input wire clk, rst_n,
    input wire bt2_set,
    input wire tick_1Hz,
    input wire sw5_snooze, sw6_start_cdwn,
    input wire sw2_updown, sw3_set_hourmin,
    input wire [2:0] state,
    output wire alarm_match, snooze_match,
    output reg [5:0] bin1, bin2
);
    wire enable_count_down, enable_count_up, enable_snooze;
    wire enable_set_alarm, enable_set_time;
    wire enable_set_hm, enable_set_ms;
    wire [5:0] hour_real, min_real, sec_real;
    wire [5:0] hour_alarm, min_alarm;
    wire [5:0] set1_hour, set1_min;
    wire [5:0] set2_min, set2_sec;
    wire [5:0] min_cnt_down, sec_cnt_down;
    wire [5:0] min_cnt_up, sec_cnt_up;
    wire countdown_done;
    

    set_hour_min uut_sethm (.clk(clk),.rst_n(rst_n),.enable_set_hm(enable_set_hm),.bt2_set(bt2_set),.sw2_updown(sw2_updown)
    ,.sw3_set_hourmin(sw3_set_hourmin), .set1_hour(set1_hour), .set1_min(set1_min));
    set_min_sec uut_setms (.clk(clk),.rst_n(rst_n),.enable_set_ms(enable_set_ms),.bt2_set(bt2_set),.sw2_updown(sw2_updown),
    .sw3_set_hourmin(sw3_set_hourmin),.set2_min(set2_min),.set2_sec(set2_sec));
    counter_realtime uut_realtime (.clk(clk),.rst_n(rst_n),.tick_1Hz(tick_1Hz),.set1_hour(set1_hour),.set1_min(set1_min),
    .enable_set_time(enable_set_time),.hour_real(hour_real),.min_real(min_real),.sec_real(sec_real));

    alarm uut_alarm (.clk(clk),.rst_n(rst_n),.set1_hour(set1_hour),.set1_min(set1_min),.sec_real(sec_real),
    .hour_real(hour_real),.min_real(min_real),.enable_set_alarm(enable_set_alarm),.alarm_match(alarm_match),.hour_alarm(hour_alarm),.min_alarm(min_alarm));
    snooze uut_snooze (.clk(clk),.rst_n(rst_n),.enable_snooze(enable_snooze),.sw5_snooze(sw5_snooze),
    .hour_real(hour_real),.min_real(min_real),.sec_real(sec_real),.snooze_match(snooze_match));
    count_down uut_cntdown(.clk(clk),.rst_n(rst_n),.tick_1Hz(tick_1Hz),.set2_min(set2_min),.set2_sec(set2_sec),.sw6_start_cdwn(sw6_start_cdwn),
    .enable_count_down(enable_count_down),.min_cnt_down(min_cnt_down),.sec_cnt_down(sec_cnt_down),.countdown_done(countdown_done));
    count_up uut_cntup (.clk(clk),.rst_n(rst_n),.tick_1Hz(tick_1Hz),.enable_count_up(enable_count_up),.bt2_set(bt2_set),
    .min_cnt_up(min_cnt_up),.sec_cnt_up(sec_cnt_up));

    control #(.WIDTH(3)) uut_control (.state(state),.set1_hour(set1_hour),.set1_min(set1_min),.hour_alarm(hour_alarm),.min_alarm(min_alarm),
    .hour_real(hour_real),.min_real(min_real),.min_cnt_down(min_cnt_down),.sec_cnt_down(sec_cnt_down),.enable_set_alarm(enable_set_alarm),
    .min_cnt_up(min_cnt_up),.sec_cnt_up(sec_cnt_up),.bin1(bin1),.bin2(bin2),.enable_set_hm(enable_set_hm),.enable_set_ms(enable_set_ms),
    .enable_set_time(enable_set_time),.enable_snooze(enable_snooze),.enable_count_down(enable_count_down),.enable_count_up(enable_count_up));
 
endmodule
