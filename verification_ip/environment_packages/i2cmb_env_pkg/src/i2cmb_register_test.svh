class i2cmb_register_test extends i2cmb_generator;
  `ncsu_register_object(i2cmb_register_test);
  
  wb_transaction wb_trans;
  bit [WB_DATA_WIDTH-1:0] pre_core[4];
  bit [WB_DATA_WIDTH-1:0] post_core[4];
  bit [WB_DATA_WIDTH-1:0] post_write[4]; 
  bit [1:0] CSR_addr = 2'b0;
  bit [1:0] DPR_addr = 2'b1;
  bit [1:0] CMDR_addr = 2'b10;
  bit [1:0] FSMR_addr = 2'b11;

  function new(string name="", ncsu_component_base parent=null);
			super.new(name, parent);
  endfunction 

  virtual task run();

    $display("________________________");
    $display("TEST PLAN: REGISTER TEST");
    $display("________________________");

    $display("REGISTER TEST: Register Default Values");

    wb_trans = new;

    // Default CSR value
    wb_trans.wb_addr = CSR_addr;
    wb_trans.we = 0; 
    agent_wb.bl_put(wb_trans);
    pre_core[0] = wb_trans.wb_data;

    // Default DPR value
    wb_trans.wb_addr = DPR_addr;
    wb_trans.we = 0; 
    agent_wb.bl_put(wb_trans);
    pre_core[1] = wb_trans.wb_data;

    // Default CMDR value
    wb_trans.wb_addr = CMDR_addr;
    wb_trans.we = 0; 
    agent_wb.bl_put(wb_trans);
    pre_core[2] = wb_trans.wb_data;

    // Default FSMR value
    wb_trans.wb_addr = FSMR_addr;
    wb_trans.we = 0; 
    agent_wb.bl_put(wb_trans);
    pre_core[3] = wb_trans.wb_data;

    if (pre_core[0] == 8'b00000000 && pre_core[1] == 8'b00000000 && pre_core[2] == 8'b10000000 && pre_core[3] == 8'b00000000) 
      $display("    REGISTER TEST: Register Default Values - PASS");
    else 
      $display("    REGISTER TEST: Register Default Values - FAIL");

    $display("REGISTER TEST: Register Core Reset");

    wb_trans = new;

    // Enable I2CMB and interrupt
    wb_trans.wb_addr = CSR_addr; 
    wb_trans.wb_data = 8'b11000000;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);

    // Read CSR value 
    wb_trans.wb_addr = CSR_addr;
    wb_trans.we = 0;
    agent_wb.bl_put(wb_trans);
    post_core[0] = wb_trans.wb_data;

    // Read DPR value 
    wb_trans.wb_addr = DPR_addr;
    wb_trans.we = 0;
    agent_wb.bl_put(wb_trans);
    post_core[1] = wb_trans.wb_data;

    // Read CMDR value 
    wb_trans.wb_addr = CMDR_addr;
    wb_trans.we = 0;
    agent_wb.bl_put(wb_trans);
    post_core[2] = wb_trans.wb_data;

    // Read FSMR value 
    wb_trans.wb_addr = FSMR_addr;
    wb_trans.we = 0;
    agent_wb.bl_put(wb_trans);
    post_core[3] = wb_trans.wb_data;


    if (post_core[0] == 8'b11000000 && post_core[1] == 8'b00000000 && post_core[2] == 8'b10000000 && post_core[3] == 8'b00000000)
      $display("   REGISTER TEST: Register Core Reset - PASS");
    else 
      $display("   REGISTER TEST: Register Core Reset - FAIL");

    $display("REGISTER TEST: Register Aliasing");

    wb_trans = new;

    // Write to CSR 
    wb_trans.wb_addr = CSR_addr; 
    wb_trans.wb_data = 8'b11111111;
    wb_trans.we = 1;
    agent_wb.bl_put(wb_trans);

    // Read DPR value after writing to CSR
    wb_trans.wb_addr = DPR_addr;
    wb_trans.we = 0;
    agent_wb.bl_put(wb_trans);
    post_write[1] = wb_trans.wb_data;

    // Read CMDR value after writing to CSR 
    wb_trans.wb_addr = CMDR_addr;
    wb_trans.we = 0;
    agent_wb.bl_put(wb_trans);
    post_write[2] = wb_trans.wb_data;

    // Read FSMR value after writing to CSR
    wb_trans.wb_addr = FSMR_addr;
    wb_trans.we = 0;
    agent_wb.bl_put(wb_trans);
    post_write[3] = wb_trans.wb_data;

    if (post_write[1] == 8'b00000000 && post_write[2] == 8'b10000000 && post_write[3] == 8'b00000000) 
      $display("    REGISTER TEST: Register Aliasing - CSR PASS");
    else 
      $display("    REGISTER TEST: Register Aliasing - CSR FAIL");

    // Write to DPR
    wb_trans.wb_addr = DPR_addr; 
    wb_trans.wb_data = 8'b11111111;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);

    // Read CSR value after writing to DPR
    wb_trans.wb_addr = CSR_addr;
    wb_trans.we = 0; 
    agent_wb.bl_put(wb_trans);
    post_write[0] = wb_trans.wb_data;

    // Read CMDR value after writing to DPR
    wb_trans.wb_addr = CMDR_addr;
    wb_trans.we = 0; 
    agent_wb.bl_put(wb_trans);
    post_write[2] = wb_trans.wb_data;

    // Read FSMR value after writing to DPR
    wb_trans.wb_addr = FSMR_addr;
    wb_trans.we = 0; 
    agent_wb.bl_put(wb_trans);
    post_write[3] = wb_trans.wb_data;

    if (post_write[0] == 8'b11000000 && post_write[2] == 8'b10000000 && post_write[3] == 8'b00000000) 
      $display("    REGISTER TEST: Register Aliasing - DPR PASS");
    else 
      $display("    REGISTER TEST: Register Aliasing - DPR FAIL");

    // Write to CMDR
    wb_trans.wb_addr = CMDR_addr; 
    wb_trans.wb_data = 8'b11111111;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);

    // Read CSR value after writing to CMDR
    wb_trans.wb_addr = CSR_addr;
    wb_trans.we = 0; 
    agent_wb.bl_put(wb_trans);
    post_write[0] = wb_trans.wb_data;

    // Read DPR value after writing to CMDR
    wb_trans.wb_addr = DPR_addr;
    wb_trans.we = 0; 
    agent_wb.bl_put(wb_trans);
    post_write[1] = wb_trans.wb_data;

    // Read FSMR value after writing to CMDR
    wb_trans.wb_addr = FSMR_addr;
    wb_trans.we = 0; 
    agent_wb.bl_put(wb_trans);
    post_write[3] = wb_trans.wb_data; 

    if (post_write[0] == 8'b11000000 && post_write[1] == 8'b00000000 && post_write[3] == 8'b00000000) 
      $display("    REGISTER TEST: Register Aliasing - CMDR PASS");
    else 
      $display("    REGISTER TEST: Register Aliasing - CMDR FAIL");

    // Write to FSMR
    wb_trans.wb_addr = FSMR_addr; 
    wb_trans.wb_data = 8'b11111111;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);

    // Read CSR value after writing to FSMR
    wb_trans.wb_addr = CSR_addr;
    wb_trans.we = 0; 
    agent_wb.bl_put(wb_trans);
    post_write[0] = wb_trans.wb_data;

    // Read DPR value after writing to FSMR
    wb_trans.wb_addr = DPR_addr;
    wb_trans.we = 0; 
    agent_wb.bl_put(wb_trans);
    post_write[1] = wb_trans.wb_data;

    // Read CMDR value after writing to FSMR
    wb_trans.wb_addr = CMDR_addr;
    wb_trans.we = 0; 
    agent_wb.bl_put(wb_trans);
    post_write[2] = wb_trans.wb_data;

    if (post_write[0] == 8'b11000000 && post_write[1] == 8'b00000000 && post_write[2] == 8'b00010111) 
      $display("    REGISTER TEST: Register Aliasing - FSMR PASS");
    else 
      $display("    REGISTER TEST: Register Aliasing - FSMR FAIL");

    $display("REGISTER TEST: Register Permissions");

    wb_trans = new; 

    // CSR access test
    wb_trans.wb_addr = CSR_addr; 
    wb_trans.wb_data = 8'b11111111;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);
    wb_trans.we = 0;
    agent_wb.bl_put(wb_trans);

    if (wb_trans.wb_data == 8'b11000000) 
      $display("    REGISTER TEST: Register Permissions - CSR PASS");
    else 
      $display("    REGISTER TEST: Register Permissions - CSR FAIL");

    // DPR access test
    wb_trans.wb_addr = DPR_addr; 
    wb_trans.wb_data = 8'b11111111;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);
    wb_trans.we = 0;
    agent_wb.bl_put(wb_trans);

    if (wb_trans.wb_data == 8'b00000000) 
      $display("    REGISTER TEST: Register Permissions - DPR PASS");
    else 
      $display("    REGISTER TEST: Register Permissions - DPR FAIL");

  endtask

endclass
