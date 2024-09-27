library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use work.txt_util.all;

entity tb_ip is
end tb_ip;

architecture Behavioral of tb_ip is

file pixels1D_upper24 : text open read_mode is "C:\Users\coa\Desktop\psds_ucitavanje\pixels1D_upper24.txt";
file pixels1D_lower24 : text open read_mode is "C:\Users\coa\Desktop\psds_ucitavanje\pixels1D_lower24.txt";

file index1D_upper24 : text open read_mode is "C:\Users\coa\Desktop\psds_ucitavanje\index_upper24.txt";
file index1D_lower24 : text open read_mode is "C:\Users\coa\Desktop\psds_ucitavanje\index_lower24.txt";

file izlaz_upper24 : text open write_mode is "C:\Users\coa\Desktop\psds_ucitavanje\izlaz_upper24.txt";
file izlaz_lower24 : text open write_mode is "C:\Users\coa\Desktop\psds_ucitavanje\izlaz_lower24.txt";

-- Constants
constant WIDTH : integer := 11;
constant PIXEL_SIZE : integer := 17;
constant INDEX_ADDRESS_SIZE : integer := 8;
constant FIXED_SIZE : integer := 48;
constant LOWER_SIZE : integer := 16;

constant BRAM_24_DATA : integer := 24;
        
constant INDEX_SIZE : integer := 4;
constant IMG_WIDTH : integer := 129;
constant IMG_HEIGHT : integer := 129;

----PODACI KOJE CU POSLE POSLATI (BROJEVI IZ VP) 
    constant FRACR_UPPER_C : std_logic_vector(BRAM_24_DATA-1 downto 0) := "000000000000000000000000";    --0.06777191162109375
    constant FRACR_LOWER_C : std_logic_vector(BRAM_24_DATA-1 downto 0) := "000000000100010101100110";
    constant FRACC_UPPER_C : std_logic_vector(BRAM_24_DATA-1 downto 0) := "000000000000000000000000";    --0.06403732299804688
    constant FRACC_LOWER_C : std_logic_vector(BRAM_24_DATA-1 downto 0) := "000000000100000110010011";
    constant SPACING_UPPER_C : std_logic_vector(BRAM_24_DATA-1 downto 0) := "000000000000000000000000";   --0.0727539062
    constant SPACING_LOWER_C : std_logic_vector(BRAM_24_DATA-1 downto 0) := "000000000100101010000000";
    constant I_COSE_UPPER_C : std_logic_vector(BRAM_24_DATA-1 downto 0) := "111111111111111111111111";     --  -0.0352935791015625
    constant I_COSE_LOWER_C : std_logic_vector(BRAM_24_DATA-1 downto 0) := "111111111101101111011100";
    constant I_SINE_UPPER_C : std_logic_vector(BRAM_24_DATA-1 downto 0) := "000000000000000000000000";     --   0.9993743896484375
    constant I_SINE_LOWER_C : std_logic_vector(BRAM_24_DATA-1 downto 0) := "000000111111111101011100";
    constant IRADIUS_C : std_logic_vector(WIDTH - 1 downto 0) := "00000011000";    --24
    constant IY_C : std_logic_vector(WIDTH - 1 downto 0) := "00000100000";         --32
    constant IX_C : std_logic_vector(WIDTH - 1 downto 0) := "00000101101";         --45
    constant STEP_C : std_logic_vector(WIDTH - 1 downto 0) := "00000000010";       --2
    constant SCALE_C : std_logic_vector(WIDTH - 1 downto 0) := "00000000100";      --4

    ----------------------IP registers-----------------------------
    constant FRACR_UPPER_REG_ADDR_C : integer := 0;
    constant FRACR_LOWER_REG_ADDR_C : integer := 4;
    constant FRACC_UPPER_REG_ADDR_C : integer := 8;
    constant FRACC_LOWER_REG_ADDR_C : integer := 12;
    constant SPACING_UPPER_REG_ADDR_C : integer := 16;
    constant SPACING_LOWER_REG_ADDR_C : integer := 20;
    constant I_COSE_UPPER_REG_ADDR_C : integer := 24;
    constant I_COSE_LOWER_REG_ADDR_C : integer := 28;
    constant I_SINE_UPPER_REG_ADDR_C : integer := 32;
    constant I_SINE_LOWER_REG_ADDR_C : integer := 36;
    constant IRADIUS_REG_ADDR_C : integer := 40;
    constant IY_REG_ADDR_C : integer := 44;
    constant IX_REG_ADDR_C : integer := 48;
    constant STEP_REG_ADDR_C : integer := 52;
    constant SCALE_REG_ADDR_C : integer := 56;
    constant CMD_REG_ADDR_C : integer := 60;
    constant STATUS_REG_ADDR_C : integer := 64;
    
    ---------------------------------------------------------------
 
    signal clk_s: std_logic;
    signal reset_s: std_logic;

------------------ Ports for BRAM Initialization -----------------

-- Input BRAM_32 port
signal tb_a_en_i : std_logic;
signal tb_a_addr_i : std_logic_vector(PIXEL_SIZE-1 downto 0);
signal tb_a_data_i : std_logic_vector(BRAM_24_DATA-1 downto 0);
signal tb_a_we_i : std_logic;

-- Input BRAM_16 port
signal tb_b_en_i : std_logic;
signal tb_b_addr_i : std_logic_vector(PIXEL_SIZE-1 downto 0);
signal tb_b_data_i : std_logic_vector(BRAM_24_DATA-1 downto 0);
signal tb_b_we_i : std_logic; 
    
-- Output BRAM32 port
signal tb_c_en_i : std_logic;
signal tb_c_addr_i : std_logic_vector(7 downto 0);
signal tb_c_data_o : std_logic_vector(BRAM_24_DATA - 1 downto 0);
signal tb_c_we_i : std_logic;

-- Output BRAM16 port
signal tb_d_en_i : std_logic;
signal tb_d_addr_i : std_logic_vector(7 downto 0);
signal tb_d_data_o : std_logic_vector(BRAM_24_DATA - 1 downto 0);
signal tb_d_we_i : std_logic;



------------------------- Ports to IP ---------------------

signal ip_a_en : std_logic;
signal ip_a_we : std_logic;
signal ip_a_addr : std_logic_vector(PIXEL_SIZE-1 downto 0);
signal ip_a_data: std_logic_vector(BRAM_24_DATA-1 downto 0);

signal ip_b_en : std_logic;
signal ip_b_we : std_logic;
signal ip_b_addr : std_logic_vector(PIXEL_SIZE-1 downto 0);
signal ip_b_data: std_logic_vector(BRAM_24_DATA-1 downto 0);

signal ip_c_en : std_logic;
signal ip_c_we : std_logic;
signal ip_c_addr : std_logic_vector(7 downto 0);
signal ip_c_data: std_logic_vector(BRAM_24_DATA - 1 downto 0);

signal ip_d_en : std_logic;
signal ip_d_we : std_logic;
signal ip_d_addr : std_logic_vector(7 downto 0);
signal ip_d_data: std_logic_vector(BRAM_24_DATA - 1 downto 0);

------------------- AXI Interfaces signals ----------------------
    
    -- Parameters of Axi-Lite Slave Bus Interface S00_AXI
    constant C_S00_AXI_DATA_WIDTH_c : integer := 32;
    constant C_S00_AXI_ADDR_WIDTH_c : integer := 7;
    
    -- Ports of Axi-Lite Slave Bus Interface S00_AXI
    signal s00_axi_aclk_s : std_logic := '0';
    signal s00_axi_aresetn_s : std_logic := '1';
    signal s00_axi_awaddr_s : std_logic_vector(C_S00_AXI_ADDR_WIDTH_c-1 downto 0) := (others => '0');
    signal s00_axi_awprot_s : std_logic_vector(2 downto 0) := (others => '0');
    signal s00_axi_awvalid_s : std_logic := '0';
    signal s00_axi_awready_s : std_logic := '0';
    signal s00_axi_wdata_s : std_logic_vector(C_S00_AXI_DATA_WIDTH_c-1 downto 0) := (others => '0');
    signal s00_axi_wstrb_s : std_logic_vector((C_S00_AXI_DATA_WIDTH_c/8)-1 downto 0) := (others => '0');
    signal s00_axi_wvalid_s : std_logic := '0';
    signal s00_axi_wready_s : std_logic := '0';
    signal s00_axi_bresp_s : std_logic_vector(1 downto 0) := (others => '0');
    signal s00_axi_bvalid_s : std_logic := '0';
    signal s00_axi_bready_s : std_logic := '0';
    signal s00_axi_araddr_s : std_logic_vector(C_S00_AXI_ADDR_WIDTH_c-1 downto 0) := (others => '0');
    signal s00_axi_arprot_s : std_logic_vector(2 downto 0) := (others => '0');
    signal s00_axi_arvalid_s : std_logic := '0';
    signal s00_axi_arready_s : std_logic := '0';
    signal s00_axi_rdata_s : std_logic_vector(C_S00_AXI_DATA_WIDTH_c-1 downto 0) := (others => '0');
    signal s00_axi_rresp_s : std_logic_vector(1 downto 0) := (others => '0');
    signal s00_axi_rvalid_s : std_logic := '0';
    signal s00_axi_rready_s : std_logic := '0';
begin

   reset_s <= not s00_axi_aresetn_s; --reset for BRAM
   
clk_gen: process is
    begin
        clk_s <= '0', '1' after 10 ns;
        wait for 20 ns;
    end process;
    
    
    stimulus_generator: process
    variable tv_slika_upper24, tv_slika_lower24  : line;
    begin
    report "Start !";

    -- reset AXI-lite interface. Reset will be 10 clock cycles wide
    s00_axi_aresetn_s <= '0';
    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;
    -- release reset
    s00_axi_aresetn_s <= '1';
    wait until falling_edge(clk_s);
        
     ----------------------------------------------------------------------

    -- Initialize the core --
    report "Loading the picture dimensions into the core!";
    
    
-- Slanje gornjih 24 bita (FRACR_UPPER_C)
wait until falling_edge(clk_s);
s00_axi_awaddr_s <= std_logic_vector(to_unsigned(FRACR_UPPER_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
s00_axi_awvalid_s <= '1';
s00_axi_wdata_s <= std_logic_vector(to_unsigned(0,8)) & FRACR_UPPER_C;  
s00_axi_wvalid_s <= '1';
s00_axi_wstrb_s <= "0111";
s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_DATA_WIDTH_c));
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s);

-- Slanje donjih 24 bita (FRACR_LOWER_C), smestenih u donji deo 32-bitne širine
wait until falling_edge(clk_s);
s00_axi_awaddr_s <= std_logic_vector(to_unsigned(FRACR_LOWER_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
s00_axi_awvalid_s <= '1';
s00_axi_wdata_s <= std_logic_vector(to_unsigned(0,8)) & FRACR_LOWER_C; 
s00_axi_wvalid_s <= '1';
s00_axi_wstrb_s <= "0111";  
s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_DATA_WIDTH_c));
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s);


    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;
    
     -- Slanje gornjih 24 bita (FRACC_UPPER_C)
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(FRACC_UPPER_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <=std_logic_vector(to_unsigned(0,8)) &  FRACC_UPPER_C;  
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "0111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_DATA_WIDTH_c));
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s);
    
    -- Slanje donjih 24 bita (FRACC_LOWER_C)
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(FRACC_LOWER_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0,8)) & FRACC_LOWER_C;  
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "0111";  
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_DATA_WIDTH_c));
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s);
    
    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;
    
        -- Slanje gornjih 24 bita (SPACING_UPPER_C)
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(SPACING_UPPER_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0,8)) & SPACING_UPPER_C;  
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "0111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awvalid_s <= '0';
    s00_axi_wvalid_s <= '0';
    s00_axi_bready_s <= '0';
    
    -- Slanje donjih 24 bita (SPACING_LOWER_C
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(SPACING_LOWER_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0,8)) & SPACING_LOWER_C;  
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "0111";  
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_DATA_WIDTH_c));
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s);
    
    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;
   
    
         -- Slanje gornjih 24 bita (I_COSE_UPPER_C)
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(I_COSE_UPPER_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <=std_logic_vector(to_unsigned(0,8)) &  I_COSE_UPPER_C;  
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "0111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awvalid_s <= '0';
    s00_axi_wvalid_s <= '0';
    s00_axi_bready_s <= '0';
    
    -- Slanje donjih 24 bita (I_COSE_LOWER_C)
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(I_COSE_LOWER_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0,8)) & I_COSE_LOWER_C;  
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "0111";  
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_DATA_WIDTH_c));
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s);
    
    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;
    
             -- Slanje gornjih 24 bita (I_SINE_UPPER_C)
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(I_SINE_UPPER_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0,8)) & I_SINE_UPPER_C;  
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "0111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awvalid_s <= '0';
    s00_axi_wvalid_s <= '0';
    s00_axi_bready_s <= '0';
    
    -- Slanje donjih 24 bita (I_SINE_LOWER_C)
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(I_SINE_LOWER_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0,8)) & I_SINE_LOWER_C;  
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "0111";  
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_DATA_WIDTH_c));
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s);
    
    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;
   
    
    -- Set the value for IRADIUS
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(IRADIUS_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0, 21)) & IRADIUS_C;
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";    
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_DATA_WIDTH_c));
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s);
    
    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;
    
      -- Set the value for IY
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(IY_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0, 21)) & IY_C;
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";    
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_DATA_WIDTH_c));
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s);
    
    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;
   
    
      -- Set the value for IX
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(IX_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0, 21)) & IX_C;
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";     
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_DATA_WIDTH_c));
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s);
    
      -- Set the value for STEP
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(STEP_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0, 21)) & STEP_C;
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";     
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_DATA_WIDTH_c));
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s);
    
    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;
        
      -- Set the value for SCALE
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(SCALE_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0, 21)) & SCALE_C;
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";     
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_DATA_WIDTH_c));
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s);
    
    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;
    
    -------------------------------------------------------------------------------------------

    -- Load the picture32 into the memory
    report "Loading picture32 into the memory!";
    
    wait until falling_edge(clk_s);

    for i in 0 to (IMG_WIDTH*IMG_HEIGHT)-1 loop 
        wait until falling_edge(clk_s);
        readline(pixels1D_upper24, tv_slika_upper24);
        tb_a_en_i  <= '1';
        tb_a_addr_i <= std_logic_vector(to_unsigned(4*i, PIXEL_SIZE)); 
        tb_a_data_i <= to_std_logic_vector(string(tv_slika_upper24));
        tb_a_we_i   <= '1';
     
        for j in 1 to 3 loop
            wait until falling_edge(clk_s);
        end loop;
        tb_a_en_i <= '0';
        tb_a_we_i <= '0';
    end loop;
    tb_a_en_i <= '0';
    tb_a_we_i <= '0';
    
        -------------------------------------------------------------------------------------------

    -- Load the picture24 into the memory
    report "Loading picture16 into the memory!";
    
    wait until falling_edge(clk_s);

    for i in 0 to (IMG_WIDTH*IMG_HEIGHT)-1 loop 
        wait until falling_edge(clk_s);
        readline(pixels1D_lower24, tv_slika_lower24);
        tb_b_en_i  <= '1';
        tb_b_addr_i <= std_logic_vector(to_unsigned(4*i, PIXEL_SIZE)); 
        tb_b_data_i <= to_std_logic_vector(string(tv_slika_lower24));
        tb_b_we_i   <= '1';
     
        for j in 1 to 3 loop
            wait until falling_edge(clk_s);
        end loop;
        tb_b_en_i <= '0';
        tb_b_we_i <= '0';
    end loop;
    tb_b_en_i <= '0';
    tb_b_we_i <= '0';
    
   -------------------------------------------------------------------------------------------
    -- Start the ip core --
    -------------------------------------------------------------------------------------------
    report "Starting proccesing!";
    -- Set the start bit (bit 0 in the CMD_REG_ADDR_C register) to 1
    
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(CMD_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(1, C_S00_AXI_DATA_WIDTH_c));
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_DATA_WIDTH_c));
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s);
    
     -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;


    report "Clearing the start bit!";
    -- Set the start bit (bit 0 in the CMD_REG_ADDR_C register) to 0
    
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(CMD_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_DATA_WIDTH_c));
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_DATA_WIDTH_c));
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s);
    
     -------------------------------------------------------------------------------------------    
     -- Wait until ip core finishes processing --
    -------------------------------------------------------------------------------------------
    report "Waiting for the process to complete!";
    loop
        -- Read the content of the Status register
        wait until falling_edge(clk_s);
        s00_axi_araddr_s <= std_logic_vector(to_unsigned(STATUS_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));     
        s00_axi_arvalid_s <= '1';
        s00_axi_rready_s <= '1';
        wait until s00_axi_arready_s = '1';
        wait until s00_axi_arready_s = '0';
        wait until falling_edge(clk_s);
        s00_axi_araddr_s <= std_logic_vector(to_unsigned(0, C_S00_AXI_ADDR_WIDTH_c));
        s00_axi_arvalid_s <= '0';
        s00_axi_rready_s <= '0';
        
       
        
        -- Check is the 1st bit of the Status register set to one
        if (s00_axi_rdata_s(0) = '1') then
            -- ip core done
             report "IP core is done!";
            exit;
        else
            wait for 1000 ns;
        end if;
    end loop;
    
    ------------------------------------------------------------------------------------------
    -- Reading the results of from output memory!  --
    -------------------------------------------------------------------------------------------
   report "Reading the results of from output memory!";

    for k in 0 to 4*INDEX_SIZE*INDEX_SIZE-1 loop
        wait until falling_edge(clk_s);
        tb_c_en_i <= '1';
        tb_d_en_i <= '1';

        tb_c_we_i <= '0';
        tb_d_we_i <= '0';

        tb_c_addr_i <= std_logic_vector(to_unsigned(k*4, 8));
        tb_d_addr_i <= std_logic_vector(to_unsigned(k*4, 8));

        wait until falling_edge(clk_s);

    end loop;

    tb_c_en_i <= '0';
    tb_d_en_i <= '0';

    
    report "Finished!";

    wait;
end process;

write_to_output_file24 : process(clk_s)
    variable data_output24_line : line;
    variable data_output24_string : string(1 to BRAM_24_DATA) := (others => '0');
    variable prev_addr : std_logic_vector(7 downto 0) := (others => '1');  -- promenite pocetnu vrednost
    variable first_iteration : boolean := true;  -- signal za pracenje prve iteracije
begin
    if falling_edge(clk_s) then
        if tb_c_en_i = '1' then
            -- Upiši samo ako je prva iteracija ili se adresa promenila
            if first_iteration or (tb_c_addr_i /= prev_addr) then
                prev_addr := tb_c_addr_i;  -- azuriraj prethodnu adresu
                first_iteration := false;  -- postavi signal da prva iteracija više nije aktivna

                -- Pripremi podatke za upis
                data_output24_string := (others => '0');
                for i in 0 to BRAM_24_DATA - 1 loop
                    if tb_c_data_o(i) = '1' then
                        data_output24_string(BRAM_24_DATA - i) := '1';  
                    else
                        data_output24_string(BRAM_24_DATA - i) := '0';  
                    end if;
                end loop;

                -- Upis podataka u izlazni fajl
                write(data_output24_line, data_output24_string);
                writeline(izlaz_upper24, data_output24_line);
            end if;
        end if;
    end if;
end process;

write_to_output_file24_lower : process(clk_s)
    variable data_output24_line : line;
    variable data_output24_string : string(1 to BRAM_24_DATA) := (others => '0');
    variable prev_addr : std_logic_vector(7 downto 0) := (others => '1');  -- promenite pocetnu vrednost
    variable first_iteration : boolean := true;  -- signal za pracenje prve iteracije
begin
    if falling_edge(clk_s) then
        if tb_d_en_i = '1' then
            -- Upiši samo ako je prva iteracija ili se adresa promenila
            if first_iteration or (tb_d_addr_i /= prev_addr) then
                prev_addr := tb_d_addr_i;  -- azuriraj prethodnu adresu
                first_iteration := false;  -- postavi signal da prva iteracija više nije aktivna

                -- Pripremi podatke za upis
                data_output24_string := (others => '0');
                for i in 0 to BRAM_24_DATA - 1 loop
                    if tb_d_data_o(i) = '1' then
                        data_output24_string(BRAM_24_DATA - i) := '1';  
                    else
                        data_output24_string(BRAM_24_DATA - i) := '0';  
                    end if;
                end loop;

                -- Upis podataka u izlazni fajl
                write(data_output24_line, data_output24_string);
                writeline(izlaz_lower24, data_output24_line);
            end if;
        end if;
    end if;
end process;


---------------------------------------------------------------------------
---- DUT --
---------------------------------------------------------------------------
uut: entity work.SURF_v1_0(arch_imp)
    generic map (
        WIDTH => WIDTH,
        PIXEL_SIZE => PIXEL_SIZE,
        INDEX_ADDRESS_SIZE => INDEX_ADDRESS_SIZE,
        FIXED_SIZE => FIXED_SIZE,
        INDEX_SIZE => INDEX_SIZE,
        BRAM_24_DATA => BRAM_24_DATA,
        IMG_WIDTH => IMG_WIDTH,
        IMG_HEIGHT => IMG_HEIGHT
    )
    port map (
    
     -- Interfejs za sliku32
        ena     => ip_a_en,
        wea     => open,
        addra   => ip_a_addr,
        dina => open,
        douta => ip_a_data,
        reseta   => open,
        clka     => open,
    
     -- Interfejs za sliku16
        
        enb     => ip_b_en,
        web     => open,
        addrb   => ip_b_addr,
        dinb    => open,
        doutb   => ip_b_data,
        resetb  => open,
        clkb    => open,
        
      -- Interfejs za izlaz32
        
        enc     => open,
        wec     => ip_c_we,
        addrc   => ip_c_addr,
        dinc => ip_c_data,
        doutc   =>(others=>'0'),
        resetc  => open,
        clkc    => open,
        
      -- Interfejs za izlaz16
        
        en_d     => open,
        wed     => ip_d_we,
        addrd   => ip_d_addr,
        dind => ip_d_data,
        doutd   =>(others=>'0'),
        resetd  => open,
        clkd    => open,
        
        
 -- Ports of Axi Slave Bus Interface S00_AXI
        s00_axi_aclk    => clk_s,
        s00_axi_aresetn => s00_axi_aresetn_s,
        s00_axi_awaddr  => s00_axi_awaddr_s,
        s00_axi_awprot  => s00_axi_awprot_s, 
        s00_axi_awvalid => s00_axi_awvalid_s,
        s00_axi_awready => s00_axi_awready_s,
        s00_axi_wdata   => s00_axi_wdata_s,
        s00_axi_wstrb   => s00_axi_wstrb_s,
        s00_axi_wvalid  => s00_axi_wvalid_s,
        s00_axi_wready  => s00_axi_wready_s,
        s00_axi_bresp   => s00_axi_bresp_s,
        s00_axi_bvalid  => s00_axi_bvalid_s,
        s00_axi_bready  => s00_axi_bready_s,
        s00_axi_araddr  => s00_axi_araddr_s,
        s00_axi_arprot  => s00_axi_arprot_s,
        s00_axi_arvalid => s00_axi_arvalid_s,
        s00_axi_arready => s00_axi_arready_s,
        s00_axi_rdata   => s00_axi_rdata_s,
        s00_axi_rresp   => s00_axi_rresp_s,
        s00_axi_rvalid  => s00_axi_rvalid_s,
        s00_axi_rready  => s00_axi_rready_s
    );


-- Instantiation of input 24 BRAM
bramA: entity work.bram24_upper_in(Behavioral)
  generic map (WIDTH =>24,
             SIZE => IMG_WIDTH*IMG_HEIGHT*4,
			 SIZE_WIDTH => 17)
         port map(
               clka => clk_s,
               clkb => clk_s,
	           ena=>tb_a_en_i,
	           wea=> tb_a_we_i,
	           addra=> tb_a_addr_i,
	           dia=> tb_a_data_i,
	           doa=> open,
	
	           enb=>ip_a_en,
	           web=>ip_a_we,
	           addrb=>ip_a_addr,
	           dib=>(others=>'0'),
	           dob=> ip_a_data    
	        );
	        
-- Instantiation of input 24 BRAM
bramB: entity work.bram24_lower_in(Behavioral) 
    generic map( WIDTH =>24,
             SIZE => IMG_WIDTH*IMG_HEIGHT*4,
			 SIZE_WIDTH => 17 )
             
    port map(
               clka => clk_s,
               clkb => clk_s,
	           ena=>tb_b_en_i,
	           wea=> tb_b_we_i,
	           addra=> tb_b_addr_i,
	           dia=> tb_b_data_i,
	           doa=> open,
	
	           enb=>ip_b_en,
	           web=>ip_b_we,
	           addrb=>ip_b_addr,
	           dib=>(others=>'0'),
	           dob=> ip_b_data
	        ); 
	         
-- Instantiation of output 24 BRAM
bramC: entity work.bram24_upper_out
    generic map (
        WIDTH => 24,  -- data width
        SIZE => 4*64,  -- memory depth
        SIZE_WIDTH => INDEX_ADDRESS_SIZE
    )
    port map (
        clka => clk_s,
        clkb => clk_s,
        ena => ip_c_en, 
        wea => ip_c_we, 
        addra => ip_c_addr, 
        dia => ip_c_data, 
        doa => open,

        enb => tb_c_en_i,
        web => tb_c_we_i,
        addrb => tb_c_addr_i,
        dib => (others => '0'),
        dob => tb_c_data_o
    );
    
-- Instantiation of output 24 BRAM
bramD: entity work.bram24_lower_out
    generic map (
        WIDTH => 24,  -- data width
        SIZE => 4*64,  -- memory depth
        SIZE_WIDTH => INDEX_ADDRESS_SIZE
    )
    port map (
        clka => clk_s,
        clkb => clk_s,
        ena => ip_d_en, 
        wea => ip_d_we, 
        addra => ip_d_addr, 
        dia => ip_d_data, 
        doa => open,

        enb => tb_d_en_i,
        web => tb_d_we_i,
        addrb => tb_d_addr_i,
        dib => (others => '0'),
        dob => tb_d_data_o
    );
    
end Behavioral;
