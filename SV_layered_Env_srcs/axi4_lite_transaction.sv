`ifndef AXI4_LITE_TRANSACTION_SV
`define AXI4_LITE_TRANSACTION_SV

class axi4_lite_transaction;
    typedef enum {READ, WRITE} kind_e; // Transaction kind: READ or WRITE
    
    rand kind_e kind;                  // Type of transaction
    rand bit [7:0] addr;               // AXI4-Lite address (8-bit)
    rand bit [31:0] wdata;             // Write data (32-bit)
    rand bit [3:0] wstrb;              // Write strobe (4-bit)

    bit [31:0] rdata;                  // Read data (32-bit) - filled by monitor/scoreboard
    bit [1:0] bresp;                   // Write response (2-bit) - filled by monitor
    bit [1:0] rresp;                   // Read response (2-bit) - filled by monitor

    // Constraint to ensure valid address range for slave 0 (0x00 to 0x7F) and slave 1 (0x80 to 0xFF)
    // Assuming SLAVE0_ADDR_MAX = 8'h7F from DUT
    constraint addr_range_c {
        addr >= 8'h00;
        addr <= 8'hFF;
    }

    // Constraint for write strobe: at least one bit must be set for a valid write
    constraint wstrb_c {
        if (kind == WRITE) {
            wstrb != 4'b0000;
        }
    }

    // Constructor
    function new();
    endfunction

    // Function to display transaction details
    function void display(string name = "Transaction");
        $display("[%0t] %s: %s, Addr: 0x%0h", $time, name, kind.name(), addr);
        if (kind == WRITE) begin
            $display("    WData: 0x%0h, WStrb: 0x%0h", wdata, wstrb);
            $display("    BResp: %0b", bresp);
        end else begin // READ
            $display("    RData: 0x%0h, RResp: %0b", rdata, rresp);
        end
    endfunction

    // Function to compare two transactions (useful for scoreboard)
    function bit compare(axi4_lite_transaction other);
        if (this.kind != other.kind) return 0;
        if (this.addr != other.addr) return 0;
        if (this.kind == WRITE) begin
            if (this.wdata != other.wdata) return 0;
            if (this.wstrb != other.wstrb) return 0;
            // For write, bresp is compared by scoreboard, not part of initial transaction
        end
        // For read, rdata and rresp are filled by monitor, not part of initial transaction
        return 1;
    endfunction

endclass
`endif