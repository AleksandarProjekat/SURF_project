`ifndef SURF_AXI_MONITOR_SV
    `define SURF_AXI_MONITOR_SV 

class surf_axi_monitor extends uvm_monitor;

    // Standart control fields
    bit checks_enable = 1;
    bit coverage_enable = 1;

    uvm_analysis_port #(surf_axi_seq_item) axi_item_collected_port;

    `uvm_component_utils_begin(surf_axi_monitor)
        `uvm_field_int(checks_enable, UVM_DEFAULT)
        `uvm_field_int(coverage_enable, UVM_DEFAULT)
    `uvm_component_utils_end

    // Virtual interface
    virtual interface surf_interface s_vif;

    // Current transaction
    surf_axi_seq_item curr_it;

    // PLACE FOR COVERAGE //
    covergroup axi_write_transactions;
        option.per_instance = 1;
        option.goal = 9;
        write_address : coverpoint s_vif.s00_axi_awaddr{
            bins BASE_ADDRESS = {AXI_BASE};
            bins FRACR_UPPER_REG_INPUT = {AXI_BASE + FRACR_UPPER_REG_OFFSET};			
            bins FRACR_LOWER_REG_INPUT = {AXI_BASE + FRACR_LOWER_REG_OFFSET};
			bins FRACC_UPPER_REG_INPUT = {AXI_BASE + FRACC_UPPER_REG_OFFSET};
			bins FRACC_LOWER_REG_INPUT = {AXI_BASE + FRACC_LOWER_REG_OFFSET};
			bins SPACING_UPPER_REG_INPUT = {AXI_BASE + SPACING_UPPER_REG_OFFSET};
			bins SPACING_LOWER_REG_INPUT = {AXI_BASE + SPACING_LOWER_REG_OFFSET};
			bins I_COSE_UPPER_REG_INPUT = {AXI_BASE + I_COSE_UPPER_REG_OFFSET};
			bins I_COSE_LOWER_REG_INPUT = {AXI_BASE + I_COSE_LOWER_REG_OFFSET};
			bins I_SINE_UPPER_REG_INPUT = {AXI_BASE + I_SINE_UPPER_REG_OFFSET};
			bins I_SINE_LOWER_REG_INPUT = {AXI_BASE + I_SINE_LOWER_REG_OFFSET};
			bins IRADIUS_REG_INPUT = {AXI_BASE + IRADIUS_REG_OFFSET};
			bins IY_REG_INPUT = {AXI_BASE + IY_REG_REG_OFFSET};
			bins IX_REG_INPUT = {AXI_BASE + IX_REG_REG_OFFSET};
			bins STEP_REG_INPUT = {AXI_BASE + STEP_REG_OFFSET};
			bins SCALE_REG_INPUT = {AXI_BASE + SCALE_REG_OFFSET};
            bins CMD_REG_INPUT = {AXI_BASE + CMD_REG_OFFSET};
            bins STATUS_REG_INPUT = {AXI_BASE + STATUS_REG_OFFSET};			
					
        }

        write_data : coverpoint s_vif.s00_axi_wdata{
            bins AXI_WDATA_LOW = {0};
            bins AXI_WDATA_HIGH = {1};
            bins AXI_WDATA_PARAMETERS = {[2:442]};           ////zasto bas ovaj opseg
        }
    endgroup

    covergroup axi_read_transactions;
        option.per_instance = 1;
        option.goal = 3;
        read_address : coverpoint s_vif.s00_axi_araddr{
            bins READY_ADDRESS = {AXI_BASE + STATUS_REG_OFFSET};
        }

        read_data : coverpoint s_vif.s00_axi_rdata{
            bins READY_RDATA_LOW = {0};
            bins READY_RDATA_HIGH = {1};
        }
    endgroup

    function new(string name = "surf_axi_monitor", uvm_component parent = null);
        super.new(name,parent);
        axi_item_collected_port = new("axi_item_collected_port", this);

        axi_write_transactions = new();
        axi_read_transactions = new();

    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(!uvm_config_db#(virtual surf_interface)::get(this, "*", "surf_interface", s_vif))
            `uvm_fatal("NOVIF", {"virtual interface must be set: ", get_full_name(),".s_vif"})
    
    endfunction

    task main_phase(uvm_phase phase);
        $display("\nin UVM_AXI_AGENT_MONITOR\n");
        forever begin
            @(posedge s_vif.clk) begin
            if(s_vif.rst)
            begin
                curr_it = surf_axi_seq_item::type_id::create("curr_it", this);

                // Monitor an Axi writing transaction
                if(s_vif.s00_axi_awvalid == 1 && s_vif.s00_axi_awready == 1)
                begin
				if (s_vif.s00_axi_wstrb == 4'b1111 || s_vif.s00_axi_wstrb == 4'b0011)
                    begin
                        axi_write_transactions.sample();
                        `uvm_info(get_type_name(),$sformatf("[AXI_Monitor] Gathering information..."), UVM_MEDIUM);
                        curr_it.s00_axi_awaddr = s_vif.s00_axi_awaddr;
                        curr_it.s00_axi_wdata = s_vif.s00_axi_wdata;
                    end
                end

                // Monitor an Axi writing transaction
                if(s_vif.s00_axi_arvalid == 1 && s_vif.s00_axi_arready == 1)
                begin
                    axi_read_transactions.sample();
                    curr_it.s00_axi_rdata = s_vif.s00_axi_rdata;
                    curr_it.s00_axi_araddr = s_vif.s00_axi_araddr;
                end;

                axi_item_collected_port.write(curr_it);
            
            end
        end
    end
    endtask:main_phase
endclass:surf_axi_monitor

`endif 