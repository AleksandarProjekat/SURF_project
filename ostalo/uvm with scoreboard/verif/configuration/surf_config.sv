class surf_config extends uvm_object;

    uvm_active_passive_enum is_active = UVM_ACTIVE; // Decide if agents are ACTIVE (monitor, agent, sqr, driver) or PASSIVE (monitor only)

    // Slika, izlaz
    string img_upper24_input;
    string img_lower24_input;

    string img_upper_gv;
    string img_lower_gv;

    // Parametri ulazne slike                       
    int fracr_upper;
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
	int scale;  
	
    int i = 0;
    int j = 0;

    int fd;
    int tmp;
    int img_doutc_gv[$]; 
    int img_doutd_gv[$]; 

    int coverage_goal_cfg;
    string line_img_upper;
    string line_img_lower;
    string line_upper_gv;
    string line_lower_gv;
    
    logic[23:0] img_upper_input_data[$];
    logic[23:0] img_lower_input_data[$];

    logic[23:0] img_upper_gv_data[$]; 
    logic[23:0] img_lower_gv_data[$]; 


    `uvm_object_utils_begin(surf_config)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "surf_config");
        super.new(name);

        img_upper24_input = "../../../../../files\/pixels1D_upper24.txt";
        img_lower24_input = "../../../../../files\/pixels1D_lower24.txt";

        img_upper_gv = "../../../../../files\/index_upper_24.txt";
        img_lower_gv = "../../../../../files\/index_lower_24.txt";

    endfunction

    function void extracting_data();

    //********** UCITAVANJE SLIKE PRVIH 24 BITA **********//
	
		img_upper_input_data.delete();
		fd = $fopen(img_upper24_input, "r");
    if(fd) begin
        
        `uvm_info(get_name(), $sformatf("Successfully opened pixels1D_upper24.txt"), UVM_LOW)
        while(!$feof(fd))
        begin
            $fgets(line_img_upper, fd);
            img_upper_input_data.push_back(line_img_upper.atobin());
            // Prikazivanje elemenata niza za svaku iteraciju
            $display("Element img_upper_input_data[%0d] = %b",i,  img_upper_input_data[i]);
            i++;    
        end
    end
    else begin
        `uvm_info(get_name(), $sformatf("Error opening pixels1D_upper24.txt"), UVM_HIGH)
    end
    $fclose(fd);

   
       //********** UCITAVANJE SLIKE DRUGIH 24 BITA **********//
	
		img_lower_input_data.delete();
		fd = $fopen(img_lower24_input, "r");
    if(fd) begin
        
        `uvm_info(get_name(), $sformatf("Successfully opened pixels1D_lower24.txt"), UVM_LOW)
        while(!$feof(fd))
        begin
            $fgets(line_img_lower, fd);
            img_lower_input_data.push_back(line_img_lower.atobin());
            // Prikazivanje elemenata niza za svaku iteraciju
            $display("Element img_lower_input_data[%0d] = %b",j,  img_lower_input_data[j]);
            j++;    
        end
    end
    else begin
        `uvm_info(get_name(), $sformatf("Error opening pixels1D_lower24.txt"), UVM_HIGH)
    end
    $fclose(fd);

    //********** UCITAVANJE ZLATNOG VEKTORA ZA PRVIH 24 BITA **********//

		img_upper_gv_data.delete();
		fd = $fopen(img_upper_gv, "r");
    if(fd) begin
        
        `uvm_info(get_name(), $sformatf("Successfully opened index_upper24.txt"), UVM_LOW)
        while(!$feof(fd))
        begin
            $fgets(line_upper_gv, fd);
            img_upper_gv_data.push_back(line_upper_gv.atobin());
        end
    end
    else begin
        `uvm_info(get_name(), $sformatf("Error opening index_upper24.txt"), UVM_HIGH)
    end
    $fclose(fd);

    //********** UCITAVANJE ZLATNOG VEKTORA ZA DRUGIH 24 BITA **********//

		img_lower_gv_data.delete();
		fd = $fopen(img_lower_gv, "r");
    if(fd) begin
        
        `uvm_info(get_name(), $sformatf("Successfully opened index_lower24.txt"), UVM_LOW)
        while(!$feof(fd))
        begin
            $fgets(line_lower_gv, fd);
            img_lower_gv_data.push_back(line_lower_gv.atobin());
        end
    end
    else begin
        `uvm_info(get_name(), $sformatf("Error opening index_lower24.txt"), UVM_HIGH)
    end
    $fclose(fd);
    endfunction : extracting_data
endclass : surf_config

        
