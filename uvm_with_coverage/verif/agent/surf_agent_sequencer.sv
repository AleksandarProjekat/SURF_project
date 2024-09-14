`ifndef SURF_SEQUENCER_SV
    `define SURF_SEQUENCER_SV

class surf_sequencer extends uvm_sequencer#(surf_seq_item);

    `uvm_component_utils(surf_sequencer)

    surf_config cfg;

    function new(string name = "sequencer", uvm_component parent = null);
        super.new(name,parent);
			if(!uvm_config_db#(surf_config)::get(this, "", "surf_config", cfg))
				`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})    
    endfunction : new

endclass : surf_sequencer 

`endif 