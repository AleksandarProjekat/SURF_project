`ifndef SURF_INTERFACE_SV
    `define SURF_INTERFACE_SV

interface surf_interface(input clk, logic rst , logic [47:0] ip_ena, logic [16:0] ip_addra, logic [47:0] ip_douta);

    parameter C_S00_AXI_DATA_WIDTH = 32;
    parameter C_S00_AXI_ADDR_WIDTH = 7;

    // Memory - Input image
     logic [16:0] img_addra;
     logic [47:0] img_douta;
     logic img_ena;

    // Memory - Output image
     logic [16:0] ip_addrc;
     logic [47:0] ip_doutc;
     logic ip_enc;
	 logic [47:0] img_doutc;

    // AXI Lite - Main registers
     logic [C_S00_AXI_ADDR_WIDTH -1:0] s00_axi_awaddr;
	 logic [2:0] s00_axi_awprot;
	 logic s00_axi_awvalid;
	 logic s00_axi_awready;
	 logic [C_S00_AXI_DATA_WIDTH -1:0] s00_axi_wdata;
	 logic [(C_S00_AXI_DATA_WIDTH/8) -1:0] s00_axi_wstrb;
	 logic s00_axi_wvalid;
	 logic s00_axi_wready;
	 logic [1:0] s00_axi_bresp;
	 logic s00_axi_bvalid;
	 logic s00_axi_bready;
	 logic [C_S00_AXI_ADDR_WIDTH -1:0] s00_axi_araddr;
	 logic [2:0] s00_axi_arprot;
	 logic s00_axi_arvalid;
	 logic s00_axi_arready;
	 logic [C_S00_AXI_DATA_WIDTH - 1:0] s00_axi_rdata;
	 logic [1:0] s00_axi_rresp;
	 logic s00_axi_rvalid;
	 logic s00_axi_rready;

endinterface : surf_interface

`endif 