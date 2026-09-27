# Full-Duplex UART System: RTL Design & SystemVerilog Verification

## 📌 Overview
This is a personal project developed during my studies and research in IC Design and Verification. This repository contains the complete RTL source code for a Full-Duplex UART system (integrated with synchronous FIFOs), alongside an Object-Oriented SystemVerilog verification environment. The project focuses on handling practical physical-layer signal noise and achieving 100% Functional Coverage for the Receiver (RX) path.

## 🛠️ Hardware Architecture (RTL Design)
The system is designed using a hierarchical approach, comprising the following key modules:
*   **`UART_TOP.v`**: The top-level module connecting the transmitter (TX), receiver (RX), baud rate generator, and FIFO buffers, enabling simultaneous bi-directional communication.
*   **`UART_TX.v` & `UART_RX.v`**: The core transmission and reception logic. Specifically, the RX module features a robust Finite State Machine (FSM) optimized for noise rejection. I implemented a `WAIT_IDLE` state to continuously monitor the stability of the RX line. If brief physical noise pulls the line low (without holding for a full Start Bit period), the FSM enters a safe wait state. This prevents the system from misinterpreting the noise as a Start Bit and stops invalid data (e.g., `8'hFF`) from propagating downstream.
*   **`FIFO_SYNCH.v`**: A parameterized synchronous FIFO buffer. It utilizes read/write pointers and status flags (Full/Empty) to safely synchronize data streams between the UART core and external peripherals, preventing data loss at high speeds.
*   **`BAUD_GEN.v`**: A clock divider generating the baud rate, supporting oversampling mechanisms to ensure accurate data recovery in the RX module.

## 🧪 Verification Environment
To ensure the functional correctness of the design (particularly the RX module), I built an OOP-based SystemVerilog testbench applying advanced verification techniques:
*   **Dual-Queue Scoreboard Architecture:** Instead of a single queue that is prone to blocking, I separated the expected outcomes into `exp_data_queue` (for valid data) and `exp_err_queue` (for error scenarios). This design achieves O(1) lookup complexity and completely resolves simulation deadlocks when the RTL actively discards noise-corrupted frames.
*   **Constrained-Random Stimulus:** The testbench automatically generates difficult corner cases, such as all zeros (`8'h00`), all ones (`8'hFF`), or aggressively toggling bits (`8'hA5`, `8'h5A`), to stress-test the sampling logic's limits.
*   **100% Functional Coverage:** I configured custom `covergroups` to sample stimulus directly from the Generator. After extensive debugging and refinement, the project successfully passed 3000 randomized test cases with 0 errors and achieved 100% coverage. This proves the design operates correctly under all combinations of normal data, frame errors, and physical glitches.

## 📁 Directory Structure
*   `RTL/`: Contains the complete Verilog source code (`BAUD_GEN.v`, `FIFO_SYNCH.v`, `UART_RX.v`, `UART_TX.v`, `UART_TOP.v`).
*   `TB/`: Contains the SystemVerilog Verification IP classes (Transaction, Generator, Driver, Monitor, Scoreboard, Coverage, Environment).