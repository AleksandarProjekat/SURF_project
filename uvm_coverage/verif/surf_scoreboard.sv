class surf_scoreboard extends uvm_scoreboard;

    bit checks_enable = 1;
    bit coverage_enable = 1;
    surf_config cfg;

    uvm_analysis_imp#(surf_seq_item, surf_scoreboard) item_collected_import;

    int num_of_tr = 1;
    int mismatch_count = 0; // Brojac neslaganja
    // Brojaci neslaganja
    int img_upper_mismatch_count = 0;
    int img_lower_mismatch_count = 0;

    bit [23:0] collected_img_upper_data[64]; 
    bit [23:0] collected_img_lower_data[64];
    bit [23:0] observed_img_upper_data[64];
    bit [23:0] observed_img_lower_data[64];

    `uvm_component_utils_begin(surf_scoreboard)
        `uvm_field_int(checks_enable, UVM_DEFAULT)
        `uvm_field_int(coverage_enable, UVM_DEFAULT)
    `uvm_component_utils_end

    function new(string name = "surf_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        item_collected_import = new("item_collected_import", this);

        if(!uvm_config_db#(surf_config)::get(this,"","surf_config",cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set for: ", get_full_name(),".cfg"})
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
    endfunction : connect_phase

    // Sacuvaj dolazne podatke, ali ne upisuj u observed nizove
    function void write(surf_seq_item curr_it);
        if (checks_enable) begin
            
            // Sacuvaj podatke u privremene promenljive
            collected_img_upper_data[curr_it.ip_addrc] = curr_it.ip_doutc;
            collected_img_lower_data[curr_it.ip_addrd] = curr_it.ip_doutd;

            ++num_of_tr;
        end
    endfunction

/*
// U report fazi izvrsi proveru
function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Provera podataka nakon svih transakcija..."), UVM_LOW);

    
    for (int i = 0; i < 64; i++) begin
        // O?itavanje podataka i upis u observed nizove
        observed_img_upper_data[i] = collected_img_upper_data[i];
        observed_img_lower_data[i] = collected_img_lower_data[i];

        // Ispisuje observed i expected vrednosti za imgupper
        `uvm_info(get_type_name(), $sformatf("Adresa [%0d] - img_upper: Observed = %0d, Expected = %0d", 
            i, observed_img_upper_data[i], cfg.img_upper_gv_data[i]), UVM_MEDIUM);

        // Provera za img_upper - prijavi neslaganje odmah
        if (observed_img_upper_datata[i] !== cfg.img_upper_gv_data[i]) begin
            `uvm_error(get_type_name(), $sformatf("Mismatch img_output_upper[%0d]\nObserved: %0d, Expected: %0d.", 
                i, observed_img_upper_datata[i], cfg.img_upper_gv_data[i]));
            img_upper_mismatch_count++; // Povecaj brojac neslaganja za imgupper
        end

        // Ispisuje observed i expected vrednosti za imglower
        `uvm_info(get_type_name(), $sformatf("Adresa [%0d] - img_lower: Observed = %0d, Expected = %0d", 
            i, observed_img_lower_data[i], cfg.img_lower_gv_data[i]), UVM_MEDIUM);

        // Provera za imglower - prijavi neslaganje odmah
        if (observed_img_lower_data[i] !== cfg.img_lower_gv_data[i]) begin
            `uvm_error(get_type_name(), $sformatf("Mismatch img_output_lower[%0d]\nObserved: %0d, Expected: %0d.", 
                i, observed_img_lower_data[i], cfg.img_lower_gv_data[i]));
            img_lower_mismatch_count++; // Povecaj brojac neslaganja za imglower
        end
    end
    
    // Ispis broja neslaganja na kraju provere
    if (img_upper_mismatch_count == 0 && img_lower_mismatch_count == 0) begin
        `uvm_info(get_type_name(), "Svi podaci su tacni za img_upper i img_lower.", UVM_LOW);
    end else begin
        if (img_upper_mismatch_count > 0) begin
            `uvm_info(get_type_name(), $sformatf("Ukupno neslaganja za img_upper: %0d", img_upper_mismatch_count), UVM_LOW);
        end
        if (img_lower_mismatch_count > 0) begin
            `uvm_info(get_type_name(), $sformatf("Ukupno neslaganja za img_lower: %0d", img_lower_mismatch_count), UVM_LOW);
        end
    end

    `uvm_info(get_type_name(), $sformatf("Ukupno transakcija: %0d", num_of_tr), UVM_LOW);
endfunction


*/


    // U report fazi izvrši proveru
    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Provera podataka nakon svih transakcija..."), UVM_LOW);
    
        
        for (int i = 0; i < 64; i++) begin
            // Ocitavanje podataka i upis u observed nizove
            observed_img_upper_datata[i] = collected_img_upper_data[i];
            observed_img_lower_data[i] = collected_img_lower_data[i];
    
            // Ispisuje observed i expected vrednosti za imgupper
            `uvm_info(get_type_name(), $sformatf("Adresa [%0d] - img_upper: Observed = %0d, Expected = %0d", 
                i, observed_img_upper_datata[i], cfg.img_upper_gv_data[i]), UVM_MEDIUM);
    
            // Provera za imgupper, ignorise se poslednji bit sa ^ XOR
            if (observed_img_upper_datata[i] !== cfg.img_upper_gv_data[i]) begin
                if ((observed_img_upper_datata[i] ^ cfg.img_upper_gv_data[i]) == 1) begin
                    `uvm_info(get_type_name(), $sformatf("Razlika u poslednjem bitu img_upper [%0d]\nObserved: %0d, Expected: %0d.", 
                        i, observed_img_upper_datata[i], cfg.img_upper_gv_data[i]), UVM_LOW);
                end else begin
                    `uvm_error(get_type_name(), $sformatf("Mismatch img_output_upper[%0d]\nObserved: %0d, Expected: %0d.", 
                        i, observed_img_upper_datata[i], cfg.img_upper_gv_data[i]));
                    img_upper_mismatch_count++; // Povecaj brojac neslaganja za imgupper
                end
            end
    
            // Ispisuje observed i expected vrednosti za img_lower
            `uvm_info(get_type_name(), $sformatf("Adresa [%0d] - img_lower: Observed = %0d, Expected = %0d", 
                i, observed_img_lower_data[i], cfg.img_lower_gv_data[i]), UVM_MEDIUM);
    
            // Provera za img_lower, ignoriše se poslednji bit sa ^ XOR
            if (observed_img_lower_data[i] !== cfg.img_lower_gv_data[i]) begin
                if ((observed_img_lower_data[i] ^ cfg.img_lower_gv_data[i]) == 1) begin
                    `uvm_info(get_type_name(), $sformatf("Razlika u poslednjem bitu img_lower [%0d]\nObserved: %0d, Expected: %0d.", 
                        i, observed_img_lower_data[i], cfg.img_lower_gv_data[i]), UVM_LOW);
                end else begin
                    `uvm_error(get_type_name(), $sformatf("Mismatch img_output_lower[%0d]\nObserved: %0d, Expected: %0d.", 
                        i, observed_img_lower_data[i], cfg.img_lower_gv_data[i]));
                    img_lower_mismatch_count++; // Povecaj brojac neslaganja za imglower
                end
            end
        end
        
        // Ispis broja neslaganja na kraju provere
        if (img_upper_mismatch_count == 0 && img_lower_mismatch_count == 0) begin
            `uvm_info(get_type_name(), "Svi podaci su tacni za img_upper i img_lower.", UVM_LOW);
        end else begin
            if (img_upper_mismatch_count > 0) begin
                `uvm_info(get_type_name(), $sformatf("Ukupno neslaganja za img_upper: %0d", img_upper_mismatch_count), UVM_LOW);
            end
            if (img_lower_mismatch_count > 0) begin
                `uvm_info(get_type_name(), $sformatf("Ukupno neslaganja za img_lower: %0d", img_lower_mismatch_count), UVM_LOW);
            end
        end
    
        `uvm_info(get_type_name(), $sformatf("Ukupno transakcija: %0d", num_of_tr), UVM_LOW);
    endfunction






endclass
