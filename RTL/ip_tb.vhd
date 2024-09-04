library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use std.env.all;  -- Dodali smo ovu biblioteku za koriš?enje std.env.stop
use work.txt_util.all;

entity tb_ip is
end tb_ip;

architecture Behavioral of tb_ip is

file pixels1D : text open read_mode is "C:\Users\coa\Desktop\pixels1D.txt";
file index1Dbin : text open read_mode is "C:\Users\coa\Desktop\index1Dbin.txt";
file izlaz : text open write_mode is "C:\Users\coa\Desktop\izlaz.txt";

-- Constants
constant WIDTH : integer := 11;
constant PIXEL_SIZE : integer := 15;
constant INDEX_ADDRESS_SIZE : integer := 6;
constant FIXED_SIZE : integer := 48;
constant INDEX_SIZE : integer := 4;
constant IMG_WIDTH : integer := 129;
constant IMG_HEIGHT : integer := 129;

-- Test signals
signal clk_s : std_logic := '0';
signal reset_s : std_logic := '0';
signal iradius_s : unsigned(WIDTH - 1 downto 0) := (others => '0');
signal fracr_s : std_logic_vector(FIXED_SIZE - 1 downto 0) := (others => '0');
signal fracc_s : std_logic_vector(FIXED_SIZE - 1 downto 0) := (others => '0');
signal spacing_s : std_logic_vector(FIXED_SIZE - 1 downto 0) := (others => '0');
signal iy_s : unsigned(WIDTH - 1 downto 0) := (others => '0');
signal ix_s : unsigned(WIDTH - 1 downto 0) := (others => '0');
signal step_s : unsigned(WIDTH - 1 downto 0) := (others => '0');
signal i_cose_s : std_logic_vector(FIXED_SIZE - 1 downto 0) := (others => '0');
signal i_sine_s : std_logic_vector(FIXED_SIZE - 1 downto 0) := (others => '0');
signal scale_s : unsigned(WIDTH - 1 downto 0) := (others => '0');

signal bram_addr1_o_s : std_logic_vector(PIXEL_SIZE-1 downto 0);
signal bram_data_i_s : std_logic_vector(FIXED_SIZE-1 downto 0) := (others => '0');
signal bram_en1_o_s : std_logic;

signal addr_do1_o_s : std_logic_vector(5 downto 0);
signal data1_o_s : std_logic_vector(FIXED_SIZE - 1 downto 0);
signal c1_data_o_s : std_logic;
signal bram_we1_o_s : std_logic;

signal rom_data_s : std_logic_vector(FIXED_SIZE - 1 downto 0) := (others => '0');
signal rom_addr_s : std_logic_vector(5 downto 0);

signal start_i_s : std_logic := '0';
signal ready_o_s : std_logic;
signal done_s : std_logic := '0';
signal rom_data_a_s : std_logic_vector(FIXED_SIZE - 1 downto 0);
signal rom_en_a_s : std_logic := '0';

-- Clock period definition
constant clk_period : time := 10 ns;

------------------ Ports for BRAM Initialization -----------------

-- Input BRAM port
signal tb_a_en_i : std_logic;
signal tb_a_addr_i : std_logic_vector(PIXEL_SIZE-1 downto 0);
signal tb_a_data_i : std_logic_vector(FIXED_SIZE-1 downto 0);
signal tb_a_we_i : std_logic;

-- Output BRAM port
signal tb_c_en_i : std_logic;
signal tb_c_addr_i : std_logic_vector(5 downto 0);
signal tb_c_data_o : std_logic_vector(FIXED_SIZE - 1 downto 0);
signal tb_c_we_i : std_logic;

------------------------- Ports to IP ---------------------

signal ip_a_en : std_logic;
signal ip_a_we : std_logic;
signal ip_a_addr : std_logic_vector(PIXEL_SIZE-1 downto 0);
signal ip_a_data: std_logic_vector(FIXED_SIZE-1 downto 0);

signal ip_c_en : std_logic;
signal ip_c_we : std_logic;
signal ip_c_addr : std_logic_vector(5 downto 0);
signal ip_c_data: std_logic_vector(FIXED_SIZE - 1 downto 0);

begin

-- Clock generation process
clk_gen: process is
begin
    clk_s <= '0', '1' after 10 ns;
    wait for 20 ns;
end process;

stimulus_generator: process
variable tv_slika : line;
begin
    report "Start !";
    
    -- Reset signal
    reset_s <= '1';
    wait for 5*20 ns; -- wait for 5 clock cycles
    reset_s <= '0';
    wait for 5*20 ns; -- wait for 5 clock cycles
        
    -- Initialize the core --
    report "Loading the picture dimensions into the core!";
    
    -- Load the picture into the memory
    report "Loading picture into the memory!";
    for i in 0 to (IMG_WIDTH*IMG_HEIGHT)-1 loop 
        wait until falling_edge(clk_s);
        readline(pixels1D, tv_slika);
        tb_a_en_i  <= '1';
        tb_a_addr_i <= std_logic_vector(to_unsigned(i, PIXEL_SIZE)); 
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
    
    -- Initialize the core
    report "Initializing the core!";
    
    -- Iteration 0 
    iradius_s <= to_unsigned(24, WIDTH);
    fracr_s <= "000000000000000000000000000000000100010101100110";  --0.06777191162109375
    fracc_s <= "000000000000000000000000000000000100000110010011";   --0.06403732299804688
    spacing_s <= "000000000000000000000000000000000100101010000000";  --0.0727539062
    iy_s <= to_unsigned(32, WIDTH);
    ix_s <= to_unsigned(45, WIDTH);
    step_s <= to_unsigned(2, WIDTH);
    i_cose_s <= "111111111111111111111111111111111101101111011100";   --  -0.0352935791015625
    i_sine_s <= "000000000000000000000000000000111111111101011100";   --   0.9993743896484375
    scale_s <= to_unsigned(4, WIDTH);
    rom_en_a_s <= '1';   

    -- Start the IP core processing
    report "Starting processing!";
    start_i_s <= '1';
    wait for clk_period * 2;
    start_i_s <= '0';

    -- Wait for processing to complete
    wait until ready_o_s = '1';
    report "Processing complete!";
    
    -- Read the output
    report "Reading the results from output memory!";
    for k in 0 to 4*INDEX_SIZE*INDEX_SIZE loop
        wait until falling_edge(clk_s);
        tb_c_en_i <= '1';
        tb_c_we_i <= '0';
        tb_c_addr_i <= std_logic_vector(to_unsigned(k, 6));
    end loop;

    tb_c_en_i <= '0';
    report "Finished!";

    wait;
end process;

write_to_output_file : process(clk_s)
    variable data_output_line : line;
    variable data_output_string : string(1 to FIXED_SIZE) := (others => '0'); 
begin
    if falling_edge(clk_s) then
        if tb_c_en_i = '1' then
            data_output_string := (others => '0');
            for i in 0 to FIXED_SIZE - 1 loop
                if tb_c_data_o(i) = '1' then
                    data_output_string(FIXED_SIZE - i) := '1';  
                else
                    data_output_string(FIXED_SIZE - i) := '0';  
                end if;
            end loop;

            write(data_output_line, data_output_string);
            writeline(izlaz, data_output_line);
        end if;
    end if;
end process;


-- Instantiation of IP
ip: entity work.ip(Behavioral)
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
        clk => clk_s,
        reset => reset_s,
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
        
        bram_addr1_o => ip_a_addr,
        bram_data_i => ip_a_data,
        bram_en1_o => ip_a_en,
    
        addr_do1_o => ip_c_addr,
        data1_o => ip_c_data,    
        c1_data_o => ip_c_en,
        bram_we1_o => ip_c_we,
        
        rom_data => rom_data_s,
        rom_addr => rom_addr_s,
        start_i => start_i_s,
        ready_o => ready_o_s,
        done => done_s
    );

-- Instantiation of ROM
rom: entity work.rom(Behavioral)
    generic map (
        WIDTH => FIXED_SIZE,
        SIZE => 40,
        SIZE_WIDTH => 6
    )
    port map (
        clk_a => clk_s,
        en_a => rom_en_a_s,
        addr_a => rom_addr_s,
        data_a_o => rom_data_s
    );

-- Instantiation of input BRAM
bram_in: entity work.bram
    generic map (
        WIDTH => FIXED_SIZE,  -- data width
        SIZE => IMG_WIDTH*IMG_HEIGHT,  -- memory depth
        SIZE_WIDTH => 15
    )
    port map (
        clk_a => clk_s,
        clk_b => clk_s,
        en_a => tb_a_en_i,
        we_a => tb_a_we_i,
        addr_a => tb_a_addr_i,
        data_a_i => tb_a_data_i,
        data_a_o => open,

        en_b => ip_a_en,
        we_b => ip_a_we,
        addr_b => ip_a_addr,
        data_b_i => (others => '0'),
        data_b_o => ip_a_data
    );

-- Instantiation of output BRAM
bram_out: entity work.bram_out
    generic map (
        WIDTH => 48,  -- data width
        SIZE => 64,  -- memory depth
        SIZE_WIDTH => INDEX_ADDRESS_SIZE
    )
    port map (
        clk_a => clk_s,
        clk_b => clk_s,
        en_a => ip_c_en, 
        we_a => ip_c_we, 
        addr_a => ip_c_addr, 
        data_a_i => ip_c_data, 
        data_a_o => open,

        en_b => tb_c_en_i,
        we_b => tb_c_we_i,
        addr_b => tb_c_addr_i,
        data_b_i => (others => '0'),
        data_b_o => tb_c_data_o
    );

end Behavioral;
