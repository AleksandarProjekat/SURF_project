`ifndef SURF_MONITOR_SV 
    `define SURF_MONITOR_SV

class surf_monitor extends uvm_monitor;

    bit checks_enable = 1;
    bit coverage_enable = 1;

    surf_config cfg;
    
    uvm_analysis_port #(surf_seq_item) item_collected_port;

    `uvm_component_utils_begin(surf_monitor)
        `uvm_field_int(checks_enable, UVM_DEFAULT)
        `uvm_field_int(coverage_enable, UVM_DEFAULT)
    `uvm_component_utils_end

    // Virtual interface
    virtual interface surf_interface s_vif;

    // Current transaction
    surf_seq_item curr_it;
    
    // PLACE FOR COVERAGE //////

covergroup surf_cover (int coverage_goal);
    option.per_instance = 1;
    option.goal = 8;
// Pokrivanje adresa u koracima od 4 za imgUPPERaddress
imgUPPERaddress : coverpoint s_vif.ip_addrd {
    bins b1 = {[0:28]};     
    bins b2 = {[32:60]};    
    bins b3 = {[64:92]};   
    bins b4 = {[96:124]};   
    bins b5 = {[128:156]};  
    bins b6 = {[160:188]};  
    bins b7 = {[192:220]}; 
    bins b8 = {[224:252]}; 
}

// Pokrivanje adresa u koracima od 4 za imgLOWERaddress
imgLOWERaddress : coverpoint s_vif.ip_addrc {
    bins b1 = {[0:28]};    
    bins b2 = {[32:60]};    
    bins b3 = {[64:92]};   
    bins b4 = {[96:124]};   
    bins b5 = {[128:156]};  
    bins b6 = {[160:188]};  
    bins b7 = {[192:220]};  
    bins b8 = {[224:252]};  
}

endgroup

    function new(string name = "surf_monitor", uvm_component parent = null);
        super.new(name,parent);
        item_collected_port = new("item_collected_port", this);

        if (!uvm_config_db#(virtual surf_interface)::get(this, "*", "surf_interface", s_vif))
            `uvm_fatal("NOVIF", {"Virtual interface must be set: ", get_full_name(), ".s_vif"});
            
        if (!uvm_config_db#(surf_config)::get(this, "", "surf_config", cfg))
            `uvm_fatal("NOCONFIG", {"Config object must be set: ", get_full_name(), ".cfg"});   
            
                    surf_cover = new(cfg.coverage_goal_cfg);      

    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

task main_phase(uvm_phase phase);
    @(posedge s_vif.clk);
    wait(s_vif.ip_enc == 1 || s_vif.ip_end == 1);

    forever begin
        @(posedge s_vif.clk); 
        curr_it = surf_seq_item::type_id::create("curr_it", this);
        //`uvm_info(get_type_name(), $sformatf("[Monitor] Prikupljam informacije..."), UVM_MEDIUM);
        
        // Kombinovana provera i prikupljanje podataka
        if (s_vif.ip_enc == 1) begin
            curr_it.ip_enc = s_vif.ip_enc;
            curr_it.ip_addrc = s_vif.ip_addrc/4;
            curr_it.ip_doutc = s_vif.ip_doutc;

            // Ispis podataka za ip_enc
 `uvm_info(get_type_name(), $sformatf("[Monitor] Poslati podaci za ip_enc:"), UVM_LOW);
            `uvm_info(get_type_name(), $sformatf("ip_addrc = %0d, ip_doutc = %0d", curr_it.ip_addrc, curr_it.ip_doutc), UVM_LOW);
            
                                                surf_cover.sample();

        end

        if (s_vif.ip_end == 1) begin
            curr_it.ip_end = s_vif.ip_end;
            curr_it.ip_addrd = s_vif.ip_addrd/4;
            curr_it.ip_doutd = s_vif.ip_doutd;

            // Ispis podataka za ip_end
            `uvm_info(get_type_name(), $sformatf("[Monitor] Poslati podaci za ip_end:"), UVM_LOW);
            `uvm_info(get_type_name(), $sformatf("ip_addrd = %0d, ip_doutd = %0d", curr_it.ip_addrd, curr_it.ip_doutd), UVM_LOW);
            
                                                surf_cover.sample();

        end

        // Samo zapisujemo transakciju ako su podaci validni
        if (s_vif.ip_enc == 1 || s_vif.ip_end == 1) begin
            // Ispisuje sta monitor salje na item_collected_port
            `uvm_info(get_type_name(), $sformatf("[Monitor] Poslata transakcija: ip_addrc = %0d, ip_doutc = %0d, ip_addrd = %0d, ip_doutd = %0d",
                curr_it.ip_addrc, curr_it.ip_doutc, curr_it.ip_addrd, curr_it.ip_doutd), UVM_LOW);
            item_collected_port.write(curr_it);
        end
    end
endtask


endclass : surf_monitor
`endif