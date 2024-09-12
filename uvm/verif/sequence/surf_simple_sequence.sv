`ifndef SURF_SIMPLE_SEQUENCE_SV
    `define SURF_SIMPLE_SEQUENCE_SV

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
    parameter IY_REG_OFFSET = 44;
    parameter IX_REG_OFFSET = 48;
    parameter STEP_REG_OFFSET = 52;
    parameter SCALE_REG_OFFSET = 56;
	
    parameter CMD_REG_OFFSET = 60;
    parameter STATUS_REG_OFFSET = 64;
	
	int fracr_upper, fracr_lower;
	int fracc_upper, fracc_lower;
	int spacing_upper, spacing_lower;
	int i_cose_upper, i_cose_lower;
	int i_sine_upper, i_sine_lower;
	int iradius;
	int iy;
	int ix;
	int step;
	int scale;

class surf_simple_sequence extends surf_base_sequence;

    int i = 0;
    int j = 0;

    `uvm_object_utils(surf_simple_sequence)
    surf_seq_item surf_item;

    function new(string name = "surf_simple_sequence");
        super.new(name);
    endfunction : new

    virtual task body();

        fracr_upper = p_sequencer.cfg.fracr_upper;
        fracr_lower = p_sequencer.cfg.fracr_lower;
        fracc_upper = p_sequencer.cfg.fracc_upper;
        fracc_lower = p_sequencer.cfg.fracc_lower;
        spacing_upper = p_sequencer.cfg.spacing_upper;
        spacing_lower = p_sequencer.cfg.spacing_lower;
        i_cose_upper = p_sequencer.cfg.i_cose_upper;
        i_cose_lower = p_sequencer.cfg.i_cose_lower;
        i_sine_upper = p_sequencer.cfg.i_sine_upper;
        i_sine_lower = p_sequencer.cfg.i_sine_lower;
        iradius = p_sequencer.cfg.iradius;
		iy = p_sequencer.cfg.iy;
        ix = p_sequencer.cfg.ix;
        step = p_sequencer.cfg.step;
        scale = p_sequencer.cfg.scale;


        surf_item = surf_seq_item::type_id::create("surf_item");

        //********** INITALIZATION OF THE SYSTEM **********//
        $display("AXI initalization starts...\n");
        `uvm_do_with(surf_item, { surf_item.bram_axi == 1; surf_item.s00_axi_awaddr == AXI_BASE + CMD_REG_OFFSET; surf_item.s00_axi_wdata == 32'd0;}); 

        //********** SETTING IMAGE PARAMETERS **********//
        $display("\nSetting image parameters...\n\n");
		
        // Slanje gornjih 32 bita (FRACR_UPPER_C)
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + FRACR_UPPER_REG_OFFSET;
            surf_item.s00_axi_wdata == 32'b00000000000000000000000000000000;
            s00_axi_wstrb == 4'b1111;
        });

        // Slanje donjih 16 bita (FRACR_LOWER_C)
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + FRACR_LOWER_REG_OFFSET;
            surf_item.s00_axi_wdata == {16'b0000000000000000, 16'b0100010101100110};  
            s00_axi_wstrb == 4'b0011;
        });

        // Slanje gornjih 32 bita (FRACC_UPPER_C)
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + FRACC_UPPER_REG_OFFSET;
            surf_item.s00_axi_wdata == 32'b00000000000000000000000000000000;
            s00_axi_wstrb == 4'b1111;
        });

        // Slanje donjih 16 bita (FRACC_LOWER_C)
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + FRACC_LOWER_REG_OFFSET;
            surf_item.s00_axi_wdata == {16'b0000000000000000, 16'b0100000110010011};  
            s00_axi_wstrb == 4'b0011;
        });

        // Slanje gornjih 32 bita (SPACING_UPPER_C)
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + SPACING_UPPER_REG_OFFSET;
            surf_item.s00_axi_wdata == 32'b00000000000000000000000000000000;
            s00_axi_wstrb == 4'b1111;
        });

        // Slanje donjih 16 bita (SPACING_LOWER_C)
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + SPACING_LOWER_REG_OFFSET;
            surf_item.s00_axi_wdata == {16'b0000000000000000, 16'b0100101010000000};  
            s00_axi_wstrb == 4'b0011;
        });

        // Slanje gornjih 32 bita (I_COSE_UPPER_C)
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + I_COSE_UPPER_REG_OFFSET;
            surf_item.s00_axi_wdata == 32'b11111111111111111111111111111111;  
            s00_axi_wstrb == 4'b1111;
        });

        // Slanje donjih 16 bita (I_COSE_LOWER_C)
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + I_COSE_LOWER_REG_OFFSET;
            surf_item.s00_axi_wdata == {16'b0000000000000000, 16'b1101101111011100};  
            s00_axi_wstrb == 4'b0011;
        });

        // Slanje gornjih 32 bita (I_SINE_UPPER_C)
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + I_SINE_UPPER_REG_OFFSET;
            surf_item.s00_axi_wdata == 32'b00000000000000000000000000000011;  
            s00_axi_wstrb == 4'b1111;
        });

        // Slanje donjih 16 bita (I_SINE_LOWER_C)
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + I_SINE_LOWER_REG_OFFSET;
            surf_item.s00_axi_wdata == {16'b0000000000000000, 16'b1111111101011100};  
            s00_axi_wstrb == 4'b0011;
        });

        // Slanje vrednosti za IRADIUS
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + IRADIUS_REG_OFFSET;
            surf_item.s00_axi_wdata == {21'b000000000000000000000, 11'b00000011000};  // IRADIUS = 24
            s00_axi_wstrb == 4'b1111;
        });

        // Slanje vrednosti za IY
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + IY_REG_OFFSET;
            surf_item.s00_axi_wdata == {21'b000000000000000000000, 11'b00000100000};  // IY = 32
            s00_axi_wstrb == 4'b1111;
        });

        // Slanje vrednosti za IX
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + IX_REG_OFFSET;
            surf_item.s00_axi_wdata == {21'b000000000000000000000, 11'b00000101101};  // IX = 45
            s00_axi_wstrb == 4'b1111;
        });

        // Slanje vrednosti za STEP
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + STEP_REG_OFFSET;
            surf_item.s00_axi_wdata == {21'b000000000000000000000, 11'b00000000010};  // STEP = 2
            s00_axi_wstrb == 4'b1111;
        });
		
		 // Slanje vrednosti za SCALE
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + SCALE_REG_OFFSET;
            surf_item.s00_axi_wdata == {21'b000000000000000000000, 11'b00000000100};  // STEP = 4
            s00_axi_wstrb == 4'b1111;
        });

        //********** LOADING AN IMAGE 32 **********//
        $display("\nImage32 loading begins...\n");

        $display("\nPicture32 resolution is: %d", 129*129);

        for(i = 0; i < 129*129; i ++)
        begin
			start_item(surf_item);
				surf_item.bram_axi = 0;	
							
				surf_item.img_ena = 1'b1;
				surf_item.img_addra = i*4;
				surf_item.img_douta = p_sequencer.cfg.img32_input_data[i];

       			surf_item.img_enb = 1'b1;
				surf_item.img_addrb = j*4;
				surf_item.img_doutb = p_sequencer.cfg.img16_input_data[i];

				finish_item(surf_item);
     end 
			$display("\nImage 32 i 16 loaded...\n");

		
        //  ***********************     START THE PROCESSING   ***********************//   
        $display("\nStarting the system... \n");
        `uvm_do_with(surf_item,{   surf_item.bram_axi == 1; surf_item.s00_axi_awaddr == AXI_BASE+CMD_REG_OFFSET; surf_item.s00_axi_wdata == 32'd1;});

    endtask : body

endclass : surf_simple_sequence
`endif