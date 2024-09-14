`ifndef TEST_SURF_BASE_SV
    `define TEST_SURF_BASE_SV

class test_surf_base extends uvm_test;

    `uvm_component_utils(test_surf_base)

    surf_environment env;
    surf_config cfg;

    function new(string name = "test_surf_base", uvm_component parent = null);
        super.new(name,parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(),"Starting build phase...", UVM_LOW);
			cfg = surf_config::type_id::create("cfg");
			cfg.randomize();
			cfg.extracting_data();
			uvm_config_db#(surf_config)::set(this,"*","surf_config",cfg);
			env = surf_environment::type_id::create("env",this); 
    endfunction : build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction : end_of_elaboration_phase

endclass : test_surf_base

`endif    