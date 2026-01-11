
`timescale 1ns / 10ps

import i2c_pkg::*;

`define task1
`define task2
`define task3
//`define wb_bus_monitor
`define i2c_bus_monitor

module top();

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_BUSSES = 2;
parameter bit [WB_ADDR_WIDTH-1:0] CSR_addr = 2'b00;
parameter bit [WB_ADDR_WIDTH-1:0] DPR_addr = 2'b01;
parameter bit [WB_ADDR_WIDTH-1:0] CMDR_addr = 2'b10;
parameter bit [WB_ADDR_WIDTH-1:0] FSMR_addr = 2'b11;

bit [I2C_DATA_WIDTH-1:0] dat_i2c [];
bit [I2C_ADDR_WIDTH-1:0] addr_i2c;
i2c_op_t op;

bit  clk;
bit  rst = 1'b1;
wire cyc;
wire stb;
wire we;
tri1 ack;
wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;
wire irq;
tri  [NUM_I2C_BUSSES-1:0] scl;
triand  [NUM_I2C_BUSSES-1:0] sda;
bit  [WB_ADDR_WIDTH-1:0] adr_master_monitor;
bit  [WB_DATA_WIDTH-1:0] dat_master_monitor;
bit we_master_monitor;
bit  [WB_DATA_WIDTH-1:0] read_dat;
bit [I2C_DATA_WIDTH-1:0] slave_addr = 8'b00000010;
i2c_op_t slave_op;
bit [WB_DATA_WIDTH-1:0] master_data [];
bit [I2C_DATA_WIDTH-1:0] slave_write_data [];
bit [I2C_DATA_WIDTH-1:0] slave_read_data [];
int i;
int temp;
bit tc;


// ****************************************************************************
// Clock generator
initial clk_gen: begin
  clk = 1'b1;
  forever #5 clk = ~clk; 
end

// ****************************************************************************
// Reset generator
initial rst_gen: begin
  rst = 1'b1;
  #113 rst = 1'b0;
end

// ****************************************************************************
// Monitor Wishbone bus and display transfers in the transcript
initial wb_monitoring: begin
  forever @(posedge clk) begin
    wb_bus.master_monitor(adr_master_monitor, dat_master_monitor, we_master_monitor);
    
    `ifdef wb_bus_monitor
      if (we_master_monitor) begin
        $display("WB_BUS WRITE - Address: %0h, Data: %0h", adr_master_monitor, dat_master_monitor);
      end
      else begin
        $display("WB_BUS READ  - Address: %0h, Data: %0h", adr_master_monitor, dat_master_monitor);
      end
    `endif

  end 
end

// ****************************************************************************
// Monitor I2C bus and display transfers in the transcript
initial monitor_i2c_bus: begin
  forever @(posedge clk) begin 
    op = WRITE;
    //op.slave_addr = 0;
    i2c_bus.monitor(addr_i2c, op, dat_i2c);
    
    `ifdef i2c_bus_monitor
      if (op == WRITE) begin
        //$write("I2C_BUS WRITE -   Slave Address: 0x%h | Data: ", op.slave_addr);
        $write("I2C_BUS WRITE -   Slave Address: 0x%h | Data: ", addr_i2c);
      end
      else begin
        //$write("I2C_BUS READ  -   Slave Address: 0x%h | Data: ", op.slave_addr);
        $write("I2C_BUS READ  -   Slave Address: 0x%h | Data: ", addr_i2c);
      end
      foreach (dat_i2c[i]) begin
        $write("%0d", dat_i2c[i]);
        if (i != dat_i2c.size()-1) $write(", ");
      end
      $display("");
    `endif

  end
end

// ****************************************************************************
// Define the simulation flow for the master
initial master_test_flow: begin
  #150

  wb_bus.master_write(CSR_addr, 8'b11000000); // Enable I2CMB and interrupt

  `ifdef task1
    $display("TASK 1: Writing 32 values (0 to 31) to the I2C_bus");
    setup_bus(1'b0); 
    for(int i=0; i<32; ++i) begin
      wb_bus.master_write(DPR_addr, i); // Writing the data
      wb_bus.master_write(CMDR_addr, 8'b00000001); // Write command
      wait_for_interrupt();
    end
    wb_bus.master_write(CMDR_addr, 8'b00000101); // Stop command
    wait_for_interrupt();
    $display("");
  `endif

  `ifdef task2
    $display("TASK 2: Reading 32 values (100 to 131) from the I2C_bus");
    master_data = new[32];
    setup_bus(1'b1);
    for(int i=0; i<31; ++i) begin
      wb_bus.master_write(CMDR_addr, 8'b00000010); // Read command with acknowledgement
      wait_for_interrupt();
      wb_bus.master_read(DPR_addr, master_data[i]); // Read data 
    end
    wb_bus.master_write(CMDR_addr, 8'b00000011); // Read command with not acknowledgement
    wait_for_interrupt();
    wb_bus.master_read(DPR_addr, master_data[31]); // Read last data
    wb_bus.master_write(CMDR_addr, 8'b00000101); // Stop command
    wait_for_interrupt();
    $display("");
  `endif

  `ifdef task3
    $display("TASK 3: Alternate writes and reads for 64 transfers (Writing 64 to 127 and Reading 63 to 0)");
    master_data = new[64];
    for(int i=0; i<64; ++i) begin
      setup_bus(1'b0); //setup for write
      wb_bus.master_write(DPR_addr, i+64); // Writing the data
      wb_bus.master_write(CMDR_addr, 8'b00000001); // Write command
      wait_for_interrupt();
      wb_bus.master_write(CMDR_addr, 8'b00000101); // Stop command
      wait_for_interrupt();

      setup_bus(1'b1); // setup for read
      wb_bus.master_write(CMDR_addr, 8'b00000011); // Read command with not acknowledgement
      wait_for_interrupt();
      wb_bus.master_read(DPR_addr, master_data[i]); // Read data
      wb_bus.master_write(CMDR_addr, 8'b00000101); // Stop command
      wait_for_interrupt();
    end
    $display("");
  `endif

  #100
  $finish();
  
end

// ****************************************************************************
// Define the simulation flow for the slave
initial slave_test_flow: begin
  slave_op = WRITE;
  //slave_op.slave_addr = 0;

  `ifdef task1
    i2c_bus.wait_for_i2c_transfer(slave_op, slave_write_data);
  `endif 

  `ifdef task2
    slave_read_data = new[32];
    for(int i=100; i<132; ++i) begin
      slave_read_data[i-100] = i;
    end
    while(slave_op == WRITE) begin
      i2c_bus.wait_for_i2c_transfer(slave_op, slave_write_data);
    end
    i2c_bus.provide_read_data(slave_read_data, tc);
  `endif

  `ifdef task3
    slave_read_data = new[1];
    temp = 63;
    for(int i=0; i<128; ++i) begin
      slave_op = WRITE;
      i2c_bus.wait_for_i2c_transfer(slave_op, slave_write_data);
      if(slave_op == READ) begin
        slave_read_data[0] = temp;
        --temp;
        i2c_bus.provide_read_data(slave_read_data, tc);
      end
    end
  `endif 

end

// ****************************************************************************
// Task to set up and initialize the bus before data transfer
task setup_bus(
  bit rw
);
  wb_bus.master_write(DPR_addr, 8'b00000000); // Select the bus
  wb_bus.master_write(CMDR_addr, 8'b00000110); // Setting the bus
  wait_for_interrupt();
  wb_bus.master_write(CMDR_addr, 8'b00000100); // Start command
  wait_for_interrupt();
  if(rw) wb_bus.master_write(DPR_addr, (slave_addr << 1)|(8'h01)); // Slave address with LSB=1 indicating a READ
  else wb_bus.master_write(DPR_addr, slave_addr << 1); // Slave address with LSB=0 indicating a WRITE
  wb_bus.master_write(CMDR_addr, 8'b00000001); // Write command
  wait_for_interrupt();
endtask


// ****************************************************************************
// Task to wait for interrupt
task wait_for_interrupt();
  read_dat = 8'b00000000;
  while(!irq) @(posedge clk);
  wb_bus.master_read(CMDR_addr, read_dat);
endtask

// ****************************************************************************
// Instantiate the I2C slave interface
i2c_if  #(
      .I2C_ADDR_WIDTH(I2C_ADDR_WIDTH),
      .I2C_DATA_WIDTH(I2C_DATA_WIDTH)
      )
i2c_bus(
  .rst_i(rst),
  .scl_i(scl[1]),
  .sda_i(sda[1]),
  .sda_o(sda[1])
);

// ****************************************************************************
// Instantiate the Wishbone master Bus Functional Model
wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst),
  // Master signals
  .cyc_o(cyc),
  .stb_o(stb),
  .ack_i(ack),
  .adr_o(adr),
  .we_o(we),
  // Slave signals
  .cyc_i(),
  .stb_i(),
  .ack_o(),
  .adr_i(),
  .we_i(),
  // Shred signals
  .dat_o(dat_wr_o),
  .dat_i(dat_rd_i)
  );

// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_BUSSES)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C interfaces:
    //.scl_i({scl[NUM_I2C_BUSSES-1:1], i2c_bus.scl_o}),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    //.sda_i({sda[NUM_I2C_BUSSES-1:1], i2c_bus.sda_o}),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    //.scl_o({scl[NUM_I2C_BUSSES-1:1], i2c_bus.scl_i}),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    //.sda_o({sda[NUM_I2C_BUSSES-1:1], i2c_bus.sda_i})          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    .scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );

endmodule
