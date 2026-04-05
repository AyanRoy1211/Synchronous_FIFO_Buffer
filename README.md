# Synchronous FIFO RTL Design and Verification

## 📌 Project Overview
This repository contains a high-performance **Synchronous FIFO (First-In-First-Out)** buffer implemented in Verilog HDL. A FIFO is a critical component in digital systems for data buffering between modules. This specific implementation focuses on **parameterized design**, allowing for flexible data widths and depths while maintaining strict timing integrity.

This project demonstrates core VLSI competencies including:
* **RTL Coding** (Verilog)
* **Finite State Logic** & Pointer Management
* **Functional Verification** via Testbenches
* **Waveform Analysis**

## 🏗️ Architecture & Design
The design consists of a dual-port memory array and control logic to manage two independent pointers:
1.  **Write Pointer (`w_ptr`):** Tracks the next available memory location for incoming data.
2.  **Read Pointer (`r_ptr`):** Tracks the location of the next data word to be read out.
3.  **Status Logic:** Generates `Full` and `Empty` flags by comparing pointers to prevent data loss (overflow) or invalid reads (underflow).



## 🚀 Key Features
* **Parameterized:** Easily adjust `DATA_WIDTH` and `FIFO_DEPTH` at instantiation.
* **Synchronous Interface:** All operations are synchronized to a single clock edge.
* **Flag Generation:** Includes `Full`, `Empty`, and `Almost_Full` flags for robust flow control.
* **Asynchronous Reset:** Ensures a known safe state upon system power-up.

## 🛠️ Technical Specifications

### Signal Descriptions
| Signal | Type | Description |
| :--- | :--- | :--- |
| `clk` | Input | System Clock |
| `rst_n` | Input | Active-Low Asynchronous Reset |
| `w_en` | Input | Write Enable (High to push data) |
| `r_en` | Input | Read Enable (High to pop data) |
| `data_in` | Input | Input Data Bus |
| `data_out` | Output | Output Data Bus |
| `full` | Output | High when FIFO is at maximum capacity |
| `empty` | Output | High when FIFO is empty |

### Parameter Constants
* `DATA_WIDTH`: Default is **8 bits**.
* `FIFO_DEPTH`: Default is **16 words**.

## 📉 Simulation & Waveform
The design was verified using **Icarus Verilog** and **GTKWave**. The testbench covers corner cases such as simultaneous read/write, overflow scenarios, and full-depth bursts.

### Waveform Preview
*Below is a screenshot of the simulation showing successful pointer incrementing and flag transitions:*

![Waveform Analysis](waveform_screenshot.png) 
*(Note: Replace this with your actual screenshot from EDA Playground or GTKWave)*



## 💻 How to Simulate
You can run this project locally or via a web-based simulator:

### 1. Using EDA Playground (Recommended)
1.  Go to [EDA Playground](https://www.edaplayground.com/).
2.  Upload `fifo.v` and `fifo_tb.v`.
3.  Select **Icarus Verilog** or **VCS** as the simulator.
4.  Run and view the Waves.

### 2. Local Simulation (Linux/Mac/WSL)
```bash
# Clone the repository
git clone [https://github.com/AyanRoy1211/Synchronous-FIFO-RTL.git](https://github.com/AyanRoy1211/Synchronous-FIFO-RTL.git)

# Compile the design
iverilog -o fifo_sim fifo.v fifo_tb.v

# Run simulation
vvp fifo_sim

# View waveform (requires GTKWave)
gtkwave dump.vcd
