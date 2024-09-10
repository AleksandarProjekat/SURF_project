class surf_config extends uvm_object;

    uvm_active_passive_enum is_active = UVM_ACTIVE; // Decide if agents are ACTIVE (monitor, agent, sqr, driver) or PASSIVE (monitor only)

    // Slika, izlaz
    string img_input;
    string img_gv;

    // Parametri ulazne slike                        ///NA KOJE VREDNOSTI INICIJALIZOVATI 
    /* int fracr_upper;
	int fracr_lower;
	int fracc_upper;
    int fracc_lower;
	int spacing_upper;
    int	spacing_lower;
	int i_cose_upper; 
	int i_cose_lower;
	int i_sine_upper;
    int	i_sine_lower;
	int iradius;
	int iy;
	int ix;
	int step;
	int scale;  */
	
    int i = 0;
    int fd;
    int tmp;
    int img_doutc_gv[$]; 
    int coverage_goal_cfg;
    string line_img;
    string line_gv;

    logic[47:0] img_input_data[$];
    logic[47:0] img_gv_data[$]; 

    `uvm_object_utils_begin(surf_config)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "surf_config");
        super.new(name);

        img_input = "../../../../../files\/pixels1D.txt";
        img_gv = "../../../../../files\/index1Dbin.txt";

    endfunction

    function void extracting_data();

    //********** UCITAVANJE SLIKE **********//
	
		img_input_data.delete();
		fd = $fopen(img_input, "r");
    if(fd) begin
        
        `uvm_info(get_name(), $sformatf("Successfully opened pixels1D.txt"), UVM_LOW)
        while(!$feof(fd))
        begin
            $fgets(line_img, fd);
            img_input_data.push_back(line_img.atobin());
            // Prikazivanje elemenata niza za svaku iteraciju
            $display("Element img_input_data[%0d] = %b",i,  img_input_data[i]);
            i++;    
        end
    end
    else begin
        `uvm_info(get_name(), $sformatf("Error opening pixels1D.txt"), UVM_HIGH)
    end
    $fclose(fd);

   

    //********** UCITAVANJE ZLATNOG VEKTORA **********//

		img_gv_data.delete();
		fd = $fopen(img_gv, "r");
    if(fd) begin
        
        `uvm_info(get_name(), $sformatf("Successfully opened index1Dbin.txt"), UVM_LOW)
        while(!$feof(fd))
        begin
            $fgets(line_gv, fd);
            img_gv_data.push_back(line_gv.atobin());
        end
    end
    else begin
        `uvm_info(get_name(), $sformatf("Error opening index1Dbin.txt"), UVM_HIGH)
    end
    $fclose(fd);

    endfunction : extracting_data
endclass : surf_config

        
