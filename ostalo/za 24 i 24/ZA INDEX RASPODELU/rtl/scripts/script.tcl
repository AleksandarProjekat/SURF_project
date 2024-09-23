start_gui

# Postavljanje direktorijuma
set script_dir [file dirname [info script]]
cd $script_dir
cd ..

# Kreiranje novog projekt foldera sa brojem na kraju
proc create_new_project_folder {} {
    set base_folder "project_folder"
    set counter 1
    while {[file exists "${base_folder}${counter}"]} {
        incr counter
    }
    return "${base_folder}${counter}"
}
set project_folder [create_new_project_folder]
file mkdir $project_folder
cd $project_folder

# Kreiranje projekta
create_project surf_project surf_project -part xc7z010clg400-1
set_property board_part digilentinc.com:zybo:part0:2.0 [current_project]
set_property target_language VHDL [current_project]
set_property simulator_language VHDL [current_project]


# Dodavanje potrebnih fajlova
add_files ../models/ip.vhd
add_files ../models/bram32_in.vhd
add_files ../models/bram16_in.vhd
add_files ../models/bram32_out.vhd
add_files ../models/bram16_out.vhd
add_files ../models/ip_pkg.vhd
add_files ../models/rom.vhd
add_files ../models/delay.vhd

# Dodavanje DSP jedinica
add_files ../models/dsp1.vhd
add_files ../models/dsp2.vhd
add_files ../models/dsp3.vhd
add_files ../models/dsp4.vhd
add_files ../models/dsp5.vhd
add_files ../models/dsp6.vhd
add_files ../models/dsp7.vhd
add_files ../models/dsp8.vhd

# Dodavanje glavnih SURF modula
add_files ../models/SURF_v1_0.vhd
add_files ../models/SURF_v1_0_S00_AXI.vhd



# Dodavanje constraints fajla
add_files ../constraints/clk_constraints.xdc

# Postavljanje top modula za sintezu
set_property top SURF_v1_0 [current_fileset]

# Ažuriranje redosleda kompajliranja
update_compile_order -fileset sources_1

# Pokretanje simulacije
#launch_simulation
