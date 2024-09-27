-uvmhome "/eda/cadence/2019-20/RHELx86/XCELIUM_19.03.013/tools/methodology/UVM/CDNS-1.2/" 
-uvm +UVM_TESTNAME=test_surf_simple +UVM_VERBOSITY=UVM_LOW
-sv +incdir+../verif
-sv +incdir+../verif/agent
-sv +incdir+../verif/axi_agent
-sv +incdir+../verif/sequence
-sv +incdir+../verif/configuration
  
../dut/utils_pkg.vhd
../dut/bram24_upper_in.vhd
../dut/bram24_lower_in.vhd
../dut/bram24_upper_out.vhd
../dut/bram24_lower_out.vhd
../dut/delay.vhd
../dut/dsp1.vhd
../dut/dsp2.vhd
../dut/dsp3.vhd
../dut/dsp4.vhd
../dut/dsp5.vhd
../dut/dsp6.vhd
../dut/dsp7.vhd
../dut/dsp8.vhd
../dut/ip_pkg.vhd

../dut/ip.vhd
../dut/rom.vhd
../dut/SURF_v1_0.vhd
../dut/SURF_v1_0_S00_AXI.vhd

-sv ../verif/configuration/configuration_pkg.sv
-sv ../verif/agent/surf_agent_pkg.sv
-sv ../verif/axi_agent/surf_axi_agent_pkg.sv
-sv ../verif/sequence/surf_sequence_pkg.sv
-sv ../verif/test_pkg.sv
-sv ../verif/surf_interface.sv
-sv ../verif/surf_top.sv

#-LINEDEBUG
-access +rwc
-disable_sem2009
-nowarn "MEMODR"
-timescale 1ns/10ps



