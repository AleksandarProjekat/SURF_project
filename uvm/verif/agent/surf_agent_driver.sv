`ifndef SURF_DRIVER_SV
    `define SURF_DRIVER_SV

class surf_driver extends uvm_driver#(surf_seq_item);

    `uvm_component_utils(surf_driver)

    virtual interface surf_interface s_vif;
    surf_seq_item seq_item;

    function new(string name = "surf_driver",uvm_component parent = null);
        super.new(name,parent);
        if(!uvm_config_db#(virtual surf_interface)::get(this,"","surf_interface", s_vif))
            `uvm_fatal("NOVIF",{"Virtual interface must be set for: ",get_full_name(),".s_vif"})
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction : connect_phase

    task main_phase(uvm_phase phase);
        forever begin
            @(posedge s_vif.clk);
            if(s_vif.rst)
            begin
                seq_item_port.get_next_item(req);;
                `uvm_info(get_type_name(), $sformatf("Driver sending...\n%s", req.sprint()), UVM_HIGH);
                
                if(req.bram_axi == 2'd0)
                begin
						$display("\nStarting BRAM AXI Transaction...\n");
                    s_vif.img_addra = req.img_addra;
                    s_vif.img_douta = req.img_douta;
                    s_vif.img_ena = req.img_ena;               
                end
                
                else if (req.bram_axi == 2'd3)
                begin                   
                    s_vif.ip_addrc = req.ip_addrc;
                    s_vif.ip_doutc = req.ip_doutc;
                    s_vif.ip_enc = req.ip_enc;
                end
                else
                begin   
                    //AXI write transaction
						$display("\nStarting AXI Transaction...\n");
                    s_vif.s00_axi_awaddr = req.s00_axi_awaddr;
                    s_vif.s00_axi_wdata = req.s00_axi_wdata;
                    s_vif.s00_axi_wstrb = 4'b1111;
                    s_vif.s00_axi_awvalid = 1'b1;
                    s_vif.s00_axi_wvalid = 1'b1;
                    s_vif.s00_axi_bready = 1'b1;
                    
                    @(posedge s_vif.clk iff s_vif.s00_axi_awready);
                    @(posedge s_vif.clk iff !s_vif.s00_axi_awready);
                    #20
                    
                    s_vif.s00_axi_awvalid = 1'b0;
                    s_vif.s00_axi_awaddr = 1'b0;
                    s_vif.s00_axi_wdata = 1'b0;
                    s_vif.s00_axi_wvalid = 1'b0;
                    s_vif.s00_axi_wstrb = 4'b0000;
            
                    @(posedge s_vif.clk iff !s_vif.s00_axi_bvalid); 
                    #20
                    s_vif.s00_axi_bready = 1'b0;

                    if(req.s00_axi_awaddr == AXI_BASE + CMD_REG_OFFSET && req.s00_axi_wdata == 1)
                    begin
							$display("\n Entering final detection...\n");
                        s_vif.s00_axi_arprot = 3'b000;
                        s_vif.s00_axi_araddr = AXI_BASE + STATUS_REG_OFFSET;
                        s_vif.s00_axi_arvalid = 1'b1;
                        s_vif.s00_axi_rready = 1'b1;

                        @(posedge s_vif.clk iff s_vif.s00_axi_arready == 0);
                        @(posedge s_vif.clk iff s_vif.s00_axi_arready == 1);

                        s_vif.s00_axi_araddr = 7'd0;
                        s_vif.s00_axi_arvalid = 1'b0;

                        wait(s_vif.s00_axi_rdata == 0)

							$display ("\nSystem on the go!\n");
                        s_vif.s00_axi_awaddr = AXI_BASE + CMD_REG_OFFSET;
                        s_vif.s00_axi_wdata = 32'd0;
                        s_vif.s00_axi_wstrb = 4'b1111;
                        s_vif.s00_axi_awvalid = 1'b1;
                        s_vif.s00_axi_wvalid = 1'b1;
                        s_vif.s00_axi_bready = 1'b1;

                        @(posedge s_vif.clk iff s_vif.s00_axi_awready);
                        @(posedge s_vif.clk iff !s_vif.s00_axi_awready);
                        #20
                        
                        s_vif.s00_axi_awvalid = 1'b0;
                        s_vif.s00_axi_awaddr = 1'b0;
                        s_vif.s00_axi_wdata = 1'b0;
                        s_vif.s00_axi_wvalid = 1'b0;
                        s_vif.s00_axi_wstrb = 4'b0000;

                        @(posedge s_vif.clk iff !s_vif.s00_axi_bvalid); 
                        #20
                        s_vif.s00_axi_bready = 1'b0;
							$display("\nStart signal taken down! \n");
							$display("\nWaiting for a finishing ready...\n");
                        #20
                        s_vif.s00_axi_arprot = 3'b000;
                        s_vif.s00_axi_araddr = AXI_BASE + STATUS_REG_OFFSET;
                        s_vif.s00_axi_arvalid = 1'b1;
                        s_vif.s00_axi_rready  = 1'b1;  

                        @(posedge s_vif.clk iff s_vif.s00_axi_arready == 0);
                        @(posedge s_vif.clk iff s_vif.s00_axi_arready == 1);
        
                        wait(s_vif.s00_axi_rdata == 1)
                        s_vif.s00_axi_araddr = 7'd0;
                        s_vif.s00_axi_arvalid = 1'b0;

							$display("\nDUT finished! \n");                   
                    end
							$display("\nAxi Lite transaction completed! \n");
                end
				seq_item_port.item_done();  
			end      
		end
	endtask : main_phase

endclass : surf_driver

`endif 
