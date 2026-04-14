 module top(
    input wire clk, rst_n,
    input wire [1:0] bt,
    input wire [2:0] switch,
    input wire sw2_updown, sw3_set_hourmin,
    output wire [5:0] bin1, bin2
 ); 
    wire bt2_set, bt1_select;
    wire clk_100hz;
    wire [2:0] state;
    wire sw4_alarm, sw5_snooze, sw6_start_cdwn;
    wire alarm_match, snooze_match;
    wire tick_1Hz;
    clock_divider_param #(.DIV(10)) uut_100Hz (.clk(clk),.clk_100hz(clk_100hz),.rst_n(rst_n));
    Debounce_button uut_dbn (.clk_100hz(clk_100hz),.rst_n(rst_n),.bt(bt),.bt2_set(bt2_set),.bt1_select(bt1_select));
    switch_posedge #(.WIDTH(3)) uut_sw (.switch(switch),.clk_100hz(clk_100hz),
    .rst_n(rst_n),.sw4_alarm(sw4_alarm),.sw5_snooze(sw5_snooze),.sw6_start_cdwn(sw6_start_cdwn));

    FSM #(.WIDTH(3)) uut_fsm (.tick_1Hz(tick_1Hz),.clk_100hz(clk_100hz),.clk(clk),.rst_n(rst_n),.bt1_select(bt1_select),.bt2_set(bt2_set),.sw5_snooze(sw5_snooze)
    , .sw4_alarm(sw4_alarm),.alarm_match(alarm_match),.snooze_match(snooze_match),.state(state));
    
    DATAPATH uut_datapath (.clk(clk),.rst_n(rst_n),.tick_1Hz(tick_1Hz),.bt2_set(bt2_set),.clk_100hz(clk_100hz),.sw5_snooze(sw5_snooze),.sw6_start_cdwn(sw6_start_cdwn),
    .sw2_updown(sw2_updown),.sw3_set_hourmin(sw3_set_hourmin),.state(state),.bin1(bin1),.bin2(bin2),.alarm_match(alarm_match), .snooze_match(snooze_match));

 endmodule
