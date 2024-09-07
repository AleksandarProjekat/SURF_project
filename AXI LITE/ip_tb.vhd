library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use work.txt_util.all;

entity tb_ip is
end tb_ip;

architecture Behavioral of tb_ip is

file pixels1D : text open read_mode is "C:\Users\coa\Desktop\pixels1D.txt";
file index1Dbin : text open read_mode is "C:\Users\coa\Desktop\index1Dbin.txt";
file izlaz : text open write_mode is "C:\Users\coa\Desktop\izlaz.txt";

-- Constants
constant WIDTH : integer := 11;
constant PIXEL_SIZE : integer := 17;
constant INDEX_ADDRESS_SIZE : integer := 8;
constant FIXED_SIZE : integer := 48;
constant LOWER_SIZE : integer := 16;

constant INDEX_SIZE : integer := 4;
constant IMG_WIDTH : integer := 129;
constant IMG_HEIGHT : integer := 129;

----PODACI KOJE CU POSLE POSLATI (BROJEVI IZ VP) 
    constant FRACR_UPPER_C : std_logic_vector(32-1 downto 0) := "00000000000000000000000000000000";    --0.06777191162109375
    constant FRACR_LOWER_C : std_logic_vector(15 downto 0) := "0100010101100110";
    constant FRACC_UPPER_C : std_logic_vector(32-1 downto 0) := "00000000000000000000000000000000";    --0.06403732299804688
    constant FRACC_LOWER_C : std_logic_vector(15 downto 0) := "0100000110010011";
    constant SPACING_UPPER_C : std_logic_vector(32-1 downto 0) := "00000000000000000000000000000000";   --0.0727539062
    constant SPACING_LOWER_C : std_logic_vector(15 downto 0) := "0100101010000000";
    constant I_COSE_UPPER_C : std_logic_vector(32-1 downto 0) := "11111111111111111111111111111111";     --  -0.0352935791015625
    constant I_COSE_LOWER_C : std_logic_vector(15 downto 0) := "1101101111011100";
    constant I_SINE_UPPER_C : std_logic_vector(32-1 downto 0) := "00000000000000000000000000000011";     --   0.9993743896484375
    constant I_SINE_LOWER_C : std_logic_vector(15 downto 0) := "1111111101011100";
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
    constant START_ADDR_C : integer := 60;
    constant READY_REG_ADDR_C : integer := 64;
    
    ---------------------------------------------------------------
 
    signal clk_s: std_logic;
    signal reset_s: std_logic;

------------------ Ports for BRAM Initialization -----------------

-- Input BRAM port
signal tb_a_en_i : std_logic;
signal tb_a_addr_i : std_logic_vector(PIXEL_SIZE-1 downto 0);
signal tb_a_data_i : std_logic_vector(FIXED_SIZE-1 downto 0);
signal tb_a_we_i : std_logic;

-- Output BRAM port
signal tb_c_en_i : std_logic;
signal tb_c_addr_i : std_logic_vector(7 downto 0);
signal tb_c_data_o : std_logic_vector(FIXED_SIZE - 1 downto 0);
signal tb_c_we_i : std_logic;

------------------------- Ports to IP ---------------------

signal ip_a_en : std_logic;
signal ip_a_we : std_logic;
signal ip_a_addr : std_logic_vector(PIXEL_SIZE-1 downto 0);
signal ip_a_data: std_logic_vector(FIXED_SIZE-1 downto 0);

signal ip_c_en : std_logic;
signal ip_c_we : std_logic;
signal ip_c_addr : std_logic_vector(7 downto 0);
signal ip_c_data: std_logic_vector(FIXED_SIZE - 1 downto 0);

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
    variable tv_slika  : line;
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
    
    
-- Slanje gornjih 32 bita (FRACR_UPPER_C)
wait until falling_edge(clk_s);
s00_axi_awaddr_s <= std_logic_vector(to_unsigned(FRACR_UPPER_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
s00_axi_awvalid_s <= '1';
s00_axi_wdata_s <= FRACR_UPPER_C;  -- Salje prvih 32 bita
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

-- Slanje donjih 16 bita (FRACR_LOWER_C), smestenih u donji deo 32-bitne širine
wait until falling_edge(clk_s);
s00_axi_awaddr_s <= std_logic_vector(to_unsigned(FRACR_LOWER_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
s00_axi_awvalid_s <= '1';
s00_axi_wdata_s <= std_logic_vector(to_unsigned(0,16)) & FRACR_LOWER_C;  -- Gornjih 16 bita nule, donjih 16 bita nasa vrednost
s00_axi_wvalid_s <= '1';
s00_axi_wstrb_s <= "0011";  -- Oznaka da su validni samo donji 2 bajta
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
    
     -- Slanje gornjih 32 bita (FRACC_UPPER_C)
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(FRACC_UPPER_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= FRACC_UPPER_C;  -- Salje prvih 32 bita
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
    
    -- Slanje donjih 16 bita (FRACC_LOWER_C), smestenih u donji deo 32-bitne širine
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(FRACC_LOWER_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0,16)) & FRACC_LOWER_C;  -- Gornjih 16 bita nule, donjih 16 bita nasa vrednost
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "0011";  -- Oznaka da su validni samo donji 2 bajta, odnosno 
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
    
        -- Slanje gornjih 32 bita (SPACING_UPPER_C)
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(SPACING_UPPER_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= SPACING_UPPER_C;  -- Salje prvih 32 bita
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awvalid_s <= '0';
    s00_axi_wvalid_s <= '0';
    s00_axi_bready_s <= '0';
    
    -- Slanje donjih 16 bita (SPACING_LOWER_C), smestenih u donji deo 32-bitne širine
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(SPACING_LOWER_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0,16)) & SPACING_LOWER_C;  -- Gornjih 16 bita nule, donjih 16 bita nasa vrednost
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "0011";  -- Oznaka da su validni samo donji 2 bajta, odnosno 
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
   
    
         -- Slanje gornjih 32 bita (I_COSE_UPPER_C)
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(I_COSE_UPPER_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= I_COSE_UPPER_C;  -- Salje prvih 32 bita
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awvalid_s <= '0';
    s00_axi_wvalid_s <= '0';
    s00_axi_bready_s <= '0';
    
    -- Slanje donjih 16 bita (I_COSE_LOWER_C), smestenih u donji deo 32-bitne širine
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(I_COSE_LOWER_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0,16)) & I_COSE_LOWER_C;  -- Gornjih 16 bita nule, donjih 16 bita nasa vrednost
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "0011";  -- Oznaka da su validni samo donji 2 bajta, odnosno 
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
    
             -- Slanje gornjih 32 bita (I_SINE_UPPER_C)
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(I_SINE_UPPER_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= I_SINE_UPPER_C;  -- Salje prvih 32 bita
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awvalid_s <= '0';
    s00_axi_wvalid_s <= '0';
    s00_axi_bready_s <= '0';
    
    -- Slanje donjih 16 bita (I_SINE_LOWER_C), smestenih u donji deo 32-bitne širine
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(I_SINE_LOWER_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= std_logic_vector(to_unsigned(0,16)) & I_SINE_LOWER_C;  -- Gornjih 16 bita nule, donjih 16 bita nasa vrednost
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "0011";  -- Oznaka da su validni samo donji 2 bajta, odnosno 
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
    s00_axi_wstrb_s <= "1111";     ----- VALJDA JE NAPISANO U SURF_V1_0_S00 NA KRAJU FAJLA DA SE UZIMA DONJIH 11 BITA PA MOZDA OVO NIJE BITNO
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
    s00_axi_wstrb_s <= "1111";     ----- VALJDA JE NAPISANO U SURF_V1_0_S00 NA KRAJU FAJLA DA SE UZIMA DONJIH 11 BITA PA MOZDA OVO NIJE BITNO
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
    s00_axi_wstrb_s <= "1111";     ----- VALJDA JE NAPISANO U SURF_V1_0_S00 NA KRAJU FAJLA DA SE UZIMA DONJIH 11 BITA PA MOZDA OVO NIJE BITNO
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
    s00_axi_wstrb_s <= "1111";     ----- VALJDA JE NAPISANO U SURF_V1_0_S00 NA KRAJU FAJLA DA SE UZIMA DONJIH 11 BITA PA MOZDA OVO NIJE BITNO
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
    s00_axi_wstrb_s <= "1111";     ----- VALJDA JE NAPISANO U SURF_V1_0_S00 NA KRAJU FAJLA DA SE UZIMA DONJIH 11 BITA PA MOZDA OVO NIJE BITNO
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

    -- Load the picture into the memory
    report "Loading picture into the memory!";
    
    wait until falling_edge(clk_s);

    for i in 0 to (IMG_WIDTH*IMG_HEIGHT)-1 loop 
        wait until falling_edge(clk_s);
        readline(pixels1D, tv_slika);
        tb_a_en_i  <= '1';
        tb_a_addr_i <= std_logic_vector(to_unsigned(4*i, PIXEL_SIZE)); 
        tb_a_data_i <= to_std_logic_vector(string(tv_slika));
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
    -- Start the ip core --
    -------------------------------------------------------------------------------------------
    report "Starting proccesing!";
    -- Set the start bit (bit 0 in the START_ADDR_C register) to 1
    
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(START_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
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
    -- Set the start bit (bit 0 in the START_ADDR_C register) to 0
    
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= std_logic_vector(to_unsigned(START_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));
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
        s00_axi_araddr_s <= std_logic_vector(to_unsigned(READY_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c));     
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
    -- Read the output --
    -------------------------------------------------------------------------------------------
   report "Reading the results of from output memory!";

    for k in 0 to 4*INDEX_SIZE*INDEX_SIZE-1 loop
        wait until falling_edge(clk_s);
        tb_c_en_i <= '1';
        tb_c_we_i <= '0';
        tb_c_addr_i <= std_logic_vector(to_unsigned(k*4, 8));
        wait until falling_edge(clk_s);

    end loop;

    tb_c_en_i <= '0';
    report "Finished!";

    wait;
end process;

write_to_output_file : process(clk_s)
    variable data_output_line : line;
    variable data_output_string : string(1 to FIXED_SIZE) := (others => '0');
    variable prev_addr : std_logic_vector(7 downto 0) := (others => '1');  -- promenite po?etnu vrednost
    variable first_iteration : boolean := true;  -- signal za pra?enje prve iteracije
begin
    if falling_edge(clk_s) then
        if tb_c_en_i = '1' then
            -- Upiši samo ako je prva iteracija ili se adresa promenila
            if first_iteration or (tb_c_addr_i /= prev_addr) then
                prev_addr := tb_c_addr_i;  -- ažuriraj prethodnu adresu
                first_iteration := false;  -- postavi signal da prva iteracija više nije aktivna

                -- Pripremi podatke za upis
                data_output_string := (others => '0');
                for i in 0 to FIXED_SIZE - 1 loop
                    if tb_c_data_o(i) = '1' then
                        data_output_string(FIXED_SIZE - i) := '1';  
                    else
                        data_output_string(FIXED_SIZE - i) := '0';  
                    end if;
                end loop;

                -- Upis podataka u izlazni fajl
                write(data_output_line, data_output_string);
                writeline(izlaz, data_output_line);
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
        IMG_WIDTH => IMG_WIDTH,
        IMG_HEIGHT => IMG_HEIGHT
    )
    port map (
    
     -- Interfejs za sliku
        ena     => ip_a_en,
        wea     => open,
        addra   => ip_a_addr,
        dina => open,
        douta => ip_a_data,
        reseta   => open,
        clka     => open,
    
      -- Interfejs za izlaz
        
        enc     => open,
        wec     => ip_c_we,
        addrc   => ip_c_addr,
        dinc => ip_c_data,
        doutc   =>(others=>'0'),
        resetc  => open,
        clkc    => open,
        
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


-- Instantiation of input BRAM
bram_in: entity work.bram(Behavioral)
  generic map (WIDTH =>48,
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
    

-- Instantiation of output BRAM
bram_out: entity work.bram_out
    generic map (
        WIDTH => 48,  -- data width
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

end Behavioral;
