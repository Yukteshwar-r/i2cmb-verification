# Functional Verification of I2C Multi-Bus Controller

This project provides a comprehensive, class-based verification environment for an I2C Multi-Bus Controller. The framework implements a scalable, layered testbench designed to verify complex bus controller logic through automated randomized testing and protocol analysis.

## 🛠 Project Evolution
The project was developed in four progressive stages, culminating in a coverage-driven regression suite:

* **Project 1: Signal-Level Interface**
    * Established the foundational `i2c_if.sv`.
    * Implemented an I2C Slave model to capture transfers and provide read data with the Wishbone Master interface.
* **Project 2: Layered Testbench Architecture**
    * Developed a class-based environment featuring a Generator, Predictor, Scoreboard, and Agents.
    * Implemented verification for various transactions across both Wishbone and I2C interfaces.
* **Project 3: Test Plan & Functional Coverage**
    * Developed a Formal Verification strategy by creating a detailed test plan
* **Project 4: Coverage Closure & Bug Reporting (Final)**
    * Executed directed and randomized tests to achieve closure on the test plan.
    * Implemented automated regression scripts and formal bug reporting for identified hardware flaws.


## 🚀 Execution Instructions (Project 4)

To run the final verification suite and generate merged coverage results, follow these steps in your simulation environment:

### 1. Execute Regression Suite
The primary execution method for the final project is the `regress.sh` script located in the simulation directory. This script automates test execution, UCDB merging, and test plan linking.

```
cd project_benches/proj_4/sim
./regress.sh
```

### 2. Manual Compilation & Merging
If you need to perform steps manually using the provided Makefile:

* **Compile the Design:**

  `make compile`
* **Run a Single Simulation:**

  `make simulate`
* **Merge Simulation and Test Plan Coverage:**

  `make merge_coverage`
* **Generate HTML Coverage Report:**

  `make report_coverage`


## 📂 Repository Structure
* **verification_ip/**: Contains reusable interface and environment packages, including `i2c_pkg`, `wb_pkg`, and `i2cmb_env_pkg`.
* **project_benches/**: Sequential project directories documenting the testbench evolution from `proj_1` to `proj_4`.
* **docs/**: The testplan excel file `i2cmb_test_plan.xls`.
* **sim/**: The simulation execution directory containing `regress.sh`, `i2cmb_test_plan.xml`, and the regression `testlist`.
