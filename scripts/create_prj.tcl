cd ..
set root_dir [pwd]
cd scripts
set resultDir ../vivado_project

file mkdir $resultDir
#xc7z020clg400-1
create_project projekat $resultDir -part xc7z010clg400-1
set_property board_part digilentinc.com:zybo-z7-10:part0:1.2 [current_project]

# ===================================================================================
# Ukljucivanje svih izvornih i simulacionih fajlova u projekat
# ===================================================================================
add_files -norecurse ../RTL/bram.vhd
add_files -norecurse ../RTL/rom.vhd
add_files -norecurse ../RTL/ip.vhd

update_compile_order -fileset sources_1
#set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]
