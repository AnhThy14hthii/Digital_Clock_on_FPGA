//depend on the button
module set_hour_min(
    input wire clk, rst_n,
    input wire bt2_set,
    input wire sw2_updown, //sw2
    input wire sw3_set_hourmin, //sw3
    output reg [5:0] set_hour, set_min
);
    always@(posedge clk or negedge rst_n) begin
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
endmodule
//divider clock for counter the real time
module Clock_divider_1Hz(
    input wire clk, rst_n,
    output wire clk_1Hz
);
    reg [5:0] count_1Hz;
    reg clk_1Hz;
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
module counter_realtime #(parameter WIDTH = 3)(
    input wire clk_1Hz, rst_n,
    input wire [5:0] set_hour, set_min,
    input wire [WIDTH-1: 0] stage,
    input wire sw3_set_hourmin, //sw3
    output reg [5:0] hour_real, min_real, sec_real
);
// counter real time
always@(posedge clk_1Hz or negedge rst_n) begin
    if(!rst_n) begin 
        hour_real <= 6'd0; 
        min_real <= 6'd0;
        sec_real <= 6'd0;
    end else if (stage == SETTIME) begin
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

module alarm #(parameter WIDTH = 3 )(
    input wire clk, rst_n,
    input wire [5:0] set_hour, set_min,
    input wire [5:0] hour_real, min_real,
    input wire [WIDTH-1: 0] stage,
    output wire alarm_match
);
    reg [5:0] hour_alarm, min_alarm;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            hour_alarm <= 6'd0;
            min_alarm <= 6'd0;
        end else if (stage == SETALARM) begin
            hour_alarm <= set_hour;
            min_alarm <= set_min;
        end 
    end
    assign alarm_match = (rst_n) && (hour_alarm == hour_real) && (min_alarm == min_real);
endmodule

module snooze#(parameter WIDTH = 3 ) (
    input wire clk, rst_n,
    input wire [5:0] set_hour, set_min,
    input wire [WIDTH-1: 0] stage,
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
        end else if (sw5_snooze && (stage == SNOOZE)) begin
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

module count_down #(parameter WIDTH = 3 )(
    input wire clk_1Hz, rst_n,
    input wire [5:0] set_min, set_sec,
    input wire sw6_start_cdwn,
    input wire [WIDTH-1: 0] stage,
    output reg [5:0] min_cnt_down, sec_cnt_down,
    output wire countdown_done
);
    //hour gán cho min, min gán cho sec
    always @(posedge clk_1Hz or negedge rst_n) begin
        if (!rst_n) begin
            min_cnt_down <= 6'd0;
            sec_cnt_down <= 6'd0;
        end else if(stage == COUNTDOWN) begin
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

module count_up #(parameter WIDTH = 3 )(
    input wire clk, clk_1Hz, rst_n,
    input wire [WIDTH-1: 0] stage,
    input wire bt2_set,
    output reg [5:0] min_cnt_up, sec_cnt_up
);
    reg [1:0] current, next; 
    localparam IDLE = 2'b00; 
    localparam RUN = 2'b01; 
    localparam STOP = 2'b10;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) current <= IDLE;
        else if(stage == COUNTUP) begin
            current <= next;
        end
    end
    always@(*) begin
        if(stage == COUNTDOWN) begin
            next = current;
            if(stage == COUNTUP) begin
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
    end 
    always@(posedge clk_1Hz or negedge rst_n) begin
        if(!rst_n) begin 
            min_cnt_up <= 6'd0; 
            sec_cnt_up <= 6'd0;
        end else if(stage == COUNTUP) begin
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

/*module DATAPATH #(parameter WIDTH = 3)(
    input wire clk, rst_n,
    input wire [WIDTH-1: 0] stage; 
    output reg 
)
    wire clk, 
    wire [5:0] set_h, set_m;
    wire [5:0] real_h, real_m, real_s;

    set_hour_min dut1 (.clk(),.rst_n(rst_n),.bt2_set(),.sw2_updown(),.sw3_set_hourmin()
    ,.set_hour(), .set_min());
    
    set_min_sec dut1 (.clk(),.rst_n(rst_n),.bt2_set(),.sw2_updown(),.sw3_set_hourmin()
    ,.set_min(), .set_sec());
    
    Clock_divider_1Hz dut1(.clk(),.rst_n(rst_n)
    ,.clk_1Hz());
    
    counter_realtime dut1 (.WIDTH(3))(.clk_1Hz(), .rst_n() ,.set_hour(), .set_min(), .stage(), .sw3_set_hourmin()
    ,.hour_real(), .min_real(), .sec_real());

    alarm dut1 (.clk(), .rst_n(), .set_hour(), .set_min () ,.hour_real() , .min_real()
    ,.alarm_match());
    
    snooze dut1 (.clk(), .rst_n(), .set_hour(), .set_min() ,.sw5_snooze() ,.hour_real() , .min_real() , .sec_real()
    ,.snooze_match());
   
    count_down dut1 (.clk_1Hz(), .rst_n(), .set_min(), .set_sec(), .sw6_start_cdwn()
    ,.min_cnt_down(), .sec_cnt_down(), .countdown_done());

    count_up dut1 ( .clk(), .clk_1Hz(), .rst_n(), .bt2_set()
    , .min_cnt_up(), .sec_cnt_up());
    
endmodule */
