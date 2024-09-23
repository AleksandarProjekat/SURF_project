`ifndef SURF_AXI_AGENT_PKG
    `define SURF_AXI_AGENT_PKG

    package surf_axi_agent_pkg;

        import uvm_pkg::*;
        `include "uvm_macros.svh"
        `include "surf_axi_agent_seq_item.sv"
        `include "surf_axi_agent_monitor.sv"
        `include "surf_axi_agent.sv"

    endpackage : surf_axi_agent_pkg

`endif 