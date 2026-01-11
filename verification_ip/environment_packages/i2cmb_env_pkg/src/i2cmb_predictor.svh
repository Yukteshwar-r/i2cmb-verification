class i2cmb_predictor extends ncsu_component#(.T(wb_transaction));

  ncsu_component#(.T(i2c_transaction)) scoreboard;
  i2c_transaction transport_trans;
  i2cmb_env_configuration configuration;

  bit [I2C_DATA_WIDTH-1:0] write_data[$];
  bit [I2C_DATA_WIDTH-1:0] read_data[$];
  bit [1:0] state;
  bit [I2C_DATA_WIDTH-1:0] dpr_reg;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void set_scoreboard(ncsu_component #(.T(i2c_transaction)) scoreboard);
      this.scoreboard = scoreboard;
  endfunction

  virtual function void nb_put(T trans);
    if(trans.wb_addr == 1 && trans.we == 1) begin
      dpr_reg = trans.wb_data;
    end

    case(state)
      2'b0: begin 
        if(trans.wb_addr == 2 && trans.wb_data[2:0] == 3'b100 && trans.we) begin
          state = 2'b1;
        end
      end
      
      2'b1: begin
        if(trans.wb_addr == 2 && trans.wb_data[2:0] == 3'b001 && trans.we) begin
          transport_trans = new;
          transport_trans.i2c_addr = dpr_reg[7:1];
          if(!dpr_reg[0]) begin 
            transport_trans.op = WRITE;
            state = 2'b10;
          end
          else begin 
            transport_trans.op = READ; 
            state = 2'b11;
          end
        end
      end
      
      2'b10: begin
        if(trans.wb_addr == 1 && trans.we) begin 
          write_data.push_back(dpr_reg);
          state = 2'b10;
        end
        else if(trans.wb_addr == 2 && trans.wb_data[2:0] == 3'b101 && trans.we) begin 
          state = 2'b0;
          transport_trans.i2c_compare_data = new[write_data.size()];
          foreach(transport_trans.i2c_compare_data[i]) transport_trans.i2c_compare_data[i] = write_data.pop_front();
          scoreboard.nb_transport(transport_trans, null);
          write_data.delete(); 
        end
      end
      
      2'b11: begin
        if(trans.wb_addr == 1 && !trans.we) begin 
          read_data.push_back(trans.wb_data);
          state = 2'b11;
        end
        else if(trans.wb_addr == 2 && trans.wb_data[2:0] == 3'b101 && trans.we) begin 
          state = 2'b0;
          transport_trans.i2c_compare_data = new[read_data.size()];
          foreach(transport_trans.i2c_compare_data[i]) transport_trans.i2c_compare_data[i] = read_data.pop_front(); 
          scoreboard.nb_transport(transport_trans, null);
          read_data.delete(); 
        end
      end
      
      default: begin
        state = 2'b0;
      end
    endcase
 
  endfunction

endclass 
