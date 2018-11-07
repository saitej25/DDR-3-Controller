
run:
		vsim -c work.hdltop -do "run -all; quit"
all:
	vlib work
	# HDL Compilation
	vlog -work work ./hdl/DUT_pkg.sv 
	vlog -work work ./hdl/if_top.sv
	vlog -work work ./hdl/timer.sv	
	vlog -work work ./hdl/IDDR.sv 
	vlog -work work ./hdl/ODDR.sv
	vlog -work work ./memory_model/1024Mb_ddr3_parameters.sv
	vlog -work work ./memory_model/ddr3.sv
	vlog -work work ./hdl/DUT.sv
	#vlog -work work ./hdl/*.sv 
	# HVL Compilation
	vlog -work work ./tb/top.sv 
	vlog -work work ./tb/LFSR.sv
	vlog -work work ./tb/cpu.sv
	vsim -c work.hdltop -do "run -all; quit"
design:
	# HDL Compilation
	vlog -work work ./hdl/DUT_pkg.sv 
	vlog -work work ./hdl/if_top.sv
	vlog -work work ./hdl/timer.sv	
	vlog -work work ./hdl/IDDR.sv 
	vlog -work work ./hdl/ODDR.sv
	vlog -work work ./memory_model/1024Mb_ddr3_parameters.sv
	vlog -work work ./memory_model/ddr3.sv
	vlog -work work ./hdl/DUT.sv 
	#vlog -work work ./hdl/*.sv  
update:
	# HVL Compilation		
	vlog -work work ./tb/top.sv 
	vlog -work work ./tb/LFSR.sv
	vlog -work work ./tb/cpu.sv
	vsim -c work.hdltop -do "run -all; quit"

coverage:
		vlib work
	# HDL Compilation
	vlog +cover -work work ./hdl/DUT_pkg.sv 
	vlog +cover -work work ./hdl/if_top.sv
	vlog +cover -work work ./hdl/timer.sv	
	vlog +cover -work work ./hdl/IDDR.sv 
	vlog +cover -work work ./hdl/ODDR.sv
	vlog +cover -work work ./memory_model/1024Mb_ddr3_parameters.sv
	vlog +cover -work work ./memory_model/ddr3.sv
	vlog +cover -work work ./hdl/DUT.sv 
	#vlog +cover -work work ./hdl/*.sv 
	# tb Compilation
	vlog +cover -work work ./tb/cpu.sv 
	vlog +cover -work work ./tb/LFSR.sv
	vlog +cover -work work ./tb/top.sv
	vsim -c -coverage work.hdltop -do "run -all; quit"

clean:
	rm -rf work transcript vsim.wlf

