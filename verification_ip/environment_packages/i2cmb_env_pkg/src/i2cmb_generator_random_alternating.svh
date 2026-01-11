class i2cmb_generator_random_alternating extends i2cmb_generator;
  `ncsu_register_object(i2cmb_generator_random_alternating);
  
  wb_transaction wb_trans;
  i2c_transaction i2c_trans;
  i2c_transaction i2c_alt_trans[64];
  bit [7:0] alt_read;
  bit [7:0] alt_write;
  bit [1:0] CSR_addr = 2'b0;
  bit [1:0] DPR_addr = 2'b1;
  bit [1:0] CMDR_addr = 2'b10;

  function new(string name="", ncsu_component_base parent=null);
		super.new(name, parent);
  endfunction 

  // random alternating writes and reads
  virtual task run();
    i2c_trans = new;

    for (int i=0; i<64; ++i) begin
      i2c_alt_trans[i] = new;
      i2c_alt_trans[i].i2c_read_data = new[1];
      alt_read = $random;
      i2c_alt_trans[i].i2c_read_data[0] = alt_read;
    end
  
    fork begin
      for (int i = 0; i < 64; ++i) begin
        i2c_trans.op = WRITE; // writing random value
        agent_i2c.bl_put(i2c_trans);
        i2c_alt_trans[i].op = READ; // reading random value
        agent_i2c.bl_put(i2c_alt_trans[i]);
      end
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
    // Test: Alternate Writes and Reads

    $display("");
    $display("_______________________________________");
    $display("TEST: Alternate random writes and reads");
    $display("_______________________________________");

    for (int i=0; i<64; ++i) begin
      // Writing a data
      
      // Start command 
      wb_trans.wb_addr = CMDR_addr; 
      wb_trans.wb_data = 8'b00000100;
      wb_trans.we = 1;
      agent_wb.bl_put(wb_trans);      

      // Slave address with LSB=0 indicating a WRITE 
      wb_trans.wb_addr = DPR_addr; 
      wb_trans.wb_data = 8'b00001010;
      wb_trans.we = 1;
      agent_wb.bl_put(wb_trans);      

      // Write command
      wb_trans.wb_addr = CMDR_addr; 
      wb_trans.wb_data = 8'b00000001;
      wb_trans.we = 1; 
      agent_wb.bl_put(wb_trans);

      // Write data
      alt_write = $random;
      wb_trans.wb_addr = DPR_addr; 
      wb_trans.wb_data = alt_write;
      wb_trans.we = 1; 
      agent_wb.bl_put(wb_trans);

      // Write command
      wb_trans.wb_addr = CMDR_addr; 
      wb_trans.wb_data = 8'b00000001;
      wb_trans.we = 1; 
      agent_wb.bl_put(wb_trans);
                        
      // Stop command 
      wb_trans.wb_addr = CMDR_addr; 
      wb_trans.wb_data = 8'b00000101;
      wb_trans.we = 1;
      agent_wb.bl_put(wb_trans);

      //Reading a data

      // Start command
      wb_trans.wb_addr = CMDR_addr; 
      wb_trans.wb_data = 8'b00000100;
      wb_trans.we = 1;
      agent_wb.bl_put(wb_trans);

      // Slave address with LSB=1 indicating a READ
      wb_trans.wb_addr = DPR_addr; 
      wb_trans.wb_data = 8'b01000101;
      wb_trans.we = 1; 
      agent_wb.bl_put(wb_trans);

      // Write command
      wb_trans.wb_addr = CMDR_addr; 
      wb_trans.wb_data = 8'b00000001;
      wb_trans.we = 1; 
      agent_wb.bl_put(wb_trans);

      // Read command without acknowledgement indicating only read for this transaction
      wb_trans.wb_addr = CMDR_addr; 
      wb_trans.wb_data = 8'b00000011;
      wb_trans.we = 1; 
      agent_wb.bl_put(wb_trans);

      // Read data 
      wb_trans.wb_addr = DPR_addr;
      wb_trans.we = 0; 
      agent_wb.bl_put(wb_trans);

      // Stop command
      wb_trans.wb_addr = CMDR_addr; 
      wb_trans.wb_data = 8'b00000101;
      wb_trans.we = 1; 
      agent_wb.bl_put(wb_trans); 

    end

  endtask

endclass
