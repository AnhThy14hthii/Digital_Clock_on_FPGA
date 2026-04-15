module Debounce_button (
    input wire clk, rst_n,
    input wire tick_100Hz,
    input wire[1:0] bt, 
    output wire bt2_set,
    output wire bt1_select
);
    wire [3:0] q;
    reg [1:0] edge_reg;
    wire bt1_debounce, bt2_debounce;
    
    //button1 
    Q_FF uut1 (.clk(clk), .rst_n(rst_n), .tick_100Hz(tick_100Hz),.d(bt[0]), .q(q[0]));
    Q_FF uut2 (.clk(clk), .rst_n(rst_n),.tick_100Hz(tick_100Hz), .d(q[0]), .q(q[1]));
    assign bt1_debounce = ~q[0] & q[1];

    //button2
    Q_FF uut3 (.clk(clk), .rst_n(rst_n), .tick_100Hz(tick_100Hz), .d(bt[1]), .q(q[2]));
    Q_FF uut4 (.clk(clk), .rst_n(rst_n), .tick_100Hz(tick_100Hz), .d(q[2]), .q(q[3]));
    assign bt2_debounce = ~q[2] & q[3];

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) edge_reg <= 2'b0;
        else begin
            edge_reg [0] <= bt1_debounce;
            edge_reg [1] <= bt2_debounce;
        end
    end
    assign bt1_select = bt1_debounce & ~edge_reg[0];
    assign bt2_set = bt2_debounce & ~edge_reg[1];

endmodule

//tick_100Hz and tick 1Hz
module clock_divider_param #(
    parameter param_100Hz = 500000, 
    parameter param_1Hz = 100)(
    input wire clk, rst_n,
    output reg tick_100Hz, 
    output reg tick_1Hz
);
    reg [18:0] count_100Hz;
    reg [6:0] count_1Hz;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            tick_100Hz <= 1'b0;
            count_100Hz <= 1'b0;
            tick_1Hz <= 1'b0;
            count_1Hz <= 1'b0;
        end else begin
            tick_100Hz <= 1'b0; 
            tick_1Hz <= 1'b0;
            if(count_100Hz == param_100Hz -1) begin
                count_100Hz <= 18'd0;
                tick_100Hz <= 1'b1;
                    if(count_1Hz == param_1Hz -1)begin
                        count_1Hz <= 7'd0;
                        tick_1Hz <= 1'b1;
                    end else count_1Hz <= count_1Hz + 1'b1;
            end else count_100Hz <= count_100Hz + 1'b1; 
        end

    end
endmodule

module Q_FF(
    input wire clk, rst_n, d,
    input wire tick_100Hz,
    output reg q
); 
    always @(posedge clk or negedge rst_n) begin 
        if(!rst_n) q<=0; 
        else if(tick_100Hz == 1'b1) q <= d;
    end
endmodule 

module switch_posedge #(parameter WIDTH = 3)(
    input wire [WIDTH-1:0] switch, 
    input wire clk, rst_n,
    input wire tick_100Hz,
    output wire sw4_alarm, 
    output wire sw5_snooze, 
    output wire sw6_start_cdwn
);
    reg [WIDTH-1:0] delay; 
    always@(posedge clk or negedge rst_n)begin
      if(!rst_n) delay <= 0;
      else if(tick_100Hz == 1'b1) begin 
        delay <= switch;
      end
    end
    // sw4 - turn off (1)
    assign sw4_alarm = switch[0] ; 
    // sw5 - snooze (1)
    assign sw5_snooze = switch[1] ; 
    // countdown 1:start count
    assign sw6_start_cdwn = switch[2] & ~delay [2]; 
endmodule
