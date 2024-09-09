`ifndef SURF_AXI_AGENT_SV
    `define SURF_AXI_AGENT_SV

class surf_axi_agent extends uvm_agent;
    
    surf_axi_monitor axi_mon;

    virtual interface surf_interface s_vif;
    
    `uvm_component_utils_begin(surf_axi_agent)
        `uvm_field_object(axi_mon,UVM_DEFAULT)
    `uvm_component_utils_end

    function new(string name = "surf_axi_agent", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        //checking if the interface is set for this component
        if(!uvm_config_db#(virtual surf_interface)::get(this,"","surf_interface",s_vif))
            `uvm_fatal("NOVIF", {"Virtual interface must be set:",get_full_name(),".s_vif"})

        //setting virtual interface s_vif
        uvm_config_db#(virtual surf_interface)::set(this,"*","surf_interface",s_vif);

        axi_mon = surf_axi_monitor::type_id::create("axi_mon",this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction : connect_phase

endclass : surf_axi_agent 

`endif