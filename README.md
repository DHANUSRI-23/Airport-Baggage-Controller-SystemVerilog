# Airport Baggage Controller using SystemVerilog

## Overview

The Airport Baggage Controller is an RTL-based digital control system designed using SystemVerilog. The controller manages baggage movement through a conveyor system and routes baggage to Terminal A, Terminal B, or Terminal C based on the selected destination.

The design uses a Finite State Machine (FSM) along with baggage counting, jam detection, and emergency-stop logic.

## Features

- FSM-based baggage conveyor control
- Three-terminal baggage routing
- Terminal A, B and C diverter control
- Baggage entry and exit detection
- 8-bit baggage counter
- Programmable jam timeout
- Emergency-stop handling
- Jam alarm
- Emergency alarm
- RTL functional simulation

## FSM States

| State | Code | Function |
|------|------|----------|
| IDLE | 000 | Waits for baggage |
| CONVEYOR | 001 | Moves baggage |
| ROUTING | 010 | Routes baggage |
| WAIT_EXIT | 011 | Waits for baggage exit |
| JAM | 100 | Stops conveyor due to jam |
| EMERGENCY | 101 | Stops system during emergency |

## Destination Encoding

| Destination | Input |
|------------|-------|
| Terminal A | 00 |
| Terminal B | 01 |
| Terminal C | 10 |
| Invalid | 11 |

## Tools Used

- SystemVerilog
- Intel Quartus
- ModelSim / Quartus Waveform Editor

## Verification

The RTL design was verified using functional simulation.

Test cases included:

1. Reset and IDLE operation
2. Baggage entry
3. Conveyor operation
4. Terminal A routing
5. Terminal B routing
6. Terminal C routing
7. Baggage exit
8. Emergency stop
9. Jam detection

Simulation waveforms were analyzed to verify FSM transitions and output signals.
