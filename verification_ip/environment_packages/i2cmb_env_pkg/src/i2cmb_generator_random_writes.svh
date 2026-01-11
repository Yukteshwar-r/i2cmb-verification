class i2cmb_generator_random_writes extends i2cmb_generator;
  `ncsu_register_object(i2cmb_generator_random_writes);
  wb_transaction wb_trans;
  i2c_transaction i2c_trans;
  bit [7:0] random_write;
  bit [1:0] CSR_addr = 2'b0;
  bit [1:0] DPR_addr = 2'b1;
  bit [1:0] CMDR_addr = 2'b10;

  function new(string name="", ncsu_component_base parent=null);
		super.new(name, parent);
  endfunction 

  // random writes
  virtual task run();
    i2c_trans = new;

    fork begin
      i2c_trans.op = WRITE; // writing random values
      agent_i2c.bl_put(i2c_trans);
    end
    join_none

    wb_trans = new;

    // Enable I2CMB and interrupt
    wb_trans.wb_addr = CSR_addr; 
    wb_trans.wb_data = 8'b11000000;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);

    // Select the bus
    wb_trans.wb_addr = DPR_addr; 
    wb_trans.wb_data = 8'b00000000;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);

    // Setting the bus
    wb_trans.wb_addr = CMDR_addr; 
    wb_trans.wb_data = 8'b00000110;
    wb_trans.we = 1;
    agent_wb.bl_put(wb_trans);

    //-----------------------------------------------------------
    // Test: Write 32 random values

    // Start command
    wb_trans.wb_addr = CMDR_addr; 
    wb_trans.wb_data = 8'b00000100;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);

    // Slave address with LSB=0 indicating a WRITE
    wb_trans.wb_addr = DPR_addr; 
    wb_trans.wb_data = 8'b00000010;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);

    // Write command
    wb_trans.wb_addr = CMDR_addr; 
    wb_trans.wb_data = 8'b00000001;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);
  
    $display("_____________________________________________");
    $display("TEST: Writing 32 random values to the I2C_bus");
    $display("_____________________________________________");

    for (int i=0; i<32; ++i) begin
      //Writing the data
      random_write = $random;
      wb_trans.wb_addr = DPR_addr; 
      wb_trans.wb_data = random_write;
      wb_trans.we = 1; 
      agent_wb.bl_put(wb_trans);

      // Write command
      wb_trans.wb_addr = CMDR_addr; 
      wb_trans.wb_data = 8'b00000001;
      wb_trans.we = 1; 
      agent_wb.bl_put(wb_trans);		
    end

    // Stop command 
    wb_trans.wb_addr = CMDR_addr; 
    wb_trans.wb_data = 8'b00000101;
    wb_trans.we = 1;
    agent_wb.bl_put(wb_trans);	

  endtask

endclass
