`ifndef SURF_AGENT_PKG
    `define SURF_AGENT_PKG

    package surf_agent_pkg;

        import uvm_pkg::*;
        `include "uvm_macros.svh"

        import configuration_pkg::*;

        `include "surf_agent_seq_item.sv"
        `include "surf_agent_sequencer.sv"
        `include "surf_agent_driver.sv"
        `include "surf_agent_monitor.sv"
        `include "surf_agent.sv"
        

    endpackage : surf_agent_pkg

`endif 