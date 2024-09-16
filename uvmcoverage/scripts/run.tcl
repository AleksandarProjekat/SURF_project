cd ..
set root_dir [pwd]
cd scripts
set resultDir ../uvm_project

file mkdir $resultDir

create_project surf_col $resultDir -part xc7z010clg400-1
set_property board_part digilentinc.com:zybo:part0:2.0 [current_project]

# ===================================================================================
# Ukljucivanje svih izvornih i simulacionih fajlova u projekat
# ===================================================================================

add_files -norecurse ../dut/bram32_in.vhd
add_files -norecurse ../dut/bram16_in.vhd
add_files -norecurse ../dut/bram32_out.vhd
add_files -norecurse ../dut/bram16_out.vhd
add_files -norecurse ../dut/delay.vhd
add_files -norecurse ../dut/dsp1.vhd
add_files -norecurse ../dut/dsp2.vhd
add_files -norecurse ../dut/dsp3.vhd
add_files -norecurse ../dut/dsp4.vhd
add_files -norecurse ../dut/dsp5.vhd
add_files -norecurse ../dut/dsp6.vhd
add_files -norecurse ../dut/dsp7.vhd
add_files -norecurse ../dut/dsp8.vhd
add_files -norecurse ../dut/ip.vhd
add_files -norecurse ../dut/ip_pkg.vhd
add_files -norecurse ../dut/rom.vhd
add_files -norecurse ../dut/SURF_v1_0.vhd
add_files -norecurse ../dut/SURF_v1_0_S00_AXI.vhd
add_files -norecurse ../dut/utils_pkg.vhd


update_compile_order -fileset sources_1

set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ../verif/axi_agent/surf_axi_agent_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ../verif/agent/surf_agent_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ../verif/configuration/configuration_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ../verif/sequence/surf_sequence_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ../verif/test_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ../verif/surf_interface.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ../verif/surf_top.sv

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Ukljucivanje uvm biblioteke

set_property -name {xsim.compile.xvlog.more_options} -value {-L uvm} -objects [get_filesets sim_1]
set_property -name {xsim.elaborate.xelab.more_options} -value {-L uvm} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.xsim.more_options} -value {-testplusarg UVM_TESTNAME=test_surf_simple -testplusarg UVM_VERBOSITY=UVM_MEDIUM -sv_seed random} -objects [get_filesets sim_1]

set_property target_language VHDL [current_project]
set_property -name {xsim.simulate.runtime} -value {500 ms} -objects [get_filesets sim_1]

