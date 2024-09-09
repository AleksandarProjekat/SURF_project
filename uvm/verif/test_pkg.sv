`ifndef TEST_PKG_SV
    `define TEST_PKG_SV

package test_pkg; 
    
        import uvm_pkg::*;
        `include "uvm_macros.svh"

        import surf_agent_pkg::*;
        import surf_axi_agent_pkg::*;
        import surf_sequence_pkg::*;
        import configuration_pkg::*;

        `include "surf_scoreboard.sv"
        `include "surf_enviroment.sv"
        `include "test_surf_base.sv"
        `include "test_surf_simple.sv"

endpackage : test_pkg

    `include "surf_interface.sv"

`endif