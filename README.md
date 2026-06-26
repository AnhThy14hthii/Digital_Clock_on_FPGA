# Digital Clock on FPGA
 
**Demo Video:** [Demo Digital Clock on FPGA](https://youtu.be/-4mvUKoOuOU) | **Project Presentation:** [Presentation](https://www.youtube.com/watch?v=I9IBpSwVAUA)
 
---
 
## Overview
 
This project implements a **Digital Clock on FPGA** using **Verilog HDL**, featuring real-time clock display, alarm, and snooze functionalities. Users can interact with the system through switches and push-buttons to adjust time settings and manage alarms.
 
The design focuses on key digital hardware concepts, including synchronous system design, finite state machine (FSM) control, clock division, button debouncing, and multiplexed 7-segment display driving. By integrating these components into a complete FPGA-based application, the project demonstrates the practical implementation of a reliable real-time digital system.
 
---
 
## Target Platform
 
| Item | Details |
|------|---------|
| **Hardware** | Microchip PolarFire SoC FPGA (MPFS095T-1FCSG325E) |
| **Display** | External 7-Segment Display (4 digits, HH:MM) |
| **Language** | Verilog HDL |
| **EDA Tool** | Microchip Libero SoC |
| **Simulator** | ModelSim |
 
![FPGA Board](Microchip.png)
 
---
 
## Features
 
- Real-time clock display in **HH:MM** format
- **Set Time** — adjust hours and minutes via push-button and switches
- **Set Alarm** — configure alarm time with hour/minute selection
- **Countdown Timer** — count down from a user-set time
- **Count Up** — stopwatch-style count-up with start/pause/resume
- **Alarm Ringing** — triggers when real-time matches alarm time
- **Snooze** — delays the alarm by 5 minutes; auto-dismiss after 60 seconds
---
 
## System Architecture
 
The design is organized into four modular blocks inside `top.v`:
 
![Top-level Interface](diagrams/1_interface.png)
 
### Block Diagram
 
![Internal Architecture](diagrams/2_Top.png)
 
| Block | Role |
|-------|------|
| **INPUT** | Debounces buttons and switches; generates `tick_1Hz` and `tick_1kHz` |
| **FSM** | Moore FSM — manages 7 states and coordinates all mode transitions |
| **DATAPATH** | Real-time counters, alarm/snooze comparison logic, binary outputs |
| **OUTPUT** | BCD conversion, time-division multiplexing for 7-segment display |
 
---
 
## Module Details
 
### INPUT Block
 
![Input Block](diagrams/3_Input.png)
 
Receives raw `switch[4:0]` and `bt[1:0]` signals from the PolarFire board, performs digital debouncing, and outputs clean internal control signals along with `tick_1Hz` and `tick_1kHz` for the rest of the system.
 
### OUTPUT Block
 
![Output Block](diagrams/4_Output.png)
 
Converts 6-bit binary time data (`bin1`, `bin2`) into BCD digits, then drives 4 seven-segment digits using high-frequency time-division multiplexing at 1 kHz to eliminate flicker.
 
### DATAPATH Block
 
![Datapath Block](diagrams/5_Datapath.png)
 
Maintains three synchronized counters — Hours (Mod-24), Minutes (Mod-60), Seconds (Mod-60) — clocked by `tick_1Hz`. Continuously compares real-time against alarm and snooze registers to assert `alarm_match` and `snooze_match` flags.
 
### FSM Block
 
![FSM Block](diagrams/5_FSM.png)
 
A Moore FSM controlling 7 operational states:
 
| Code | State | Description |
|------|-------|-------------|
| `000` | **IDLE** | Real-time clock runs continuously |
| `001` | **SET_TIME** | User adjusts current time |
| `010` | **SET_ALARM** | User sets alarm time |
| `011` | **COUNTDOWN** | Countdown from user-set time |
| `100` | **COUNTUP** | Stopwatch; toggle start/pause with Button 2 |
| `101` | **RINGING** | Alarm active; auto-dismiss after 60 s |
| `110` | **SNOOZE** | Alarm snoozed; re-rings +5 minutes later |
 
State transitions are driven by button presses (`bt1_select`, `bt2_set`), switch positions, and datapath comparison flags (`alarm_match`, `snooze_match`).
 
---
 
## Input Controls
 
### DIP Switches
 
| Switch | Function |
|--------|----------|
| SW1 | System reset (active low) |
| SW2 | Count direction: `0` = down, `1` = up |
| SW3 | Field select: `0` = hour/minute, `1` = minute/second |
| SW4 | Turn off alarm (active high) |
| SW5 | Activate snooze (rising edge) |
| SW6 | Start countdown (active high, in COUNTDOWN state) |
 
### Push-Buttons
 
| Button | Function |
|--------|----------|
| **Button 1** | Cycle through modes (0→IDLE, 1→SETTIME, 2→SETALARM, 3→COUNTDOWN, 4→COUNTUP); press in any mode to return to IDLE |
| **Button 2** | Confirm selected mode / increment or decrement the active time field |
 
---
 
## Simulation Results
 
### Case 1 — Set Hour
 
![Set Hour Waveform](images/1_sethour.png)
 
Entering SET_TIME via Button 1 + Button 2, adjusting hours/minutes with SW2/SW3, then returning to IDLE. The `realtime_reg` is updated and output through `bin1`/`bin2`.
 
### Case 2 — Count Up / Down
 
![Count Up/Down Waveform](images/2_countupdown.png)
 
Verifies Start / Pause / Resume logic using button toggles in COUNTUP state.
 
### Case 3 — Alarm Trigger
 
![Alarm Trigger Waveform](images/3_alarmtrigger.png)
 
When real-time matches the alarm register, the FSM transitions from IDLE → RINGING (state `101`).
 
### Case 4 — Alarm Turn-off
 
![Alarm Turn-off Waveform](images/4_alarmturnoff.png)
 
Toggling SW4 while RINGING returns the system to IDLE and silences the alarm.
 
### Case 5 — Snooze Mechanism
 
![Snooze Waveform](images/5_snooze.png)
 
Toggling SW5 while RINGING moves the FSM to SNOOZE (state `110`), adds 5 minutes to the snooze register, and re-triggers RINGING when `snooze_match` fires. If SW4 is toggled instead, or no action is taken within 60 seconds, the system automatically returns to IDLE.

---

*2026 — Hồ Huỳnh Anh Thy*

