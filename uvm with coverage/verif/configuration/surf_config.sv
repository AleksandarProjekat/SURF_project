parameter NUMBER_OF_PARAMETERS = 49;

class surf_config extends uvm_object;

    uvm_active_passive_enum is_active = UVM_ACTIVE; // Decide if agents are ACTIVE (monitor, agent, sqr, driver) or PASSIVE (monitor only)

	randc int rand_test_init;
    int rand_test_num;

    // Slika, izlaz
    string img32_input[NUMBER_OF_PARAMETERS];
    string img16_input[NUMBER_OF_PARAMETERS];

    string img32_gv[NUMBER_OF_PARAMETERS];
    string img16_gv[NUMBER_OF_PARAMETERS];

    // Parametri ulazne slike                       
    int fracr_upper[$];
	int fracr_lower[$];
	int fracc_upper[$];
    int fracc_lower[$];
	int spacing_upper[$];
    int	spacing_lower[$];
	int i_cose_upper[$]; 
	int i_cose_lower[$];
	int i_sine_upper[$];
    int	i_sine_lower[$];
	int iradius[$];
	int iy[$];
	int ix[$];
	int step[$];
	int scale[$];  
	
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
    

    `uvm_object_utils_begin(surf_config)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
    `uvm_object_utils_end

constraint rand_constr { 
        rand_test_init>0;
        rand_test_init<49;} 

    function new(string name = "surf_config");
        super.new(name);

        img32_input[0] = "../../../../../files\/pixels1D_upper32.txt";
        img16_input[0] = "../../../../../files\/pixels1D_lower16.txt";

        img32_gv[0] = "../../../../../files\/index1D_upper32.txt";
        img16_gv[0] = "../../../../../files\/index1D_lower16.txt";


        for(int j = 0; j < NUMBER_OF_PARAMETERS;j++)
		 begin
            num.itoa(j);
			
        img32_input[j] = "../../../../../files\/pixels1D_upper32_",num,".txt";
        img16_input[j] = "../../../../../files\/pixels1D_lower16_",num,".txt";

		parameters_input[j]= "../../../../../files\/parameters_input_",num,".txt";
		
        img32_gv[j] = "../../../../../golden_vectors\/index1D_upper32_",num,"txt";
        img16_gv[j] = "../../../../../golden_vectors\/index1D_lower16_",num,".txt";
		
		end
    endfunction

    function void extracting_data();

		rand_test_num = (rand_test_init%NUMBER_OF_PARAMETERS);
        $display("rand_test_num : %d", rand_test_num);

 //**************************          UCITAVANJE PARAMETARA SLIKE         **************************//
        
        fd = $fopen(parameters_input[rand_test_num],"r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully opened parameters_input"),UVM_LOW)

            $fscanf(fd, "%d\n", fracr_upper);
            $display("fracr_upper: %d", fracr_upper);
            $fscanf(fd, "%d\n", fracr_lower);
            $display("fracr_lower: %d", fracr_lower);
            $fscanf(fd, "%d\n", fracc_upper);
            $display("fracc_upper: %d", fracc_upper);  
			$fscanf(fd, "%d\n", fracc_lower);
            $display("fracc_lower: %d", fracc_lower);
            $fscanf(fd, "%d\n", spacing_upper);
            $display("spacing_upper: %d", spacing_upper);
            $fscanf(fd, "%d\n", spacing_lower);
            $display("spacing_lower: %d", spacing_lower);
			 $fscanf(fd, "%d\n", i_cose_upper);
            $display("i_cose_upper: %d", i_cose_upper);
            $fscanf(fd, "%d\n", i_cose_lower);
            $display("i_cose_lower: %d", i_cose_lower);
            $fscanf(fd, "%d\n", i_sine_upper);
            $display("i_sine_upper: %d", i_sine_upper);  
			$fscanf(fd, "%d\n", i_sine_lower);
            $display("i_sine_lower: %d", i_sine_lower);
            $fscanf(fd, "%d\n", iradius);
            $display("iradius: %d", iradius);
            $fscanf(fd, "%d\n", iy);
            $display("iy: %d", iy);
			$fscanf(fd, "%d\n", ix);
            $display("ix: %d", ix);
            $fscanf(fd, "%d\n", step);
            $display("step: %d", step);
            $fscanf(fd, "%d\n", scale);
            $display("scale: %d", scale);
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening slika.txt"),UVM_HIGH)    
        end
        $fclose(fd);
		
    //********** UCITAVANJE SLIKE PRVIH 32 BITA **********//
	
		img32_input.delete();
		fd = $fopen(img32_input[rand_test_num], "r");
    if(fd) begin
        
        `uvm_info(get_name(), $sformatf("Successfully opened img32_input %d", rand_test_num), UVM_LOW)
        while(!$feof(fd))
        begin
            $fscanf(fd ,"%f\n",tmp);
            img32_input.push_back(tmp);
        end
    end
    else begin
        `uvm_info(get_name(), $sformatf("Error opening img32_input.txt"), UVM_HIGH)
    end
    $fclose(fd);

   
       //********** UCITAVANJE SLIKE DRUGIH 16 BITA **********//
	
		img16_input.delete();
		fd = $fopen(img16_input[rand_test_num], "r");
    if(fd) begin      
        `uvm_info(get_name(), $sformatf("Successfully opened img16_input %d", rand_test_num), UVM_LOW)
        while(!$feof(fd))
        begin
             $fscanf(fd ,"%f\n",tmp);
            img16_input.push_back(tmp); 
        end
    end
    else begin
        `uvm_info(get_name(), $sformatf("Error opening img16_input.txt"), UVM_HIGH)
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

        
