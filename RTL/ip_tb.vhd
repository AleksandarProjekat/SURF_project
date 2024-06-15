library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ip_pkg.all;  -- Dodajte ovu liniju

entity tb_ip is
end tb_ip;

architecture Behavioral of tb_ip is

    -- Constants
    constant WIDTH : integer := 11;
    constant PIXEL_SIZE : integer := 14;
    constant SUM_WIDTH : integer := 16;
    constant FIXED_SIZE : integer := 48;
    constant INDEX_SIZE : integer := 4;
    constant IMG_WIDTH : integer := 128;
    constant IMG_HEIGHT : integer := 128;

    -- Signals
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal iradius : unsigned(WIDTH - 1 downto 0) := (others => '0');
    signal fracr : std_logic_vector(FIXED_SIZE - 1 downto 0) := (others => '0');
    signal fracc : std_logic_vector(FIXED_SIZE - 1 downto 0) := (others => '0');
    signal spacing : std_logic_vector(FIXED_SIZE - 1 downto 0) := (others => '0');
    signal iy : unsigned(WIDTH - 1 downto 0) := (others => '0');
    signal ix : unsigned(WIDTH - 1 downto 0) := (others => '0');
    signal step : unsigned(WIDTH - 1 downto 0) := (others => '0');
    signal i_cose : std_logic_vector(FIXED_SIZE - 1 downto 0) := (others => '0');
    signal i_sine : std_logic_vector(FIXED_SIZE - 1 downto 0) := (others => '0');
    signal scale : std_logic_vector(FIXED_SIZE - 1 downto 0) := (others => '0');
    signal bram_addr1_o : std_logic_vector(PIXEL_SIZE-1 downto 0);
    signal bram_addr2_o : std_logic_vector(PIXEL_SIZE-1 downto 0);
    signal bram_data1_i : std_logic_vector(7 downto 0) := (others => '0');
    signal bram_data2_i : std_logic_vector(7 downto 0) := (others => '0');
    signal bram_en1_o : std_logic;
    signal bram_we1_o : std_logic;
    signal bram_en2_o : std_logic;
    signal bram_we2_o : std_logic;
    signal addr_do1_o : std_logic_vector (5 downto 0);
    signal data1_o_next : std_logic_vector (8*FIXED_SIZE + 4*WIDTH + 2*SUM_WIDTH - 1 downto 0);
    signal c1_data_o : std_logic;
    signal addr_do2_o : std_logic_vector (5 downto 0);
    signal data2_o_next : std_logic_vector (8*FIXED_SIZE + 4*WIDTH + 2*SUM_WIDTH - 1 downto 0);
    signal c2_data_o : std_logic;
    signal rom_data : std_logic_vector(FIXED_SIZE - 1 downto 0) := (others => '0');
    signal rom_addr : std_logic_vector(5 downto 0);
    signal start_i : std_logic := '0';
    signal ready_o : std_logic;
    signal state_o : state_type;

    -- Clock generation
    constant clk_period : time := 10 ns;
    begin
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.ip
        generic map (
            WIDTH => 11,
            PIXEL_SIZE => 14,
            SUM_WIDTH => 16,
            FIXED_SIZE => 48,
            INDEX_SIZE => 4,
            IMG_WIDTH => 128,
            IMG_HEIGHT => 128
        )
        port map (
            clk => clk,
            reset => reset,
            iradius => iradius,
            fracr => fracr,
            fracc => fracc,
            spacing => spacing,
            iy => iy,
            ix => ix,
            step => step,
            i_cose => i_cose,
            i_sine => i_sine,
            scale => scale,
            bram_addr1_o => bram_addr1_o,
            bram_addr2_o => bram_addr2_o,
            bram_data1_i => bram_data1_i,
            bram_data2_i => bram_data2_i,
            bram_en1_o => bram_en1_o,
            bram_we1_o => bram_we1_o,
            bram_en2_o => bram_en2_o,
            bram_we2_o => bram_we2_o,
            addr_do1_o => addr_do1_o,
            data1_o_next => data1_o_next,
            c1_data_o => c1_data_o,
            addr_do2_o => addr_do2_o,
            data2_o_next => data2_o_next,
            c2_data_o => c2_data_o,
            rom_data => rom_data,
            rom_addr => rom_addr,
            start_i => start_i,
            ready_o => ready_o,
            state_o => state_o
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- hold reset state for 100 ns.
        wait for 100 ns;
        reset <= '0';

        -- Initialize Inputs
        iradius <= to_unsigned(2, WIDTH);
        fracr <= std_logic_vector(to_signed(1, FIXED_SIZE));
        fracc <= std_logic_vector(to_signed(1, FIXED_SIZE));
        spacing <= std_logic_vector(to_signed(1, FIXED_SIZE));
        iy <= to_unsigned(10, WIDTH);
        ix <= to_unsigned(10, WIDTH);
        step <= to_unsigned(1, WIDTH);
        i_cose <= std_logic_vector(to_signed(1, FIXED_SIZE));
        i_sine <= std_logic_vector(to_signed(1, FIXED_SIZE));
        scale <= std_logic_vector(to_signed(1, FIXED_SIZE));
        bram_data1_i <= x"FF"; -- Example data
        bram_data2_i <= x"FF"; -- Example data
        rom_data <= std_logic_vector(to_signed(1, FIXED_SIZE)); -- Example data
        
        -- Apply stimulus
        wait for 20 ns;
        start_i <= '1';
        wait for clk_period;
        start_i <= '0';
        
        -- Wait for the processing to complete
        wait until ready_o = '1';

        -- Wait for global reset to finish
        wait;
    end process;

    -- Process to monitor state changes and print them
    monitor_proc: process(clk)
    begin
        if rising_edge(clk) then
            report "Current state: " & state_to_string(state_o);
        end if;
    end process;

end Behavioral;
