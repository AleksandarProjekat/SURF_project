`ifndef SURF_SEQ_ITEM
    `define SURF_SEQ_ITEM

    parameter AXI_BASE = 7'b0000000;
    parameter FRACR_UPPER_REG_OFFSET = 0;
    parameter FRACR_LOWER_REG_OFFSET = 4;	
	parameter FRACC_UPPER_REG_OFFSET = 8;
    parameter FRACC_LOWER_REG_OFFSET = 12;	
    parameter SPACING_UPPER_REG_OFFSET = 16;
    parameter SPACING_LOWER_REG_OFFSET = 20;
    parameter I_COSE_UPPER_REG_OFFSET = 24;
    parameter I_COSE_LOWER_REG_OFFSET = 28;
    parameter I_SINE_UPPER_REG_OFFSET = 32;
    parameter I_SINE_LOWER_REG_OFFSET = 36;
    parameter IRADIUS_REG_OFFSET = 40;
    parameter IY_REG_REG_OFFSET = 44;
    parameter IX_REG_REG_OFFSET = 48;
    parameter STEP_REG_OFFSET = 52;
    parameter SCALE_REG_OFFSET = 56;
	
    parameter CMD_REG_OFFSET = 60;
    parameter STATUS_REG_OFFSET = 64;
	
    parameter C_S00_AXI_ADDR_WIDTH = 7;
    parameter C_S00_AXI_DATA_WIDTH = 32;


class surf_seq_item extends uvm_sequence_item;

    // Control signal - 0 for bram, 1 for AXI lite registers
    rand logic [2:0] bram_axi;

    // Memory - Input image
    logic [16:0] img_addra;
    logic [23:0] img_douta;
    rand logic img_ena;

    // Memory - Input image
    logic [16:0] img_addrb;
    logic [23:0] img_doutb;
    logic img_enb;
    
    // Memory - Output image
    rand logic [7:0] ip_addrc;
    rand logic [23:0] ip_doutc;
    rand logic ip_enc;

    rand logic [23:0] img_doutc;
    
   // Memory - Output image
    rand logic [7:0] ip_addrd;
    rand logic [23:0] ip_doutd;
    rand logic ip_end;

    rand logic [23:0] img_doutd;

    // AXI Lite - Main registers
    rand logic [C_S00_AXI_ADDR_WIDTH -1:0] s00_axi_awaddr;
	rand logic [2:0] s00_axi_awprot;
	rand logic s00_axi_awvalid;
	rand logic s00_axi_awready;
	rand logic [C_S00_AXI_DATA_WIDTH -1:0] s00_axi_wdata;
	rand logic [(C_S00_AXI_DATA_WIDTH/8) -1:0] s00_axi_wstrb;
	rand logic s00_axi_wvalid;
	rand logic s00_axi_wready;
	rand logic [1:0] s00_axi_bresp;
	rand logic s00_axi_bvalid;
	rand logic s00_axi_bready;
	rand logic [C_S00_AXI_ADDR_WIDTH -1:0] s00_axi_araddr;
	rand logic [2:0] s00_axi_arprot;
	rand logic s00_axi_arvalid;
	rand logic s00_axi_arready;
	rand logic [C_S00_AXI_DATA_WIDTH - 1:0] s00_axi_rdata;
	rand logic [1:0] s00_axi_rresp;
	rand logic s00_axi_rvalid;
	rand logic s00_axi_rready;

    `uvm_object_utils_begin(surf_seq_item)
        `uvm_field_int(img_addra, UVM_DEFAULT );
        `uvm_field_int(img_douta, UVM_DEFAULT );
        `uvm_field_int(img_ena, UVM_DEFAULT );

        `uvm_field_int(img_addrb, UVM_DEFAULT );
        `uvm_field_int(img_doutb, UVM_DEFAULT );
        `uvm_field_int(img_enb, UVM_DEFAULT );

        `uvm_field_int(ip_addrc, UVM_DEFAULT );
        `uvm_field_int(ip_doutc, UVM_DEFAULT );
        `uvm_field_int(ip_enc, UVM_DEFAULT );
        
        `uvm_field_int(ip_addrd, UVM_DEFAULT );
        `uvm_field_int(ip_doutd, UVM_DEFAULT );
        `uvm_field_int(ip_end, UVM_DEFAULT );
        
        `uvm_field_int(s00_axi_awaddr, UVM_DEFAULT );
        `uvm_field_int(s00_axi_awprot, UVM_DEFAULT );
        `uvm_field_int(s00_axi_awvalid, UVM_DEFAULT );
        `uvm_field_int(s00_axi_awready, UVM_DEFAULT );
        `uvm_field_int(s00_axi_wdata, UVM_DEFAULT);
        `uvm_field_int(s00_axi_wstrb, UVM_DEFAULT);
        `uvm_field_int(s00_axi_wvalid, UVM_DEFAULT);
        `uvm_field_int(s00_axi_wready, UVM_DEFAULT);
        `uvm_field_int(s00_axi_bresp, UVM_DEFAULT);
        `uvm_field_int(s00_axi_bvalid, UVM_DEFAULT);
        `uvm_field_int(s00_axi_bready, UVM_DEFAULT);
        `uvm_field_int(s00_axi_araddr, UVM_DEFAULT);
        `uvm_field_int(s00_axi_arprot, UVM_DEFAULT);
        `uvm_field_int(s00_axi_arvalid, UVM_DEFAULT);
        `uvm_field_int(s00_axi_arready, UVM_DEFAULT);
        `uvm_field_int(s00_axi_rdata, UVM_DEFAULT);
        `uvm_field_int(s00_axi_rresp, UVM_DEFAULT);
        `uvm_field_int(s00_axi_rvalid, UVM_DEFAULT);
        `uvm_field_int(s00_axi_rready, UVM_DEFAULT);
    `uvm_object_utils_end

    function new( string name = "surf_seq_item");
        super.new(name);
    endfunction : new

endclass : surf_seq_item

`endif