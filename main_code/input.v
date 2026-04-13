module Debounce_button (
    input wire clk, rst_n,
    input wire[1:0] bt, 
    output wire bt2_set,
    output wire bt1_select
);
    wire [3:0] q;
    //button1 
    Q_FF uut1 (
        .clk(clk), 
        .rst_n(rst_n), 
        .d(bt[0]), 
        .q(q[0])
    );
    Q_FF uut2 (
        .clk(clk), 
        .rst_n(rst_n), 
        .d(q[0]), 
        .q(q[1])
    );
    assign bt1_select = ~q[0] & q[1];

    //button2
    Q_FF uut3 (
        .clk(clk), 
        .rst_n(rst_n), 
        .d(bt[1]), 
        .q(q[2])
    );
    Q_FF uut4 (
        .clk(clk), 
        .rst_n(rst_n), 
        .d(q[2]), 
        .q(q[3])
    );
    assign bt2_set = ~q[2] & q[3];
endmodule

//100Hz
module clock_divider#(parameter  DIV = 250000)(
    input wire clk_in, rst_n,
    output reg clk
);
    reg [18:0] clock_cnt;
    always @(posedge clk_in or negedge rst_n) begin
        if(!rst_n) begin
          clk <= 0;
          clock_cnt <= 0;
        end else if(clock_cnt == DIV-1) begin 
            clk <= ~clk;
            clock_cnt <= 0;
          end else begin
            clock_cnt <= clock_cnt + 1;
          end
    end
endmodule

module Q_FF(
    input clk, rst_n, d,
    output reg q
); 
    always @(posedge clk or negedge rst_n) begin 
        if(!rst_n) q<=0; 
        else q <= d;
    end
endmodule 

module switch_posedge #(parameter WIDTH = 3)(
    input wire [WIDTH-1:0] switch, 
    input wire clk, rst_n,
    output wire sw4_alarm, 
    output wire sw5_snooze, 
    output wire sw6_start_cdwn
);
    reg [WIDTH-1:0] delay; 
    always@(posedge clk or negedge rst_n)begin
      if(!rst_n) delay <= 0;
      else begin 
        delay <= switch;
      end
    end
    // sw4 - turn off (1)
    assign sw4_alarm = switch[0] & ~delay [0]; 
    // sw5 - snooze (1)
    assign sw5_snooze = switch[1] & ~delay [1]; 
    // countdown 1:start count
    assign sw6_start_cdwn = switch[2] & ~delay [2]; 
endmodule
