class i2cmb_dut_test extends i2cmb_generator;
  `ncsu_register_object(i2cmb_dut_test);

  wb_transaction wb_trans;
  i2c_transaction i2c_trans;
  bit [WB_DATA_WIDTH-1:0] valid_bus = 8'b00010000; 
  bit [WB_DATA_WIDTH-1:0] invalid_bus = 8'b00000010; 
  bit [1:0] CSR_addr = 2'b0;
  bit [1:0] DPR_addr = 2'b1;
  bit [1:0] CMDR_addr = 2'b10;

  function new(string name="", ncsu_component_base parent=null);
		super.new(name, parent);
  endfunction

  virtual task run();

    $display("___________________");
    $display("TEST PLAN: DUT TEST");
    $display("___________________");

    i2c_trans = new;
    i2c_trans.op = WRITE; 

    fork 
      agent_i2c.bl_put(i2c_trans); 
    join_none

    $display("DUT TEST: Bus Busy and Bit Capture");

    wb_trans = new;

    // Enable I2CMB and interrupt
    wb_trans.wb_addr = CSR_addr; 
    wb_trans.wb_data = 8'b11000000;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);

    // Read from CSR
    wb_trans.wb_addr = CSR_addr;
    wb_trans.we = 0; 
    agent_wb.bl_put(wb_trans);

    if(!wb_trans.wb_data[4] && !wb_trans.wb_data[5]) 
      $display("    DUT TEST: Bus Busy and Bit Capture Start - PASS");
    else 
      $display("    DUT TEST: Bus Busy and Bit Capture Start - FAIL");


    $display("DUT TEST: Bus ID Valid");

    // Select the bus
    wb_trans.wb_addr = DPR_addr; 
    wb_trans.wb_data = 8'b00010000; // valid bus
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);

    // Setting the bus
    wb_trans.wb_addr = CMDR_addr; 
    wb_trans.wb_data = 8'b00000110;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);
    
    // Read from CMDR
    wb_trans.wb_addr = CMDR_addr;
    wb_trans.we = 0; 
    agent_wb.bl_put(wb_trans);

    if(wb_trans.wb_data[7]) 
      $display("    DUT TEST: Valid Bus ID - PASS");
    else 
      $display("    DUT TEST: Valid Bus ID - FAIL");

    // Start command
    wb_trans.wb_addr = CMDR_addr; 
    wb_trans.wb_data = 8'b00000100;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);

    // Slave address with LSB=0 indicating a WRITE
    wb_trans.wb_addr = DPR_addr; 
    wb_trans.wb_data = 8'b01000100;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);
  
    // Write command
    wb_trans.wb_addr = CMDR_addr; 
    wb_trans.wb_data = 8'b00000001;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);
    
    $display("DUT TEST: Bit Capture Freed");

    // Stop command 
    wb_trans.wb_addr = CMDR_addr; 
    wb_trans.wb_data = 8'b00000101;
    wb_trans.we = 1;
    agent_wb.bl_put(wb_trans);	

    // Read from CSR
    wb_trans.wb_addr = CSR_addr;
    wb_trans.we = 0; 
    agent_wb.bl_put(wb_trans);

    if(!wb_trans.wb_data[4]) 
      $display("    DUT TEST: Bit Capture Stop - PASS");
    else 
      $display("    DUT TEST: Bit Capture Stop - FAIL");

    $display("DUT TEST: Bus ID Invalid");

    // Select the bus
    wb_trans.wb_addr = DPR_addr; 
    wb_trans.wb_data = 8'b00000010; // invalid bus
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);

    // Setting the bus
    wb_trans.wb_addr = CMDR_addr; 
    wb_trans.wb_data = 8'b00000110;
    wb_trans.we = 1;
    agent_wb.bl_put(wb_trans);
      
    // Read from CMDR
    wb_trans.wb_addr = CMDR_addr;
    wb_trans.we = 0; 
    agent_wb.bl_put(wb_trans);

    if(wb_trans.wb_data[4]) 
      $display("    DUT TEST: Invalid Bus ID - PASS");
    else 
      $display("    DUT TEST: Invalid Bus ID - FAIL");

  endtask

endclass
