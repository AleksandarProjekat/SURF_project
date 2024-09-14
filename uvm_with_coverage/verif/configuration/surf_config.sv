parameter NUMBER_OF_PARAMETERS = 48;

class surf_config extends uvm_object;

    uvm_active_passive_enum is_active = UVM_ACTIVE; // Decide if agents are ACTIVE (monitor, agent, sqr, driver) or PASSIVE (monitor only)

    randc int rand_test_init;
    int rand_test_num;

    string img32_file[NUMBER_OF_PARAMETERS];
    string img16_file[NUMBER_OF_PARAMETERS];
    string parameters_input[NUMBER_OF_PARAMETERS];
    string img32_gv_file[NUMBER_OF_PARAMETERS];
    string img16_gv_file[NUMBER_OF_PARAMETERS];
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
    int tmp;

    int img32_data[$];
    int img16_data[$];
    int img32_gv_data[$];
    int img16_gv_data[$];
    
    int coverage_goal_cfg;

    `uvm_object_utils_begin(surf_config)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
    `uvm_object_utils_end

    constraint rand_constr { 
        rand_test_init > 0;
        rand_test_init < NUMBER_OF_PARAMETERS; 
    } 

    function new(string name = "surf_config");
        super.new(name);
        
        // Initialization for the files and vectors
        img32_file[0] = "../../../../../files/pixels1D_upper32.txt";
        img16_file[0] = "../../../../../files/pixels1D_lower16.txt";
        parameters_input[0] = "../../../../../files/parameters_input.txt";
        img32_gv_file[0] = "../../../../../golden_vectors/index_upper32.txt";
        img16_gv_file[0] = "../../../../../golden_vectors/index_lower16.txt";

        // Loop initialization for all parameters
        for (int j = 1; j < NUMBER_OF_PARAMETERS; j++) begin
            num.itoa(j);
            img32_file[j] = {"../../../../../files/pixels1D_upper32_", num, ".txt"};
            img16_file[j] = {"../../../../../files/pixels1D_lower16_", num, ".txt"};
            parameters_input[j] = {"../../../../../files/parameters_input", num, ".txt"};
            img32_gv_file[j] = {"../../../../../golden vectors/index_upper_32_", num, ".txt"};
            img16_gv_file[j] = {"../../../../../golden vectors/index_lower_16_", num, ".txt"};
        end
    endfunction

    // Data extraction function similar to hough_config
    function void extracting_data();

        rand_test_num = (rand_test_init % NUMBER_OF_PARAMETERS);
        $display("rand_test_num : %d", rand_test_num);

        // Reading image parameters
        fd = $fopen(parameters_input[rand_test_num], "r");
        if (fd) begin
            `uvm_info(get_name(), $sformatf("Successfully opened parameters_input"), UVM_LOW)
            $fscanf(fd, "%d\n", fracr_upper);
            $fscanf(fd, "%d\n", fracr_lower);
            $fscanf(fd, "%d\n", fracc_upper);
            $fscanf(fd, "%d\n", fracc_lower);
            $fscanf(fd, "%d\n", spacing_upper);
            $fscanf(fd, "%d\n", spacing_lower);
            $fscanf(fd, "%d\n", i_cose_upper);
            $fscanf(fd, "%d\n", i_cose_lower);
            $fscanf(fd, "%d\n", i_sine_upper);
            $fscanf(fd, "%d\n", i_sine_lower);
            $fscanf(fd, "%d\n", iradius);
            $fscanf(fd, "%d\n", iy);
            $fscanf(fd, "%d\n", ix);
            $fscanf(fd, "%d\n", step);
            $fscanf(fd, "%d\n", scale);
        end else begin
            `uvm_info(get_name(), $sformatf("Error opening parameters_input file"), UVM_HIGH)
        end
        $fclose(fd);

        // Reading image - upper 32 bits
        img32_data.delete();
        fd = $fopen(img32_file[rand_test_num], "r");
        if (fd) begin
            `uvm_info(get_name(), $sformatf("Successfully opened img32_file"), UVM_LOW)
            while (!$feof(fd)) begin
                $fscanf(fd, "%f\n", tmp);
                img32_data.push_back(tmp);
            end
        end else begin
            `uvm_info(get_name(), $sformatf("Error opening img32_file"), UVM_HIGH)
        end
        $fclose(fd);

        // Reading image - lower 16 bits
        img16_data.delete();
        fd = $fopen(img16_file[rand_test_num], "r");
        if (fd) begin
            `uvm_info(get_name(), $sformatf("Successfully opened img16_file"), UVM_LOW)
            while (!$feof(fd)) begin
                $fscanf(fd, "%f\n", tmp);
                img16_data.push_back(tmp);
            end
        end else begin
            `uvm_info(get_name(), $sformatf("Error opening img16_file"), UVM_HIGH)
        end
        $fclose(fd);

        // Reading golden vectors - upper 32 bits
        img32_gv_data.delete();
        fd = $fopen(img32_gv_file[rand_test_num], "r");
        if (fd) begin
            `uvm_info(get_name(), $sformatf("Successfully opened index1D_upper32"), UVM_LOW)
            while (!$feof(fd)) begin
                $fscanf(fd, "%f\n", tmp);
                img32_gv_data.push_back(tmp);
            end
        end else begin
            `uvm_info(get_name(), $sformatf("Error opening index1D_upper32"), UVM_HIGH)
        end
        $fclose(fd);

        // Reading golden vectors - lower 16 bits
        img16_gv_data.delete();
        fd = $fopen(img16_gv_file[rand_test_num], "r");
        if (fd) begin
            `uvm_info(get_name(), $sformatf("Successfully opened index1D_lower16"), UVM_LOW)
            while (!$feof(fd)) begin
                $fscanf(fd, "%f\n", tmp);
                img16_gv_data.push_back(tmp);
            end
        end else begin
            `uvm_info(get_name(), $sformatf("Error opening index1D_lower16"), UVM_HIGH)
        end
        $fclose(fd);
    endfunction
endclass : surf_config
