package i2c_pkg;
	import ncsu_pkg::*;
	`include "ncsu_macros.svh"
	
	typedef enum bit { WRITE, READ } i2c_op_t;
	typedef enum int { NULL, START, DATA, STOP } status_op_t;

	string i2c_name [i2c_op_t] = '{
		WRITE : "WRITE",
		READ : "READ"
	};
   	parameter int NUM_I2C_BUSSES = 2;
   	parameter int I2C_ADDR_WIDTH = 7;
   	parameter int I2C_DATA_WIDTH = 8;


	`include "src/i2c_configuration.svh"
	`include "src/i2c_transaction.svh"
	`include "src/i2c_driver.svh"
	`include "src/i2c_monitor.svh"
	`include "src/i2c_coverage.svh"
	`include "src/i2c_agent.svh"
endpackage