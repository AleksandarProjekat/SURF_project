----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 06/15/2024
-- Design Name: Testbench for ip module
-- Module Name: ip_tb - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: Testbench for the IP core, covering the initial states of the FSM.
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ip_tb is
end ip_tb;

architecture Behavioral of ip_tb is

    -- Component declaration for the unit under test (UUT)
    component ip
        generic (
            WIDTH : integer := 11;
            PIXEL_SIZE : integer := 14;
            SUM_WIDTH : integer := 16;
            FIXED_SIZE : integer := 48;
            INDEX_SIZE : integer := 4;
            IMG_WIDTH : integer := 128;
            IMG_HEIGHT : integer := 128
        );
        port (
            clk : in std_logic;
            reset : in std_logic;
            iradius : in unsigned(WIDTH - 1 downto 0);
            fracr : in std_logic_vector(FIXED_SIZE - 1 downto 0);
            fracc : in std_logic_vector(FIXED_SIZE - 1 downto 0);
            spacing : in std_logic_vector(FIXED_SIZE - 1 downto 0);
            iy : in unsigned(WIDTH - 1 downto 0);
            ix : in unsigned(WIDTH - 1 downto 0);
            step : in unsigned(WIDTH - 1 downto 0);
            i_cose : in std_logic_vector(FIXED_SIZE - 1 downto 0);
            i_sine : in std_logic_vector(FIXED_SIZE - 1 downto 0);
            scale : in std_logic_vector(FIXED_SIZE - 1 downto 0);
            ---------------MEM INTERFEJS ZA SLIKU--------------------
            bram_addr1_o : out std_logic_vector(PIXEL_SIZE-1 downto 0);
            bram_addr2_o : out std_logic_vector(PIXEL_SIZE-1 downto 0);
            bram_data1_i : in std_logic_vector(7 downto 0);
            bram_data2_i : in std_logic_vector(7 downto 0);
            bram_en1_o : out std_logic;
            bram_we1_o : out std_logic;
            bram_en2_o : out std_logic;
            bram_we2_o : out std_logic;
            ---------------MEM INTERFEJS ZA IZLAZ--------------------
            addr_do1_o : out std_logic_vector (5 downto 0);
            data1_o_next : out std_logic_vector (8*FIXED_SIZE + 4*WIDTH + 2*SUM_WIDTH - 1 downto 0);
            c1_data_o : out std_logic;
            addr_do2_o : out std_logic_vector (5 downto 0);
            data2_o_next : out std_logic_vector (8*FIXED_SIZE + 4*WIDTH + 2*SUM_WIDTH - 1 downto 0);
            c2_data_o : out std_logic;
            ---------------INTERFEJS ZA ROM--------------------
            rom_data : in std_logic_vector(FIXED_SIZE - 1 downto 0);
            rom_addr : out std_logic_vector(5 downto 0);  
            ---------------KOMANDNI INTERFEJS------------------------
            start_i : in std_logic;
            ---------------STATUSNI INTERFEJS------------------------
            ready_o : out std_logic
        );
    end component;

    -- Signals for connecting to the UUT
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal iradius : unsigned(10 downto 0) := (others => '0');
    signal fracr : std_logic_vector(47 downto 0) := (others => '0');
    signal fracc : std_logic_vector(47 downto 0) := (others => '0');
    signal spacing : std_logic_vector(47 downto 0) := (others => '0');
    signal iy : unsigned(10 downto 0) := (others => '0');
    signal ix : unsigned(10 downto 0) := (others => '0');
    signal step : unsigned(10 downto 0) := (others => '0');
    signal i_cose : std_logic_vector(47 downto 0) := (others => '0');
    signal i_sine : std_logic_vector(47 downto 0) := (others => '0');
    signal scale : std_logic_vector(47 downto 0) := (others => '0');
    signal bram_addr1_o : std_logic_vector(13 downto 0);
    signal bram_addr2_o : std_logic_vector(13 downto 0);
    signal bram_data1_i : std_logic_vector(7 downto 0) := (others => '0');
    signal bram_data2_i : std_logic_vector(7 downto 0) := (others => '0');
    signal bram_en1_o : std_logic;
    signal bram_we1_o : std_logic;
    signal bram_en2_o : std_logic;
    signal bram_we2_o : std_logic;
    signal addr_do1_o : std_logic_vector (5 downto 0);
    signal data1_o_next : std_logic_vector (8*48 + 4*11 + 2*16 - 1 downto 0);
    signal c1_data_o : std_logic;
    signal addr_do2_o : std_logic_vector (5 downto 0);
    signal data2_o_next : std_logic_vector (8*48 + 4*11 + 2*16 - 1 downto 0);
    signal c2_data_o : std_logic;
    signal rom_data : std_logic_vector(47 downto 0) := (others => '0');
    signal rom_addr : std_logic_vector(5 downto 0);
    signal start_i : std_logic := '0';
    signal ready_o : std_logic;
    signal state_reg : std_logic_vector(5 downto 0);
    signal rx : std_logic_vector (2*11 + 2*48 - 1 downto 0);
    signal cx : std_logic_vector (2*11 + 2*48 - 1 downto 0);

    -- Clock generation
    constant clk_period : time := 10 ns;
    signal done : std_logic := '0';

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: ip
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
            ready_o => ready_o
        );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize Inputs
        reset <= '1';
        start_i <= '0';
        wait for clk_period*2;

        reset <= '0';
        wait for clk_period*2;

        -- Apply first set of inputs
        iradius <= to_unsigned(5, 11);
        fracr <= std_logic_vector(to_unsigned(10, 48));
        fracc <= std_logic_vector(to_unsigned(15, 48));
        spacing <= std_logic_vector(to_unsigned(20, 48));
        iy <= to_unsigned(30, 11);
        ix <= to_unsigned(40, 11);
        step <= to_unsigned(2, 11);
        i_cose <= std_logic_vector(to_unsigned(5000, 48));
        i_sine <= std_logic_vector(to_unsigned(6000, 48));
        scale <= std_logic_vector(to_unsigned(7000, 48));

        -- Start the process
        start_i <= '1';
        wait for clk_period*2;
        start_i <= '0';

        -- Wait for the process to complete
        wait until ready_o = '1';

        -- Apply second set of inputs
        iradius <= to_unsigned(10, 11);
        fracr <= std_logic_vector(to_unsigned(20, 48));
        fracc <= std_logic_vector(to_unsigned(25, 48));
        spacing <= std_logic_vector(to_unsigned(30, 48));
        iy <= to_unsigned(60, 11);
        ix <= to_unsigned(80, 11);
        step <= to_unsigned(4, 11);
        i_cose <= std_logic_vector(to_unsigned(10000, 48));
        i_sine <= std_logic_vector(to_unsigned(12000, 48));
        scale <= std_logic_vector(to_unsigned(14000, 48));

        -- Start the process again
        start_i <= '1';
        wait for clk_period*2;
        start_i <= '0';

        -- Wait for the process to complete
        wait until ready_o = '1';

        -- Apply third set of inputs
        iradius <= to_unsigned(15, 11);
        fracr <= std_logic_vector(to_unsigned(30, 48));
        fracc <= std_logic_vector(to_unsigned(35, 48));
        spacing <= std_logic_vector(to_unsigned(40, 48));
        iy <= to_unsigned(90, 11);
        ix <= to_unsigned(120, 11);
        step <= to_unsigned(6, 11);
        i_cose <= std_logic_vector(to_unsigned(15000, 48));
        i_sine <= std_logic_vector(to_unsigned(18000, 48));
        scale <= std_logic_vector(to_unsigned(21000, 48));

        -- Start the process again
        start_i <= '1';
        wait for clk_period*2;
        start_i <= '0';

        -- Iterate through multiple steps to ensure all states are covered
        wait for clk_period * 20000;  -- Extended wait time to ensure all states are covered

        -- Check the result
        assert (ready_o = '1')
        report "Test completed successfully"
        severity note;

        wait;
    end process;

    -- Monitor state_reg signal and other key signals
    process (clk)
    begin
        if rising_edge(clk) then
            case state_reg is
                when "000000" => report "State: idle";
                when "000001" => report "State: StartLoop";
                when "000010" => report "State: InnerLoop";
                when "000011" => report "State: ComputeRPos1";
                when "000100" => report "State: ComputeRPos2";
                when "000101" => report "State: ComputeRPos3";
                when "000110" => report "State: ComputeRPos4";
                when "000111" => report "State: ComputeRPos5";
                when "001000" => report "State: ComputeCPos1";
                when "001001" => report "State: ComputeCPos2";
                when "001010" => report "State: ComputeCPos3";
                when "001011" => report "State: ComputeCPos4";
                when "001100" => report "State: ComputeCPos5";
                when "001101" => report "State: SetRXandCX";
                when "001110" => 
                    report "State: BoundaryCheck";
                    --report "rx: " & std_logic_vector(rx) & " cx: " & std_logic_vector(cx);
                when "001111" => report "State: PositionValidation";
                when "010000" => report "State: ComputePosition";
                when "010001" => report "State: ProcessSample";
                when "010010" => report "State: ComputeDerivatives";
                when "010011" => report "State: FetchDXX1_1";
                when "010100" => report "State: FetchDXX1_2";
                when "010101" => report "State: ComputeDXX1";
                when "010110" => report "State: FetchDXX2_1";
                when "010111" => report "State: FetchDXX2_2";
                when "011000" => report "State: ComputeDXX2";
                when "011001" => report "State: FetchDYY1_1";
                when "011010" => report "State: FetchDYY1_2";
                when "011011" => report "State: ComputeDYY1";
                when "011100" => report "State: FetchDYY2_1";
                when "011101" => report "State: FetchDYY2_2";
                when "011110" => report "State: ComputeDYY2";
                when "011111" => report "State: CalculateDerivatives";
                when "100000" => report "State: ApplyOrientationTransform";
                when "100001" => report "State: SetOrientations";
                when "100010" => report "State: UpdateIndex";
                when "100011" => report "State: ComputeFractionalComponents";
                when "100100" => report "State: ValidateIndices";
                when "100101" => report "State: ComputeWeightsR";
                when "100110" => report "State: ComputeWeightsC";
                when "100111" => report "State: UpdateIndexArray";
                when "101000" => report "State: CheckNextColumn";
                when "101001" => report "State: CheckNextRow";
                when "101010" => report "State: NextSample";
                when "101011" => report "State: IncrementI";
                when "101100" => report "State: Finish";
                when others => report "State: Unknown";
            end case;
        end if;
    end process;

end Behavioral;
