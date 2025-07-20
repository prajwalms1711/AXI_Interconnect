# AXI4 Interconnect (1 Master, 2 Slaves)

## 📄 Overview
This project implements an **AXI4-Lite compliant Interconnect** in Verilog, supporting **one master and two slaves**.  
It ensures reliable and efficient communication between AXI-compliant master and slave devices using address-based slave selection and centralized control of the five AXI channels:  
**AW (Address Write), W (Write Data), B (Write Response), AR (Address Read), R (Read Data)**.

---

## 🚩 Features
- **AXI4-Lite Subset Compliance**
- **Address Decoder Logic**
  - Slave 0: Address Range `0x00 - 0x7F`
  - Slave 1: Address Range `0x80 - 0xFF`
- **Unified State Machine for Each Channel**
- **Protocol Verification using:**
  - Directed Verilog Testbench
  - Layered SystemVerilog UVM-like Testbench (Driver, Monitor, Scoreboard)

---


---

## 🚩 Key Features

✅ **AXI4-Lite Subset Compliance (AMBA 4)**  
✅ **One Master - Two Slaves** with address-based selection  
✅ **Dedicated State Machines for AW, W, B, AR, R**  
✅ **Seamless Data Path Switching Based on Address**  
✅ **Protocol Correctness Verified via Assertions**  
✅ **Both ASIC (TSMC 180nm) and FPGA (Artix-7) Ready**  
✅ **Modular, Reusable, Scalable Design**

---

## 🔨 Implementation Details

### Address Mapping:
| Slave   | Address Range   |
|---------|-----------------|
| Slave 0 | `0x00` - `0x7F` |
| Slave 1 | `0x80` - `0xFF` |

### State Machine Summary:
| Channel | Function                         |
|---------|----------------------------------|
| AW      | Write Address Phase Control      |
| W       | Write Data Phase Control         |
| B       | Write Response Phase Control     |
| AR      | Read Address Phase Control       |
| R       | Read Data Phase Control          |

Each channel has a simple **valid/ready handshake-compliant FSM**, ensuring AXI4-Lite protocol correctness.

---

## ✅ Verification Strategy

### 1️⃣ Directed Verilog Testbench
- Basic read/write transactions to each slave
- Invalid addresses checked for no response
- Proper back-pressure simulation

### 2️⃣ Layered SystemVerilog UVM-like Environment
- Modular classes: `driver`, `monitor`, `transaction`, `scoreboard`
- Randomized sequences, coverage driven
- Assertions to check protocol rules
- Scoreboard to verify functional correctness

### 3️⃣ Waveform Debugging
- GTKWave `.vcd` analysis for handshakes and data transactions

---

## 📈 Synthesis Results (Summary)

| Platform             | Area      | Power   | Timing      |
|-----------------------|-----------|---------|-------------|
| ASIC (TSMC 180nm)     | Optimized | Low     | Met Target  |
| FPGA (Artix-7, Vivado)| Compact   | Low     | Met Target  |

---

## 🚀 Usage Guide

### Running Simulations (ModelSim/QuestaSim)
```bash
cd scripts
vsim -do compile_and_simulate.do

