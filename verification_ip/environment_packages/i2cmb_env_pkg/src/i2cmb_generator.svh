class i2cmb_generator extends ncsu_component;

  wb_transaction wb_trans;
  i2c_transaction i2c_trans;
  i2c_transaction i2c_alt_trans[64];
  wb_agent agent_wb;
  i2c_agent agent_i2c;
  bit [1:0] CSR_addr = 2'b0;
  bit [1:0] DPR_addr = 2'b1;
  bit [1:0] CMDR_addr = 2'b10;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  virtual task run();
    i2c_trans = new;
    i2c_trans.i2c_read_data = new[32];

    for (int i=0; i<32; ++i) begin
      i2c_trans.i2c_read_data[i] = i+100;
    end

    for (int i=0; i<64; ++i) begin
      i2c_alt_trans[i] = new;
      i2c_alt_trans[i].i2c_read_data = new[1];
      i2c_alt_trans[i].i2c_read_data[0] = 63-i;
    end
  
    fork 
      begin
        // Write 32 values
        i2c_trans.op = WRITE;
        agent_i2c.bl_put(i2c_trans);

        // Read 32 values
        i2c_trans.op = READ; 
        agent_i2c.bl_put(i2c_trans);

        // Alternate writes and reads
        for (int i=0; i<64; ++i) begin 
          i2c_trans.op = WRITE; 
          agent_i2c.bl_put(i2c_trans);
          i2c_alt_trans[i].op = READ;
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
    // Task 1: Write 32 incrementing values

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
  
    $display("__________________________________________________");
    $display("TASK 1: Writing 32 values (0 to 31) to the I2C_bus");
    $display("__________________________________________________");

    for (int i=0; i<32; ++i) begin
      //Writing the data
      wb_trans.wb_addr = DPR_addr; 
      wb_trans.wb_data = i;
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

    // Task 1 done				

    //-----------------------------------------------------------
    // Task 2: Read 32 incremental values			               

    // Start command
    wb_trans.wb_addr = CMDR_addr; 
    wb_trans.wb_data = 8'b00000100;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);
                          
    // Slave address with LSB=1 indicating a READ
    wb_trans.wb_addr = DPR_addr; 
    wb_trans.wb_data = 8'b00000011;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);

    // Write command
    wb_trans.wb_addr = CMDR_addr; 
    wb_trans.wb_data = 8'b00000001;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);

    $display("");
    $display("_______________________________________________________");
    $display("TASK 2: Reading 32 values (100 to 131) from the I2C_bus");
    $display("_______________________________________________________");

    for (int i=0; i<31; ++i) begin
      // Read command with acknowledgement
      wb_trans.wb_addr = CMDR_addr; 
      wb_trans.wb_data = 8'b00000010;
      wb_trans.we = 1; 
      agent_wb.bl_put(wb_trans);

      // Read data 
      wb_trans.wb_addr = DPR_addr;
      wb_trans.we = 0; 
      agent_wb.bl_put(wb_trans);
    end

    // Read command without acknowledgement to indicate last read
    wb_trans.wb_addr = CMDR_addr; 
    wb_trans.wb_data = 8'b00000011;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);

    // Read last data 
    wb_trans.wb_addr = DPR_addr;
    wb_trans.we = 0; 
    agent_wb.bl_put(wb_trans);

    // Stop command
    wb_trans.wb_addr = CMDR_addr; 
    wb_trans.wb_data = 8'b00000101;
    wb_trans.we = 1; 
    agent_wb.bl_put(wb_trans);

    // Task 2 done				

    //-----------------------------------------------------------
    // Task 3: Alternate write/read

    $display("");
    $display("___________________________________________________________________________________________");
    $display("TASK 3: Alternate writes and reads for 64 transfers (Writing 64 to 127 and Reading 63 to 0)");
    $display("___________________________________________________________________________________________");

    for (int i=0; i<64; ++i) begin
      // Write a data

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
      wb_trans.wb_addr = DPR_addr; 
      wb_trans.wb_data = i+64;
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
                      

      // Read a data

      // Start command
      wb_trans.wb_addr = CMDR_addr; 
      wb_trans.wb_data = 8'b00000100;
      wb_trans.we = 1;
      agent_wb.bl_put(wb_trans);

      // Slave address with LSB=1 indicating a READ
      wb_trans.wb_addr = DPR_addr; 
      wb_trans.wb_data = 8'b00100011;
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


  function void set_wb_agent(wb_agent agent_wb);
    this.agent_wb = agent_wb;
  endfunction

  function void set_i2c_agent(i2c_agent agent_i2c);
    this.agent_i2c = agent_i2c;
  endfunction

endclass 