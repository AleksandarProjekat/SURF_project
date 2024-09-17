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

covergroup img_data_cover();
		option.per_instance = 2;

        index_upper_pix_value : coverpoint surf_item.img_doutc {    
            bins low_value = {0};   
            bins high_value = {16777215};  
        }
    
		indedex_lower_pix_value : coverpoint surf_item.img_doutd {
            bins very_low    = {[0:4194303]};          // 0 to 25% of the full range
            bins low_value   = {[4194304:8388607]};    // 25% to 50% of the full range
            bins mid_value   = {[8388608:12582911]};   // 50% to 75% of the full range
            bins high_value  = {[12582912:16777215]};  // 75% to 100% of the full range
        }

    endgroup
    
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
		
        // Slanje gornjih 24 bita (FRACR_UPPER_C)
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + FRACR_UPPER_REG_OFFSET;
            surf_item.s00_axi_wdata == fracr_upper;
            surf_item.s00_axi_wstrb == 4'b0111;
        });

        // Slanje donjih 24 bita (FRACR_LOWER_C)
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + FRACR_LOWER_REG_OFFSET;
            surf_item.s00_axi_wdata == fracr_lower;
            surf_item.s00_axi_wstrb == 4'b0111;
        });

        // Slanje gornjih 24 bita (FRACC_UPPER_C)
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + FRACC_UPPER_REG_OFFSET;
            surf_item.s00_axi_wdata == fracc_upper;
            surf_item.s00_axi_wstrb == 4'b0111;
        });

        // Slanje donjih 24 bita (FRACC_LOWER_C)
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + FRACC_LOWER_REG_OFFSET;
            surf_item.s00_axi_wdata == fracc_lower;  
            surf_item.s00_axi_wstrb == 4'b0111;
        });

        // Slanje gornjih 24 bita (SPACING_UPPER_C)
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + SPACING_UPPER_REG_OFFSET;
            surf_item.s00_axi_wdata == spacing_upper;
            surf_item.s00_axi_wstrb == 4'b0111;
        });

        // Slanje donjih 24 bita (SPACING_LOWER_C)
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + SPACING_LOWER_REG_OFFSET;
            surf_item.s00_axi_wdata == spacing_lower;  
            surf_item.s00_axi_wstrb == 4'b0111;
        });

        // Slanje gornjih 24 bita (I_COSE_UPPER_C)
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + I_COSE_UPPER_REG_OFFSET;
            surf_item.s00_axi_wdata == i_cose_upper;  
            surf_item.s00_axi_wstrb == 4'b0111;
        });

        // Slanje donjih 24 bita (I_COSE_LOWER_C)
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + I_COSE_LOWER_REG_OFFSET;
            surf_item.s00_axi_wdata == i_cose_lower;  
            surf_item.s00_axi_wstrb == 4'b0111;
        });

        // Slanje gornjih 24 bita (I_SINE_UPPER_C)
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + I_SINE_UPPER_REG_OFFSET;
            surf_item.s00_axi_wdata == i_sine_upper;  
            surf_item.s00_axi_wstrb == 4'b0111;
        });

        // Slanje donjih 24 bita (I_SINE_LOWER_C)
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + I_SINE_LOWER_REG_OFFSET;
            surf_item.s00_axi_wdata == i_sine_lower;  
            surf_item.s00_axi_wstrb == 4'b0111;
        });

        // Slanje vrednosti za IRADIUS
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + IRADIUS_REG_OFFSET;
            surf_item.s00_axi_wdata == iradius;  
            surf_item.s00_axi_wstrb == 4'b1111;
        });

        // Slanje vrednosti za IY
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + IY_REG_OFFSET;
            surf_item.s00_axi_wdata == iy;  
            surf_item.s00_axi_wstrb == 4'b1111;
        });

        // Slanje vrednosti za IX
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + IX_REG_OFFSET;
            surf_item.s00_axi_wdata == ix;  
            surf_item.s00_axi_wstrb == 4'b1111;
        });

        // Slanje vrednosti za STEP
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + STEP_REG_OFFSET;
            surf_item.s00_axi_wdata == step; 
            surf_item.s00_axi_wstrb == 4'b1111;
        });
		
		 // Slanje vrednosti za SCALE
        `uvm_do_with(surf_item, {
            surf_item.bram_axi == 1;
            surf_item.s00_axi_awaddr == AXI_BASE + SCALE_REG_OFFSET;
            surf_item.s00_axi_wdata == scale; 
            surf_item.s00_axi_wstrb == 4'b1111;
        });
        
//  ***********************     PRELOADING ZEROS IN INDEX32 AND INDEX16   ***********************//
//        `uvm_info(get_name(), $sformatf("UBACIVANJE NULA U INDEX32 I INDEX16"),   UVM_HIGH)
//        $display("\Index loading begins...\n");

//        for ( i = 0 ; i < 63 ; i ++)
//        begin
//            start_item(surf_item);
//                surf_item.bram_axi = 0;
//                surf_item.ip_enc = 1;
//                surf_item.ip_addrc = i*4;
//                surf_item.ip_doutc = p_sequencer.cfg.index32_data[i];

//                surf_item.ip_end = 1;
//                surf_item.ip_addrd = i*4;
//                surf_item.ip_doutd = p_sequencer.cfg.index16_data[i];
                
//            finish_item(surf_item);
//        end

//        $display("\Index preloaded!\n");

        //********** LOADING AN IMAGE 32 **********//
        $display("\nImage 24 and 24 loading begins...\n");

        $display("\nPicture 24 and 24 resolution is: %d", 129*129);

        for(i = 0; i < 129*129; i ++)
        begin
			start_item(surf_item);
				surf_item.bram_axi = 0;	
							
				surf_item.img_ena = 1'b1;
				surf_item.img_addra = i*4;
				surf_item.img_douta = p_sequencer.cfg.img_upper_input_data[i];

       			surf_item.img_enb = 1'b1;
				surf_item.img_addrb = i*4;
				surf_item.img_doutb = p_sequencer.cfg.img_lower_input_data[i];
                img_data_cover.sample();

				finish_item(surf_item);
     end 
			$display("\nImage 24 and 24 loaded...\n");

		
        //  ***********************     START THE PROCESSING   ***********************//   
        $display("\nStarting the system... \n");
        `uvm_do_with(surf_item,{   surf_item.bram_axi == 1; surf_item.s00_axi_awaddr == AXI_BASE+CMD_REG_OFFSET; surf_item.s00_axi_wdata == 32'd1;});
        
// ************************ READING INDEX VALUES AFTER PROCESSING  ***********************//

//        $display("Initiate reading from index");
//        for ( j = 0 ; j < 64 ; j ++)
//        begin
//           start_item(surf_item);
//               surf_item.bram_axi = 0;
        
//               surf_item.ip_enc = 1'd0;
//               surf_item.ip_addrc = j*4;
//               surf_item.ip_doutc = 24'd0;

//               surf_item.ip_end = 1'd0;
//               surf_item.ip_addrd = j*4;
//               surf_item.ip_doutc = 24'd0;  
//           finish_item(surf_item);
//        end

        $display("\n All done!\n");


    endtask : body

endclass : surf_simple_sequence
`endif