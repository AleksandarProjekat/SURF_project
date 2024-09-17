`ifndef SURF_AGENT_SV
    `define SURF_AGENT_SV

class surf_agent extends uvm_agent;

    surf_driver drv;
    surf_sequencer seqr;
    surf_monitor mon;
	
    virtual interface surf_interface s_vif;

    surf_config cfg;
    
    `uvm_component_utils_begin(surf_agent)
        `uvm_field_object(cfg,UVM_DEFAULT);
        `uvm_field_object(drv,UVM_DEFAULT);
        `uvm_field_object(seqr,UVM_DEFAULT);
        `uvm_field_object(mon,UVM_DEFAULT);
    `uvm_component_utils_end

    function new(string name = "surf_agent", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if(!uvm_config_db#(virtual surf_interface)::get(this,"","surf_interface",s_vif))
            `uvm_fatal("NOVIF", {"Virtual interface must be set:",get_full_name(),".s_vif"})

        if(!uvm_config_db#(surf_config)::get(this,"","surf_config",cfg))
            `uvm_fatal("NOCONFIG", {"Config object must be set for:",get_full_name(),".cfg"})

        uvm_config_db#(surf_config)::set(this,"mon","surf_config",cfg);
        uvm_config_db#(surf_config)::set(this,"seqr","surf_config",cfg);
        uvm_config_db#(virtual surf_interface)::set(this,"*","surf_interface",s_vif);

        mon = surf_monitor::type_id::create("mon",this);
        if(cfg.is_active == UVM_ACTIVE) 
        begin
            drv = surf_driver::type_id::create("drv",this);
            seqr = surf_sequencer::type_id::create("seqr",this);
        end
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(cfg.is_active == UVM_ACTIVE) 
        begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction : connect_phase

endclass : surf_agent 

`endif