class i2c_monitor extends ncsu_component#(.T(i2c_transaction));

  i2c_configuration  configuration;
  virtual i2c_if #(I2C_ADDR_WIDTH, I2C_DATA_WIDTH) bus;
  T i2c_monitor_trans;
  ncsu_component #(T) agent;
  bit [I2C_ADDR_WIDTH-1:0] i2c_addr;
  bit [I2C_DATA_WIDTH-1:0] i2c_write_data[];
  i2c_op_t op;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  function void set_agent(ncsu_component#(T) agent);
    this.agent = agent;
  endfunction

  virtual task run();
    forever begin
      i2c_monitor_trans = new("i2c_monitor_trans");
      bus.monitor(i2c_addr, op, i2c_write_data); 
      i2c_monitor_trans.i2c_addr = i2c_addr;
      i2c_monitor_trans.i2c_write_data = i2c_write_data;
      i2c_monitor_trans.op = op;
      agent.nb_put(i2c_monitor_trans); 
    end
  endtask

endclass
