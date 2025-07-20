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

## 📂 Directory Structure
```plaintext
axi_interconnect/
├── rtl/
│   ├── axi_interconnect.v
│   ├── axi_slave_0.v
│   ├── axi_slave_1.v
│   └── axi_master_stub.v
├── tb/
│   ├── axi_tb.v
│   ├── axi_if.sv
│   ├── driver.sv
│   ├── monitor.sv
│   ├── transaction.sv
│   ├── scoreboard.sv
│   └── axi_test.sv
├── scripts/
│   └── compile_and_simulate.do
├── reports/
│   ├── synthesis/
│   ├── timing/
│   └── area_power/
├── waveform/
│   └── axi_waveform.vcd
├── README.md
└── doc/
    └── axi_interconnect_poster.pdf
