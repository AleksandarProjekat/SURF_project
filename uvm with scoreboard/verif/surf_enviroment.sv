`ifndef SURF_ENVIRONMENT_SV
    `define SURF_ENVIRONMENT_SV
    
    class surf_environment extends uvm_env;
    
    surf_agent agent; 
    surf_axi_agent axi_agent;
    
    surf_config cfg;
    surf_scoreboard s_scbd;

    virtual interface surf_interface s_vif;
    `uvm_component_utils (surf_environment)

    function new(string name = "surf_environment" , uvm_component parent = null);  
       super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Getting interfaces from configuration base //
        if (!uvm_config_db#(virtual surf_interface)::get(this, "", "surf_interface", s_vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".s_vif"})

        if (!uvm_config_db#(surf_config)::get(this, "", "surf_config", cfg))
            `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".cfg"})

         // Setting to configurartion base //
        uvm_config_db#(surf_config)::set(this, "agent", "surf_config", cfg);
        uvm_config_db#(surf_config)::set(this, "s_scbd","surf_config", cfg);
        uvm_config_db#(virtual surf_interface)::set(this, "agent", "surf_interface", s_vif);
        uvm_config_db#(virtual surf_interface)::set(this, "axi_agent", "surf_interface", s_vif);

        agent = surf_agent::type_id::create("agent",this);
        axi_agent = surf_axi_agent::type_id::create("axi_agent",this);
        //Dodavanje scoreboard-a
        s_scbd = surf_scoreboard::type_id::create("s_scbd",this);
    endfunction : build_phase   
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.mon.item_collected_port.connect(s_scbd.item_collected_import);
    endfunction
    
    
    endclass : surf_environment

`endif    