class i2cmb_scoreboard extends ncsu_component#(.T(i2c_transaction));
  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  T trans_in; 
  T trans_out;

  virtual function void nb_transport(input T input_trans, output T output_trans);
    $display({get_full_name()," | Expected Transaction:-  ", input_trans.convert2string()});
    this.trans_in = input_trans;
  endfunction

  virtual function void nb_put(T trans);
    trans.i2c_compare_data = new[trans.i2c_write_data.size()];
    foreach(trans.i2c_write_data[i]) begin
      trans.i2c_compare_data[i] = trans.i2c_write_data[i];
    end
    $display({get_full_name()," | Actual Transaction:-    ", trans.convert2string()});
    if(this.trans_in.compare(trans)) begin
      if(this.trans_in.op == WRITE) begin
        $display({get_full_name()," | I2C WRITE TRANSACTION MATCH"});
      end
      else if(this.trans_in.op == READ) begin
        $display({get_full_name()," | I2C READ TRANSACTION MATCH"});
      end
    end
    else begin
      if(this.trans_in.op == WRITE) begin
        $display({get_full_name()," | I2C WRITE TRANSACTION MISMATCH"});
      end
      else if(this.trans_in.op == READ) begin
        $display({get_full_name()," | I2C READ TRANSACTION MISMATCH"});
      end
    end
  endfunction
endclass


