# Comprehensive FIFO IP: Synchronous & Asynchronous (CDC) Designs

## 📌 Project Overview
This repository contains RTL designs and functional verification environments for First-In-First-Out (FIFO) buffers, implemented in SystemVerilog. 

Initially starting as a standard buffer project, this repository has been expanded to include two distinct, industry-standard architectures: 
1. A single-clock **Synchronous FIFO** for intra-domain data pipelining.
2. A dual-clock **Asynchronous FIFO** specifically engineered for safe **Clock Domain Crossing (CDC)** applications.

This project demonstrates core VLSI and Front-End RTL competencies including:
* **RTL Coding** (SystemVerilog)
* **Clock Domain Crossing (CDC)** mitigations (Gray code, Multi-stage Synchronizers)
* **Finite State Logic** & Advanced Pointer Management
* **Functional Verification** via Self-checking Testbenches

---

## 🏗️ 1. Synchronous FIFO (Data Pipelining)
The Synchronous FIFO utilizes a shared clock for both read and write operations, making it ideal for buffering data between logic blocks operating at the same frequency.

### Key Features:
* **Architecture:** Parameterized, power-of-2 depth (e.g., 16x8) circular buffer.
* **Flow Control:** Includes programmable `almost_full` and `almost_empty` thresholds, crucial for AXI-stream data buffering and pipeline stalling.
* **BRAM Inference:** Write logic is intentionally separated from reset domains to ensure synthesis tools infer highly efficient Block RAM (BRAM) instead of distributed logic.
* **Pointer Logic:** Utilizes standard binary pointers (N+1 bits) for precise wrap-around detection and Full/Empty flag generation.

---

## 🏗️ 2. Asynchronous FIFO (CDC Applications)
The Asynchronous FIFO is designed to safely transfer data between two independent, asynchronous clock domains without data corruption or metastability.

### Key Features:
* **Dual-Clock Architecture:** Completely isolated read (`rd_clk`) and write (`wr_clk`) domains.
* **Clock Domain Crossing (CDC):** Safely passes control signals across asynchronous boundaries using 2-stage (2-flop) synchronizer chains to mitigate metastability.
* **Gray Code Pointers:** Converts binary address pointers into **Gray Code** before synchronization. Because Gray code only flips one bit at a time, it completely prevents multi-bit CDC sampling errors during pointer evaluation.
* **Pessimistic Flag Generation:** * The `Full` condition is evaluated in the write domain using a synchronized (delayed) read pointer, preventing overflow.
  * The `Empty` condition is evaluated in the read domain using a synchronized write pointer, preventing underflow.

---

## 📉 Verification & Waveform Analysis
Both designs include robust testbenches designed to verify functional correctness and boundary corner cases. Simulated using **Icarus Verilog** and analyzed via **EPWave/GTKWave**.

### Test Scenarios Covered:
* **Boundary Protections:** Attempting to write to a full FIFO (overflow protection) and read from an empty FIFO (underflow protection).
* **Concurrent Operations:** Simultaneous, back-to-back read/write operations on the exact same clock edge.
* **CDC Verification (Async):** Driving the read and write clocks at drastically different frequencies (e.g., 100MHz vs 40MHz) to prove data integrity and synchronizer delay handling across domains.

---

## 💻 How to Simulate (EDA Playground)
The fastest way to simulate these designs and view the waveforms is via EDA Playground.

1. Go to [EDA Playground](https://www.edaplayground.com/).
2. Copy the `design.sv` and `testbench.sv` files from either the `sync_fifo` or `async_fifo_cdc` folder.
3. Paste the codes into the respective Design and Testbench windows.
4. Select **Icarus Verilog** from the "Tools & Simulators" menu.
5. Check the **"Open EPWave after run"** box.
6. Click **Run**.
7. In the EPWave window, click **"Get Signals"**, expand your module, and append the signals to view the timing diagrams and CDC flag generation.
