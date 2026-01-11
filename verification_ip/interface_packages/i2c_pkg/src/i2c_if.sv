import i2c_pkg::*;

interface automatic i2c_if #(
      int I2C_ADDR_WIDTH = 7,                                
      int I2C_DATA_WIDTH = 8                               
      )(
  // Signals
  input logic rst_i,
  input logic scl_i,
  input logic sda_i,
  output logic sda_o
);

  bit start_check = 1'b0;
  bit drive_sda = 1'b0;
  bit sda_value = 1'b1;

  bit [I2C_ADDR_WIDTH-1:0] slave_addr;
  
  always @(posedge rst_i or negedge rst_i) begin
    start_check = 1'b0;
    drive_sda = 1'b0;
    sda_value = 1'b1;
  end

  always begin
    while(start_check == 1'b0) begin
      @(negedge sda_i);
      if(scl_i && !drive_sda) start_check = 1'b1; // Start condition met
    end
    @(posedge scl_i);
    start_check = 1'b0;
  end

  task wait_for_reset(); 
    if (rst_i !== 0) @(negedge rst_i);
  endtask

  // Task to wait for and capture transfer start
  task wait_for_i2c_transfer (
    output i2c_op_t	op,
    output bit [I2C_DATA_WIDTH-1:0]	write_data []);

    write_data = new[0];  // Initialize empty dynamic array
    op = WRITE;

    //Dont check for start if already checked
    if(!start_check) begin
      do begin
        @(negedge sda_i);
      end
      while(!scl_i);
    end

    // Capture slave address
    for (int i = 0; i < I2C_ADDR_WIDTH; i++) begin
      @(posedge scl_i);
      slave_addr[I2C_ADDR_WIDTH-1-i] = sda_i;
    end
        
    // Capture R/W bit
    @(posedge scl_i);
    op = sda_i ? READ : WRITE;

    @(posedge scl_i);

    //if write
    if(op == WRITE) begin
      get_data_from_bus(op,1'b1, write_data);
    end
  endtask

  // task to get data from the bus
  task get_data_from_bus(
    input bit rw,
    input bit ack,
    output bit [I2C_DATA_WIDTH-1:0]	data []);
    int i=0;
    int count=0;
    bit stop = 1'b0;
    int data_position = I2C_DATA_WIDTH-1;
    bit [I2C_DATA_WIDTH-1:0]	temp_data [];
    temp_data = new[count+1] (temp_data);
    while(!stop) begin
      @(posedge scl_i) begin
        temp_data[count][data_position] = sda_value && sda_i; //get data
        ++i;
        --data_position;
        if(i!=0 && i%8==0) begin
          if(!ack) @(posedge scl_i); //ACK
          else drive_sda_line(1'b0);
          data_position = I2C_DATA_WIDTH-1;
          ++count;
          temp_data = new[count+1] (temp_data);
          i=0;
        end
      end
      @(posedge sda_i or negedge sda_i or negedge scl_i) begin
        if(scl_i && !drive_sda) stop = 1'b1; // stop condition
        else stop = 1'b0;
      end
    end
    data = new[temp_data.size()-1];
    for(i = 0; i<temp_data.size()-1; ++i) begin
      data[i] = temp_data[i];
    end
  endtask

  // Task to provide data when data has to be read from the i2c bus
  task provide_read_data (
    input	bit	[I2C_DATA_WIDTH-1:0]	read_data [],
    output bit transfer_complete);
    transfer_complete = 1'b0;
    for(int i = 0; i < read_data.size(); ++i) begin
      for(int j=0; j<I2C_DATA_WIDTH; ++j) begin
        drive_sda_line(read_data[i][I2C_DATA_WIDTH-1-j]);
      end
      @(posedge scl_i);
      transfer_complete = 1'b1;
    end
  endtask

  // Task to drive the sda line
  task drive_sda_line(
    input bit val);
    
    sda_value = val;
    @(posedge scl_i) begin
      drive_sda = 1;
      end
    @(negedge scl_i) begin
      drive_sda = 0;
      sda_value = 1;
    end
  endtask

  // Task to monitor the i2c interface bus
  task	monitor	(
    output bit [I2C_ADDR_WIDTH-1:0] addr,
    output i2c_op_t	op,
    output bit	[I2C_DATA_WIDTH-1:0] data	[]);

    wait_for_i2c_transfer(op, data); //write handled here itself
    addr = slave_addr;
    if(op == READ) begin //if read
      get_data_from_bus(op, 1'b0, data);
    end
  endtask

  always_comb begin 
    if (drive_sda) sda_o = sda_value;
    else sda_o = 1'b1;
  end

endinterface