library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SURF_v1_0 is
	generic (
		-- Users to add parameters here
        WIDTH : integer := 11;            -- Bit width for various unsigned signals
        PIXEL_SIZE : integer := 17;       -- 129 x 129 pixels
        INDEX_ADDRESS_SIZE : integer := 8;
        FIXED_SIZE : integer := 48;       -- Bit width for fixed-point operations
        INDEX_SIZE : integer := 4;        -- Dimension size for the index array
        BRAM_24_DATA : integer := 24;
        IMG_WIDTH : integer := 129;       -- Width of the image
        IMG_HEIGHT : integer := 129;       -- Height of the image
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 7
	);
	port (
		-- Users to add ports here
		
		---------------MEM INTERFEJS ZA SLIKU32--------------------
		clka       : out std_logic;
		reseta     : out std_logic;
		ena        : out std_logic;
		addra      : out std_logic_vector (PIXEL_SIZE - 1 downto 0);
		dina    : out std_logic_vector (BRAM_24_DATA - 1 downto 0);
		douta : in std_logic_vector (BRAM_24_DATA - 1 downto 0);
		wea        : out std_logic;
		---------------MEM INTERFEJS ZA SLIKU16--------------------
		clkb       : out std_logic;
		resetb     : out std_logic;
		enb        : out std_logic;
		addrb      : out std_logic_vector (PIXEL_SIZE - 1 downto 0);
		dinb    : out std_logic_vector (BRAM_24_DATA - 1 downto 0);
		doutb : in std_logic_vector (BRAM_24_DATA - 1 downto 0);
		web        : out std_logic;
        ---------------MEM INTERFEJS ZA IZLAZ32--------------------
        clkc       : out std_logic;
		resetc     : out std_logic;
		enc        : out std_logic;
		addrc      : out std_logic_vector (INDEX_ADDRESS_SIZE-1 downto 0);
		dinc    : out std_logic_vector (BRAM_24_DATA - 1 downto 0);
		doutc : in std_logic_vector (BRAM_24_DATA - 1 downto 0);
		wec        : out std_logic; 
		---------------MEM INTERFEJS ZA IZLAZ16--------------------
        clkd       : out std_logic;
		resetd     : out std_logic;
		en_d        : out std_logic;
		addrd      : out std_logic_vector (INDEX_ADDRESS_SIZE-1 downto 0);
		dind    : out std_logic_vector (BRAM_24_DATA - 1 downto 0);
		doutd : in std_logic_vector (BRAM_24_DATA - 1 downto 0);
		wed        : out std_logic; 
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end SURF_v1_0;

architecture arch_imp of SURF_v1_0 is
        signal reset_s : std_logic;


        ------------------ Interface to IP -------------------------
        signal iradius_s :  std_logic_vector(WIDTH - 1 downto 0);
        signal fracr_s :  std_logic_vector(FIXED_SIZE - 1 downto 0);
        signal fracc_s :  std_logic_vector(FIXED_SIZE - 1 downto 0);
        signal spacing_s :  std_logic_vector(FIXED_SIZE - 1 downto 0);
        signal iy_s :  std_logic_vector(WIDTH - 1 downto 0);
        signal ix_s :  std_logic_vector(WIDTH - 1 downto 0);
        signal step_s :  std_logic_vector(WIDTH - 1 downto 0);
        signal i_cose_s :  std_logic_vector(FIXED_SIZE - 1 downto 0);
        signal i_sine_s :  std_logic_vector(FIXED_SIZE - 1 downto 0);
        signal scale_s :  std_logic_vector(WIDTH - 1 downto 0);
        signal start_i_s :  std_logic;
        signal ready_o_s :  std_logic;
        
        signal bram_addr1_o : std_logic_vector(PIXEL_SIZE -1 downto 0);
        signal bram_addr2_o : std_logic_vector(PIXEL_SIZE -1 downto 0);
        signal bram_data24upp_i : std_logic_vector(BRAM_24_DATA -1 downto 0);
        signal bram_data24low_i : std_logic_vector(BRAM_24_DATA -1 downto 0);
        signal bram_en1_o : std_logic;
        signal bram_en2_o : std_logic;
        
        signal addr_do1_o : std_logic_vector (7 downto 0);
        signal addr_do2_o : std_logic_vector (7 downto 0);
        signal data24upp_o : std_logic_vector (BRAM_24_DATA - 1 downto 0);          
        signal data24low_o : std_logic_vector (BRAM_24_DATA - 1 downto 0);          
        signal c1_data_o : std_logic;
        signal bram_we1_o : std_logic;
        signal c2_data_o : std_logic;
        signal bram_we2_o : std_logic;

        signal rom_data_s :  std_logic_vector(FIXED_SIZE - 1 downto 0);
        signal rom_addr_s :  std_logic_vector(5 downto 0);  
        
    component ip is
        generic (
        WIDTH : integer := 11;            -- Bit width for various unsigned signals
        PIXEL_SIZE : integer := 17;       -- 129 x 129 pixels
        INDEX_ADDRESS_SIZE : integer := 8;
        FIXED_SIZE : integer := 48;       -- Bit width for fixed-point operations
        BRAM_24_DATA : integer := 24;
        INDEX_SIZE : integer := 4;        -- Dimension size for the index array
        IMG_WIDTH : integer := 129;       -- Width of the image
        IMG_HEIGHT : integer := 129       -- Height of the image
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        iradius : in std_logic_vector(WIDTH - 1 downto 0);
        fracr : in std_logic_vector(FIXED_SIZE - 1 downto 0);
        fracc : in std_logic_vector(FIXED_SIZE - 1 downto 0);
        spacing : in std_logic_vector(FIXED_SIZE - 1 downto 0);
        iy : in std_logic_vector(WIDTH - 1 downto 0);
        ix : in std_logic_vector(WIDTH - 1 downto 0);
        step : in std_logic_vector(WIDTH - 1 downto 0);
        i_cose : in std_logic_vector(FIXED_SIZE - 1 downto 0);
        i_sine : in std_logic_vector(FIXED_SIZE - 1 downto 0);
        scale : in std_logic_vector(WIDTH - 1 downto 0);
         ---------------MEM INTERFEJSI ZA SLIKU--------------------
        bram_addr1_o : out std_logic_vector(PIXEL_SIZE -1 downto 0);
        bram_addr2_o : out std_logic_vector(PIXEL_SIZE -1 downto 0);
        bram_data24upp_i : in std_logic_vector(BRAM_24_DATA -1 downto 0);
        bram_data24low_i : in std_logic_vector(BRAM_24_DATA -1 downto 0);
        bram_en1_o : out std_logic;
        bram_en2_o : out std_logic;
        ---------------MEM INTERFEJSI ZA IZLAZ--------------------
        addr_do1_o : out std_logic_vector (7 downto 0);
        addr_do2_o : out std_logic_vector (7 downto 0);
        data24upp_o : out std_logic_vector (BRAM_24_DATA - 1 downto 0);          
        data24low_o : out std_logic_vector (BRAM_24_DATA - 1 downto 0);          
        c1_data_o : out std_logic;
        bram_we1_o : out std_logic;
        c2_data_o : out std_logic;
        bram_we2_o : out std_logic;
        ---------------INTERFEJS ZA ROM--------------------
        rom_data : in std_logic_vector(FIXED_SIZE - 1 downto 0);
        rom_addr : out std_logic_vector(5 downto 0);  
        ---------------KOMANDNI INTERFEJS------------------------
        start_i : in std_logic;
        ---------------STATUSNI INTERFEJS------------------------
        ready_o : out std_logic
    );
    end component;  
    
	-- component declaration
	component SURF_v1_0_S00_AXI is
		generic (
 WIDTH : integer := 11;
 FIXED_SIZE : integer := 48;
 UPPER_SIZE : integer := 24;
 LOWER_SIZE : integer := 24; 
                C_S_AXI_DATA_WIDTH	: integer	:= 32;
                C_S_AXI_ADDR_WIDTH	: integer	:= 7
		);
		port (
		iradius_axi_o : out std_logic_vector(WIDTH - 1 downto 0);
        fracr_axi_o : out std_logic_vector(FIXED_SIZE - 1 downto 0);
        fracc_axi_o : out std_logic_vector(FIXED_SIZE - 1 downto 0);
        spacing_axi_o : out std_logic_vector(FIXED_SIZE - 1 downto 0);
        iy_axi_o : out std_logic_vector(WIDTH - 1 downto 0);
        ix_axi_o : out std_logic_vector(WIDTH - 1 downto 0);
        step_axi_o : out std_logic_vector(WIDTH - 1 downto 0);
        i_cose_axi_o : out std_logic_vector(FIXED_SIZE - 1 downto 0);
        i_sine_axi_o : out std_logic_vector(FIXED_SIZE - 1 downto 0);
        scale_axi_o : out std_logic_vector(WIDTH - 1 downto 0);
        start_i_axi : out std_logic;
        ready_axi_i : in std_logic;
        
                S_AXI_ACLK	: in std_logic;
                S_AXI_ARESETN	: in std_logic;
                S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
                S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
                S_AXI_AWVALID	: in std_logic;
                S_AXI_AWREADY	: out std_logic;
                S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
                S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
                S_AXI_WVALID	: in std_logic;
                S_AXI_WREADY	: out std_logic;
                S_AXI_BRESP	: out std_logic_vector(1 downto 0);
                S_AXI_BVALID	: out std_logic;
                S_AXI_BREADY	: in std_logic;
                S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
                S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
                S_AXI_ARVALID	: in std_logic;
                S_AXI_ARREADY	: out std_logic;
                S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
                S_AXI_RRESP	: out std_logic_vector(1 downto 0);
                S_AXI_RVALID	: out std_logic;
                S_AXI_RREADY	: in std_logic
		);
	end component SURF_v1_0_S00_AXI;

begin

reset_s <= not s00_axi_aresetn;

-- Instantiation of Axi Bus Interface S00_AXI
SURF_v1_0_S00_AXI_inst : SURF_v1_0_S00_AXI
	generic map (
	  WIDTH => WIDTH,
      FIXED_SIZE => FIXED_SIZE,
       UPPER_SIZE => 24,
 LOWER_SIZE => 24,
        
                C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
                C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	    iradius_axi_o => iradius_s,
        fracr_axi_o => fracr_s,
        fracc_axi_o => fracc_s,
        spacing_axi_o => spacing_s, 
        iy_axi_o => iy_s,
        ix_axi_o => ix_s,
        step_axi_o => step_s,
        i_cose_axi_o => i_cose_s, 
        i_sine_axi_o => i_sine_s,
        scale_axi_o => scale_s,
        start_i_axi => start_i_s,    
        ready_axi_i => ready_o_s,
        
                S_AXI_ACLK	=> s00_axi_aclk,
                S_AXI_ARESETN	=> s00_axi_aresetn,
                S_AXI_AWADDR	=> s00_axi_awaddr,
                S_AXI_AWPROT	=> s00_axi_awprot,
                S_AXI_AWVALID	=> s00_axi_awvalid,
                S_AXI_AWREADY	=> s00_axi_awready,
                S_AXI_WDATA	=> s00_axi_wdata,
                S_AXI_WSTRB	=> s00_axi_wstrb,
                S_AXI_WVALID	=> s00_axi_wvalid,
                S_AXI_WREADY	=> s00_axi_wready,
                S_AXI_BRESP	=> s00_axi_bresp,
                S_AXI_BVALID	=> s00_axi_bvalid,
                S_AXI_BREADY	=> s00_axi_bready,
                S_AXI_ARADDR	=> s00_axi_araddr,
                S_AXI_ARPROT	=> s00_axi_arprot,
                S_AXI_ARVALID	=> s00_axi_arvalid,
                S_AXI_ARREADY	=> s00_axi_arready,
                S_AXI_RDATA	=> s00_axi_rdata,
                S_AXI_RRESP	=> s00_axi_rresp,
                S_AXI_RVALID	=> s00_axi_rvalid,
                S_AXI_RREADY	=> s00_axi_rready
	);

	-- Add user logic here
 ip_inst: ip
    generic map (
        WIDTH => WIDTH,
        FIXED_SIZE => FIXED_SIZE
    )
    port map(
        clk => s00_axi_aclk,
        reset => reset_s,
        
         ---------------REGISTRI----------------------------------
        iradius => iradius_s,
        fracr => fracr_s,
        fracc => fracc_s,
        spacing => spacing_s,
        iy => iy_s,
        ix => ix_s,
        step => step_s,
        i_cose => i_cose_s,
        i_sine => i_sine_s,
        scale => scale_s,
        
        ---------------MEM INTERFEJS ZA SLIKU32--------------------
        bram_addr1_o => addra,
        bram_data24upp_i => douta,
        bram_en1_o => ena,
        
        ---------------MEM INTERFEJS ZA SLIKU16--------------------
        bram_addr2_o => addrb,
        bram_data24low_i => doutb,
        bram_en2_o => enb,
        ---------------MEM INTERFEJS ZA IZLAZ32--------------------

        addr_do1_o => addrc,
        data24upp_o => dinc,        
        c1_data_o => enc,
        bram_we1_o => wec,
        
        ---------------MEM INTERFEJS ZA IZLAZ16--------------------
        addr_do2_o => addrd,
        data24low_o => dind,        
        c2_data_o => en_d,
        bram_we2_o => wed,
        
        rom_data => rom_data_s,
        rom_addr => rom_addr_s,
        ---------------KOMANDNI INTERFEJS------------------------
        start_i => start_i_s,
        ---------------STATUSNI INTERFEJS------------------------
        ready_o => ready_o_s
     );
     
        clka <= s00_axi_aclk;
        clkb <= s00_axi_aclk;
        clkc <= s00_axi_aclk;
        clkd <= s00_axi_aclk;
        
        reseta <= reset_s;
        resetb <= reset_s;
        resetc <= reset_s;
        resetd <= reset_s;
        wea <= '0';
        web <= '0';
        dina <= (others => '0');
        dinb <= (others => '0');
	-- User logic ends

end arch_imp;