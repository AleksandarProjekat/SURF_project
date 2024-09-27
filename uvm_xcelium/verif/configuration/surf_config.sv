parameter NUMBER_OF_PARAMETERS = 12;

class surf_config extends uvm_object;

    uvm_active_passive_enum is_active = UVM_ACTIVE;

    randc int rand_test_init;
    int rand_test_num;

    // Parametri, slika, izlaz
    string img_properties[NUMBER_OF_PARAMETERS];
    
    string index_upper_gv_file[NUMBER_OF_PARAMETERS];
    string index_lower_gv_file[NUMBER_OF_PARAMETERS];
    string img_upper_file[NUMBER_OF_PARAMETERS];
    string img_lower_file[NUMBER_OF_PARAMETERS];
    string index_upper_file[NUMBER_OF_PARAMETERS];
    string index_lower_file[NUMBER_OF_PARAMETERS];
    string num;

    int fracr_upper = 0;
    int fracr_lower = 0;
    int fracc_upper = 0;
    int fracc_lower = 0;
    int spacing_upper = 0;
    int spacing_lower = 0;
    int i_cose_upper = 0;
    int i_cose_lower = 0;
    int i_sine_upper = 0;
    int i_sine_lower = 0;
    int iradius = 0;
    int iy = 0;
    int ix = 0;
    int step = 0;
    int scale = 0;

    int fd = 0;
    int i = 0;
    int tmp;

    int index_upper_gv_arr[$];
    int index_lower_gv_arr[$];
    int coverage_goal_cfg;

    int img_upper_input_data[$];
    int img_lower_input_data[$];

    int index_upper_data[$];
    int index_lower_data[$];

    `uvm_object_utils_begin(surf_config)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
    `uvm_object_utils_end

constraint rand_constr { 
        rand_test_init > 0;
        rand_test_init < 12;
    } 
        
    function new(string name = "surf_config");
        super.new(name);

        img_properties[0] = "../files/\parameters_input.txt";
        index_upper_gv_file[0] = "../golden_vectors/\index_upper.txt";
        index_lower_gv_file[0] = "../golden_vectors//\index_lower.txt";
        img_upper_file[0] = "../files/\pixels1D_upper24_decimal.txt";
        img_lower_file[0] = "../files/\pixels1D_lower24_decimal.txt";
        index_upper_file[0] = "../files/\index_upper.txt";
        index_lower_file[0] = "../files/\index_lower.txt";

        // Loop initialization for all parameters
        for (int j = 1; j < NUMBER_OF_PARAMETERS; j++) begin
            num.itoa(j);
            img_properties[j] = $sformatf("../files/\parameters_input%0d.txt", j);
            index_upper_gv_file[j] = $sformatf("../golden_vectors/\index_upper_%0d.txt", j);
            index_lower_gv_file[j] = $sformatf("../golden_vectors/\index_lower_%0d.txt", j);
            img_upper_file[j] = $sformatf("../files/\pixels1D_upper24_decimal_%0d.txt", j);
            img_lower_file[j] = $sformatf("../files/\pixels1D_lower24_decimal_%0d.txt", j);
            index_upper_file[j] = $sformatf("../files/\index_upper_%0d.txt", j);
            index_lower_file[j] = $sformatf("../files/\index_lower_%0d.txt", j);
        end
    endfunction

    function void extracting_data();
    
      rand_test_num = (rand_test_init % NUMBER_OF_PARAMETERS);
      $display("rand_test_num : %0d", rand_test_num);
        
    //**************************          UCITAVANJE PARAMETARA SLIKE         **************************//

    fd = $fopen(img_properties[rand_test_num], "r");
    if (fd != 0) begin
        `uvm_info(get_name(), $sformatf("Successfully opened %s", img_properties[rand_test_num]), UVM_LOW);
        // Nastavak obrade fajla
        if ($fscanf(fd, "%d\n", fracr_upper) != 1) `uvm_info(get_name(), "Failed to read fracr_upper", UVM_ERROR);
        if ($fscanf(fd, "%d\n", fracr_lower) != 1) `uvm_info(get_name(), "Failed to read fracr_lower", UVM_ERROR);
        if ($fscanf(fd, "%d\n", fracc_upper) != 1) `uvm_info(get_name(), "Failed to read fracc_upper", UVM_ERROR);
        if ($fscanf(fd, "%d\n", fracc_lower) != 1) `uvm_info(get_name(), "Failed to read fracc_lower", UVM_ERROR);
        if ($fscanf(fd, "%d\n", spacing_upper) != 1) `uvm_info(get_name(), "Failed to read spacing_upper", UVM_ERROR);
        if ($fscanf(fd, "%d\n", spacing_lower) != 1) `uvm_info(get_name(), "Failed to read spacing_lower", UVM_ERROR);
        if ($fscanf(fd, "%d\n", i_cose_upper) != 1) `uvm_info(get_name(), "Failed to read i_cose_upper", UVM_ERROR);
        if ($fscanf(fd, "%d\n", i_cose_lower) != 1) `uvm_info(get_name(), "Failed to read i_cose_lower", UVM_ERROR);
        if ($fscanf(fd, "%d\n", i_sine_upper) != 1) `uvm_info(get_name(), "Failed to read i_sine_upper", UVM_ERROR);
        if ($fscanf(fd, "%d\n", i_sine_lower) != 1) `uvm_info(get_name(), "Failed to read i_sine_lower", UVM_ERROR);
        if ($fscanf(fd, "%d\n", iradius) != 1) `uvm_info(get_name(), "Failed to read iradius", UVM_ERROR);
        if ($fscanf(fd, "%d\n", iy) != 1) `uvm_info(get_name(), "Failed to read iy", UVM_ERROR);
        if ($fscanf(fd, "%d\n", ix) != 1) `uvm_info(get_name(), "Failed to read ix", UVM_ERROR);
        if ($fscanf(fd, "%d\n", step) != 1) `uvm_info(get_name(), "Failed to read step", UVM_ERROR);
        if ($fscanf(fd, "%d\n", scale) != 1) `uvm_info(get_name(), "Failed to read scale", UVM_ERROR);
    end else begin
        `uvm_info(get_name(), "Error opening input_parameters.txt", UVM_HIGH);
    end
    
    $fclose(fd);

	// ************************** FUNKCIJA ZA UCITAVANJE ZLATNIH VEKTORA ************************** //
	
    fd = $fopen(index_upper_gv_file[rand_test_num], "r");
    if (fd != 0) begin 
        `uvm_info(get_name(), "Successfully opened index_upper_gv file", UVM_LOW);
        while (!$feof(fd)) begin
            if ($fscanf(fd, "%d\n", tmp) == 1) index_upper_gv_arr.push_back(tmp);
        end
    end else begin
        `uvm_info(get_name(), $sformatf("Error opening index_upper_gv file: %s", index_upper_gv_file[rand_test_num]), UVM_LOW);
    end
    $fclose(fd);

    fd = $fopen(index_lower_gv_file[rand_test_num], "r");
    if (fd != 0) begin 
        `uvm_info(get_name(), "Successfully opened index_lower_gv file", UVM_LOW);
        while (!$feof(fd)) begin
            if ($fscanf(fd, "%d\n", tmp) == 1) index_lower_gv_arr.push_back(tmp);
        end
    end else begin
        `uvm_info(get_name(), $sformatf("Error opening index_lower_gv file: %s", index_lower_gv_file[rand_test_num]), UVM_LOW);
    end
    $fclose(fd);

	// ************************** READING FROM IMAGE FILES ************************** //

    img_upper_input_data.delete();
    fd = $fopen(img_upper_file[rand_test_num], "r");
    if (fd != 0) begin 
        `uvm_info(get_name(), $sformatf("Successfully opened img_upper_file %d", rand_test_num), UVM_LOW);
        while (!$feof(fd)) begin
            if ($fscanf(fd, "%d\n", tmp) == 1) img_upper_input_data.push_back(tmp);
        end
    end else begin
        `uvm_info(get_name(), "Error opening img_upper_file", UVM_HIGH);
    end
    $fclose(fd);

    img_lower_input_data.delete();
    fd = $fopen(img_lower_file[rand_test_num], "r");
    if (fd != 0) begin 
        `uvm_info(get_name(), $sformatf("Successfully opened img_lower_file %d", rand_test_num), UVM_LOW);
        while (!$feof(fd)) begin
            if ($fscanf(fd, "%d\n", tmp) == 1) img_lower_input_data.push_back(tmp);
        end
    end else begin
        `uvm_info(get_name(), "Error opening img_lower_file", UVM_HIGH);
    end
    $fclose(fd);

	// ************************** READING INDEX FILES ************************** //

    index_upper_data.delete();
    fd = $fopen(index_upper_file[rand_test_num], "r");
    if (fd != 0) begin 
        `uvm_info(get_name(), $sformatf("Successfully opened index_upper_file"), UVM_LOW);
        while (!$feof(fd)) begin
            if ($fscanf(fd, "%d\n", tmp) == 1) index_upper_data.push_back(tmp);
        end
    end else begin
        `uvm_info(get_name(), "Error opening index_upper_file", UVM_LOW);
    end
    $fclose(fd);

    index_lower_data.delete();
    fd = $fopen(index_lower_file[rand_test_num], "r");
    if (fd != 0) begin 
        `uvm_info(get_name(), $sformatf("Successfully opened index_lower_file"), UVM_LOW);
        while (!$feof(fd)) begin
            if ($fscanf(fd, "%d\n", tmp) == 1) index_lower_data.push_back(tmp);
        end
    end else begin
        `uvm_info(get_name(), "Error opening index_lower_file", UVM_LOW);
    end
    $fclose(fd);

    endfunction : extracting_data
endclass : surf_config

