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
    parameter IY_REG_REG_OFFSET = 44;
    parameter IX_REG_REG_OFFSET = 48;
    parameter STEP_REG_OFFSET = 52;
    parameter SCALE_REG_OFFSET = 56;
	
    parameter CMD_REG_OFFSET = 60;
    parameter STATUS_REG_OFFSET = 64;
	
	int rows, cols;

class surf_simple_sequence extends surf_base_sequence;

    int i = 0;
    int j = 0;
    int k = 0;

    `uvm_object_utils(surf_simple_sequence)
    surf_seq_item surf_item;

    function new(string name = "surf_simple_sequence");
        super.new(name);
    endfunction : new

    virtual task body();

        rows = p_sequencer.cfg.rows;
        cols = p_sequencer.cfg.cols;

        surf_item = surf_seq_item::type_id::create("surf_item");

        //********** INITALIZATION OF THE SYSTEM **********//
        $display("AXI initalization starts...\n");
        `uvm_do_with(surf_item, { surf_item.bram_axi == 1; surf_item.s00_axi_awaddr == AXI_BASE + CMD_REG_OFFSET; surf_item.s00_axi_wdata == 32'd0;}); 

        //********** SETTING IMAGE PARAMETERS **********//
        $display("\nSetting image parameters...\n\n");
			`uvm_do_with(surf_item, {surf_item.bram_axi == 1; surf_item.s00_axi_awaddr == AXI_BASE + ROWS_REG_OFFSET; surf_item.s00_axi_wdata == rows;});
			`uvm_do_with(surf_item, {surf_item.bram_axi == 1; surf_item.s00_axi_awaddr == AXI_BASE + COLS_REG_OFFSET; surf_item.s00_axi_wdata == cols;});

        //********** LOADING AN IMAGE **********//
        $display("\nImage loading begins...\n");

        $display("\nPicture resolution is: %d", rows*cols);

        for(i = 0; i < rows*cols; i ++)
        begin
				start_item(seg_item);
				seg_item.bram_axi = 0;
				seg_item.img_ena = 1'b1;
				seg_item.img_addra = i*4;
            $display("Image adrress: %d",seg_item.img_addra);
				seg_item.img_douta = p_sequencer.cfg.img_input_data[i];
            $display("Loaded %d. pixel",i);
				finish_item(seg_item);
        end
			$display("\nImage loaded...\n");

        //********** LOADING CENTERS **********//
			$display("\nCenter loading begins...\n");

        for(j = 0; j < CLUSTER_CEN; j ++)
        begin
				start_item(seg_item);
				seg_item.bram_axi = 2;
				seg_item.img_enb = 1'b1;
				seg_item.img_addrb = j*4;
            $display("Image adrress: %d",seg_item.img_addrb);
				seg_item.img_doutb = p_sequencer.cfg.img_cent_data[j];
            $display("Loaded %d.pixel, bin: %b",j,p_sequencer.cfg.img_cent_data[j]);
				finish_item(seg_item);
        end
        $display("\nCenter loaded...\n");
		
        //  ***********************     START THE PROCESSING   ***********************//   
        $display("\nStarting the system... \n");
        `uvm_do_with(seg_item,{   surf_item.bram_axi == 1; surf_item.s00_axi_awaddr == AXI_BASE+CMD_REG_OFFSET; surf_item.s00_axi_wdata == 32'd1;});

    endtask : body

endclass : surf_simple_sequence
`endif