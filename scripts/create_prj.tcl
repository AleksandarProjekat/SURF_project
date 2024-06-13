cd ..
set root_dir [pwd]
cd scripts
set resultDir ../vivado_project

file mkdir $resultDir
#xc7z020clg400-1
create_project Fault_Tolerant_FIR $resultDir -part xcku060-ffva1156-2-e
set_property board_part alpha-data.com:Kintex-Ultrascale Alphadata board:part0:1.0 [current_project]

# ===================================================================================
# Ukljucivanje svih izvornih i simulacionih fajlova u projekat
# ===================================================================================
add_files -norecurse ../RTL/bram.vhd
add_files -norecurse ../RTL/rom.vhd
add_files -norecurse ../RTL/ip.vhd

update_compile_order -fileset sources_1
