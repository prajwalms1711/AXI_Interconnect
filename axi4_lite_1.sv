module axi4_lite_1 (

input wire ACLK,

input wire ARESETN,



// Write address channel

input wire [7:0] AWADDR,

input wire AWVALID,

output reg AWREADY,



// Write data channel

input wire [31:0] WDATA,

input wire [3:0] WSTRB,

input wire WVALID,

output reg WREADY,



// Write response channel

output reg [1:0] BRESP,

output reg BVALID,

input wire BREADY,



// Read address channel

input wire [7:0] ARADDR,

input wire ARVALID,

output reg ARREADY,



// Read data channel

output reg [31:0] RDATA,

output reg [1:0] RRESP,

output reg RVALID,

input wire RREADY

);



parameter SLAVE0_ADDR_MAX = 8'h7F;



// Two 128x32 memories

reg [31:0] mem_slave0 [0:127];

reg [31:0] mem_slave1 [0:127];



// Internal registers for address, selection, and handshake

reg [7:0] awaddr_reg, araddr_reg;

reg aw_slave_select, ar_slave_select;

reg awvalid_reg, wvalid_reg, arvalid_reg;



// Address calculation registers

reg [6:0] addr_write; // Address within a slave is 7 bits (0-127)

reg [6:0] addr_read; // Address within a slave is 7 bits (0-127)



// Write address handshake

always @(posedge ACLK or negedge ARESETN) begin

if (!ARESETN) begin

AWREADY <= 1'b0;

awaddr_reg <= 8'd0;

aw_slave_select <= 1'b0;

awvalid_reg <= 1'b0;

end else begin

// Default state for AWREADY

if (AWREADY) AWREADY <= 1'b0;



// When a new valid address appears and we are not already busy

if (!AWREADY && AWVALID && !awvalid_reg) begin

AWREADY <= 1'b1;

awaddr_reg <= AWADDR;

aw_slave_select <= (AWADDR <= SLAVE0_ADDR_MAX) ? 1'b0 : 1'b1;

awvalid_reg <= 1'b1;

end


// De-assert awvalid_reg after the write response is accepted

if (BVALID && BREADY) begin

awvalid_reg <= 1'b0;

end

end

end



// Write data handshake

always @(posedge ACLK or negedge ARESETN) begin

if (!ARESETN) begin

WREADY <= 1'b0;

wvalid_reg <= 1'b0;

end else begin

if (WREADY) WREADY <= 1'b0;



if (!WREADY && WVALID && !wvalid_reg) begin

WREADY <= 1'b1;

wvalid_reg <= 1'b1;

end


if (BVALID && BREADY) begin

wvalid_reg <= 1'b0;

end

end

end



// Write operation and response

always @(posedge ACLK or negedge ARESETN) begin

if (!ARESETN) begin

BRESP <= 2'b00;

BVALID <= 1'b0;

addr_write <= 7'd0;

end else begin

if (BVALID && BREADY) begin

BVALID <= 1'b0;

end



if (awvalid_reg && wvalid_reg && !BVALID) begin

// Address decode (use only lower 7 bits for memory index)

addr_write = aw_slave_select ? (awaddr_reg[6:0]) : awaddr_reg[6:0];



// Write operation

if (!aw_slave_select) begin

if (WSTRB[0]) mem_slave0[addr_write][7:0] <= WDATA[7:0];

if (WSTRB[1]) mem_slave0[addr_write][15:8] <= WDATA[15:8];

if (WSTRB[2]) mem_slave0[addr_write][23:16] <= WDATA[23:16];

if (WSTRB[3]) mem_slave0[addr_write][31:24] <= WDATA[31:24];

end else begin

if (WSTRB[0]) mem_slave1[addr_write][7:0] <= WDATA[7:0];

if (WSTRB[1]) mem_slave1[addr_write][15:8] <= WDATA[15:8];

if (WSTRB[2]) mem_slave1[addr_write][23:16] <= WDATA[23:16];

if (WSTRB[3]) mem_slave1[addr_write][31:24] <= WDATA[31:24];

end



BRESP <= 2'b00; // OKAY

BVALID <= 1'b1;

end

end

end



// Read address handshake

always @(posedge ACLK or negedge ARESETN) begin

if (!ARESETN) begin

ARREADY <= 1'b0;

araddr_reg <= 8'd0;

ar_slave_select <= 1'b0;

arvalid_reg <= 1'b0;

end else begin

if(ARREADY) ARREADY <= 1'b0;



if (!ARREADY && ARVALID && !arvalid_reg) begin

ARREADY <= 1'b1;

araddr_reg <= ARADDR;

ar_slave_select <= (ARADDR <= SLAVE0_ADDR_MAX) ? 1'b0 : 1'b1;

arvalid_reg <= 1'b1;

end


if (RVALID && RREADY) begin

arvalid_reg <= 1'b0;

end

end

end



// Read data channel

always @(posedge ACLK or negedge ARESETN) begin

if (!ARESETN) begin

RDATA <= 32'd0;

RRESP <= 2'b00;

RVALID <= 1'b0;

addr_read <= 7'd0;

end else begin

if (RVALID && RREADY) begin

RVALID <= 1'b0;

end


if (arvalid_reg && !RVALID) begin

// Address decode

addr_read = ar_slave_select ? araddr_reg[6:0] : araddr_reg[6:0];



// Read operation

RDATA <= !ar_slave_select ? mem_slave0[addr_read] : mem_slave1[addr_read];

RRESP <= 2'b00; // OKAY

RVALID <= 1'b1;

end

end

end

endmodule