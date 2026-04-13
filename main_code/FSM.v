module FSM #(parameter WIDTH = 3 )(
    input wire clk, rst_n, 
    input wire bt1_select, bt2_set, 
    input wire sw5_snooze, sw4_alarm,
    input wire alarm_match, snooze_match, 
    output reg [WIDTH-1: 0] stage
); 
    //counter for button 1
    reg [2:0] cnt_bt1;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) cnt_bt1 <= 3'd0;
        else begin
            if(stage != IDLE) cnt_bt1 <= 3'd0;
            else begin
                if(bt1_select) begin
                    if(cnt_bt1 >= 3'd4) cnt_bt1 <= 3'd0; 
                    else cnt_bt1 <= cnt_bt1 + 3'd1; 
                end
            end
        end
    end

    //state of FSM
    localparam IDLE = 3'b000;
    localparam SETTIME = 3'b001; 
    localparam SETALARM = 3'b010;
    localparam COUNTDOWN = 3'b011; 
    localparam COUNTUP = 3'b100; 
    localparam RINGING = 3'b101; 
    localparam SNOOZE = 3'b110;

    //time out 60s
    reg [12:0] time_out;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) time_out <= 13'd0; 
        else begin
            if(alarm_match) time_out <= time_out + 1'd1;
            else time_out <= 13'd0;
        end
    end

    //fsm 
    reg [WIDTH-1:0] next_state;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) stage <= IDLE;
        else stage <= next_state;
    end

    always@(*) begin
       if (alarm_match) next_state = RINGING;
       else begin
            case(stage)
                IDLE: begin
                    if(bt2_set && (cnt_bt1==3'd1)) next_state = SETTIME; 
                    else if (bt2_set && (cnt_bt1==3'd2)) next_state = SETALARM; 
                    else if (bt2_set && (cnt_bt1== 3'd3)) next_state = COUNTDOWN;
                    else if (bt2_set && (cnt_bt1==3'd4)) next_state = COUNTUP;
                end
                SETTIME: begin
                    if(bt1_select) next_state = IDLE;
                end
                SETALARM: begin
                    if(bt1_select) next_state = IDLE;
                end
                COUNTDOWN: begin
                    if(bt1_select) next_state = IDLE;
                end
                COUNTUP: begin
                    if(bt1_select) next_state = IDLE;
                end
                RINGING: begin
                    if(time_out >= 13'd60) next_state = IDLE;
                    else begin
                        if(sw4_alarm) next_state = IDLE;
                        else if(sw5_snooze) next_state = SNOOZE;
                    end
                end
                SNOOZE: begin
                    if(snooze_match) next_state = RINGING;
                end
                default: next_state = IDLE;
            endcase
       end
    end 
endmodule 
