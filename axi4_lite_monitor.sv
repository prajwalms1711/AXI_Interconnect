class axi4_lite_monitor;
    // 1. First declare class members
    virtual axi4_lite_if.monitor vif;
    mailbox #(axi4_lite_transaction) mon2sb_mb;

    covergroup cg_axi_trans;  // Will instantiate in constructor, see below
        option.per_instance = 1;

        coverpoint AWADDR {
            bins slave0[] = {[8'h00:8'h7F]};
            bins slave1[] = {[8'h80:8'hFF]};
        }
        coverpoint WDATA;
        coverpoint ARADDR {
            bins slave0[] = {[8'h00:8'h7F]};
            bins slave1[] = {[8'h80:8'hFF]};
        }
    endgroup
    
    // 2. Constructor-initialize the covergroup using with ... construct
    function new(virtual axi4_lite_if.monitor vif, mailbox #(axi4_lite_transaction) mon2sb_mb);
        this.vif = vif;
        this.mon2sb_mb = mon2sb_mb;
        cg_axi_trans = new();
        // Must use sample values, can't use vif directly!
        // So, you will have to assign class fields for sampling...
    endfunction

    // 3. Add shadow fields so you can sample values
    bit [7:0] AWADDR;
    bit [31:0] WDATA;
    bit [7:0] ARADDR;

    // Task to monitor AXI4-Lite write transactions
    task monitor_write();
        axi4_lite_transaction tr = new();
        forever begin
            @(vif.mon_cb iff vif.mon_cb.AWVALID && vif.mon_cb.AWREADY);
            tr.kind = axi4_lite_transaction::WRITE;
            tr.addr = vif.mon_cb.AWADDR;
            AWADDR = vif.mon_cb.AWADDR; // for coverage
            @(vif.mon_cb iff vif.mon_cb.WVALID && vif.mon_cb.WREADY);
            tr.wdata = vif.mon_cb.WDATA;
            tr.wstrb = vif.mon_cb.WSTRB;
            WDATA = vif.mon_cb.WDATA;
            @(vif.mon_cb iff vif.mon_cb.BVALID && vif.mon_cb.BREADY);
            tr.bresp = vif.mon_cb.BRESP;
            cg_axi_trans.sample(); // now samples .AWADDR, .WDATA etc fields
            $display("[Monitor] at %0t Sending to scoreboard from DUT",$time);
            mon2sb_mb.put(tr);
        end
    endtask

    // Task to monitor AXI4-Lite read transactions
    task monitor_read();
        axi4_lite_transaction tr = new();
        forever begin
            @(vif.mon_cb iff vif.mon_cb.ARVALID && vif.mon_cb.ARREADY);
            tr.kind = axi4_lite_transaction::READ;
            tr.addr = vif.mon_cb.ARADDR;
            ARADDR = vif.mon_cb.ARADDR;
            @(vif.mon_cb iff vif.mon_cb.RVALID && vif.mon_cb.RREADY);
            tr.rdata = vif.mon_cb.RDATA;
            tr.rresp = vif.mon_cb.RRESP;
            cg_axi_trans.sample();
            $display("[Monitor] at %0t Sending to scoreboard from DUT",$time);
            mon2sb_mb.put(tr);
        end
    endtask

    // Main run task for the monitor
    task run();
        fork
            monitor_write();
            monitor_read();
        join_none
    endtask
endclass
