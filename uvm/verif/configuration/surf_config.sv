class surf_config extends uvm_object;

    uvm_active_passive_enum is_active = UVM_ACTIVE; // Decide if agents are ACTIVE (monitor, agent, sqr, driver) or PASSIVE (monitor only)

    // Slika, izlaz
    string img32_input;
    string img16_input;

    string img32_gv;
    string img16_gv;

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
    string line_img32;
    string line_img16;
    string line_gv32;
    string line_gv16;
    
    logic[31:0] img32_input_data[$];
    logic[15:0] img16_input_data[$];

    logic[31:0] img32_gv_data[$]; 
    logic[15:0] img16_gv_data[$]; 


    `uvm_object_utils_begin(surf_config)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "surf_config");
        super.new(name);

        img32_input = "../../../../../files\/pixels1D_upper32.txt";
        img16_input = "../../../../../files\/pixels1D_lower16.txt";

        img32_gv = "../../../../../files\/index1D_upper32.txt";
        img16_gv = "../../../../../files\/index1D_lower16.txt";

    endfunction

    function void extracting_data();

    //********** UCITAVANJE SLIKE PRVIH 32 BITA **********//
	
		img32_input_data.delete();
		fd = $fopen(img32_input, "r");
    if(fd) begin
        
        `uvm_info(get_name(), $sformatf("Successfully opened pixels1D_upper32.txt"), UVM_LOW)
        while(!$feof(fd))
        begin
            $fgets(line_img32, fd);
            img32_input_data.push_back(line_img32.atobin());
            // Prikazivanje elemenata niza za svaku iteraciju
            $display("Element img32_input_data[%0d] = %b",i,  img32_input_data[i]);
            i++;    
        end
    end
    else begin
        `uvm_info(get_name(), $sformatf("Error opening pixels1D_upper32.txt"), UVM_HIGH)
    end
    $fclose(fd);

   
       //********** UCITAVANJE SLIKE DRUGIH 16 BITA **********//
	
		img16_input_data.delete();
		fd = $fopen(img16_input, "r");
    if(fd) begin
        
        `uvm_info(get_name(), $sformatf("Successfully opened pixels1D_lower16.txt"), UVM_LOW)
        while(!$feof(fd))
        begin
            $fgets(line_img16, fd);
            img16_input_data.push_back(line_img16.atobin());
            // Prikazivanje elemenata niza za svaku iteraciju
            $display("Element img16_input_data[%0d] = %b",j,  img16_input_data[j]);
            j++;    
        end
    end
    else begin
        `uvm_info(get_name(), $sformatf("Error opening pixels1D_lower16.txt"), UVM_HIGH)
    end
    $fclose(fd);

    //********** UCITAVANJE ZLATNOG VEKTORA ZA PRVIH 32 BITA **********//

		img32_gv_data.delete();
		fd = $fopen(img32_gv, "r");
    if(fd) begin
        
        `uvm_info(get_name(), $sformatf("Successfully opened index1D_upper32.txt"), UVM_LOW)
        while(!$feof(fd))
        begin
            $fgets(line_gv32, fd);
            img32_gv_data.push_back(line_gv32.atobin());
        end
    end
    else begin
        `uvm_info(get_name(), $sformatf("Error opening index1D_upper32.txt"), UVM_HIGH)
    end
    $fclose(fd);

    //********** UCITAVANJE ZLATNOG VEKTORA ZA DRUGIH 16 BITA **********//

		img16_gv_data.delete();
		fd = $fopen(img16_gv, "r");
    if(fd) begin
        
        `uvm_info(get_name(), $sformatf("Successfully opened index1D_lower16.txt"), UVM_LOW)
        while(!$feof(fd))
        begin
            $fgets(line_gv16, fd);
            img16_gv_data.push_back(line_gv16.atobin());
        end
    end
    else begin
        `uvm_info(get_name(), $sformatf("Error opening index1D_lower16.txt"), UVM_HIGH)
    end
    $fclose(fd);
    endfunction : extracting_data
endclass : surf_config

        
