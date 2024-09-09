`ifndef SURF_SEQUENCE_PKG_SV
    `define SURF_SEQUENCE_PKG_SV

    package surf_sequence_pkg;

        import uvm_pkg::*;            
        `include "uvm_macros.svh"          
		
        import surf_agent_pkg::surf_seq_item;
        import surf_agent_pkg::surf_sequencer;
		
        `include "surf_base_sequence.sv"
        `include "surf_simple_sequence.sv"
    endpackage
`endif 