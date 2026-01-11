import i2c_pkg::*;
class i2c_transaction extends ncsu_transaction;
  `ncsu_register_object(i2c_transaction)

  bit [I2C_ADDR_WIDTH-1:0] i2c_addr;
  bit [I2C_DATA_WIDTH-1:0] i2c_write_data[];
  bit [I2C_DATA_WIDTH-1:0] i2c_read_data[];
  i2c_op_t op;
  bit transfer_complete; 
  bit [I2C_DATA_WIDTH-1:0] i2c_compare_data[];

  function new(string name=""); 
    super.new(name);
  endfunction

  virtual function string convert2string();
     return {super.convert2string(),$sformatf("i2c_addr:0x%x op:0x%x i2c_compare_data:%p", i2c_addr, op, i2c_compare_data)};
  endfunction

  function bit compare(i2c_transaction rhs);
    return((this.i2c_addr == rhs.i2c_addr) && 
            (this.op == rhs.op) &&
            (this.i2c_compare_data == rhs.i2c_compare_data));
  endfunction

endclass
