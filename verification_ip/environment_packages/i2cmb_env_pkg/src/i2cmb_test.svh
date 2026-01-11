class i2cmb_test extends ncsu_component;

  i2cmb_env_configuration cfg;
  i2cmb_environment env;
  i2cmb_generator gen;
  i2cmb_generator_random_reads read_gen;
  i2cmb_generator_random_writes write_gen;
  i2cmb_generator_random_alternating alt_gen;
  i2cmb_register_test register_gen;
  i2cmb_dut_test dut_gen;
  string test_name;

  function new(string name = "", ncsu_component_base parent = null); 
    super.new(name,parent);

    if ( !$value$plusargs("GEN_TRANS_TYPE=%s", test_name)) begin
      $display("FATAL: +GEN_TRANS_TYPE plusarg not found on command line");
      $fatal;
    end
    $display("%m GEN_TRANS_TYPE=%s", test_name);

    cfg = new("cfg");
    env = new("env",this);
    env.set_configuration(cfg);
    env.build();

    if (test_name == "i2cmb_register_test") begin
      register_gen = new("i2cmb_register_test",this);
      register_gen.set_wb_agent(env.get_wb_agent());
      register_gen.set_i2c_agent(env.get_i2c_agent());
    end
    else if (test_name == "i2cmb_dut_test") begin
      dut_gen = new("i2cmb_dut_test",this);
      dut_gen.set_wb_agent(env.get_wb_agent());
      dut_gen.set_i2c_agent(env.get_i2c_agent());
    end
    else if (test_name == "i2cmb_generator_random_reads") begin
      read_gen = new("i2cmb_generator_random_reads",this);
      read_gen.set_wb_agent(env.get_wb_agent());
      read_gen.set_i2c_agent(env.get_i2c_agent());
    end
    else if (test_name == "i2cmb_generator_random_writes") begin
      write_gen = new("i2cmb_generator_random_writes",this);
      write_gen.set_wb_agent(env.get_wb_agent());
      write_gen.set_i2c_agent(env.get_i2c_agent());
    end
    else if (test_name == "i2cmb_generator_random_alternating") begin
      alt_gen = new("i2cmb_generator_random_alternating",this);
      alt_gen.set_wb_agent(env.get_wb_agent());
      alt_gen.set_i2c_agent(env.get_i2c_agent());
    end
    else begin
      gen = new("gen",this);
      gen.set_wb_agent(env.get_wb_agent());
      gen.set_i2c_agent(env.get_i2c_agent());
    end
  endfunction

  virtual task run();
     env.run();
     if (test_name == "i2cmb_generator_random_reads") read_gen.run();
     else if (test_name == "i2cmb_generator_random_writes") write_gen.run();
     else if (test_name == "i2cmb_generator_random_alternating") alt_gen.run();
     else if (test_name == "i2cmb_register_test") register_gen.run();
     else if (test_name == "i2cmb_dut_test") dut_gen.run();
     else gen.run();
  endtask

endclass
