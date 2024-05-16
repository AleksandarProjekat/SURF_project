library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rom is
    generic (WIDTH: positive := 32;
             SIZE: positive := 40;  -- Match the number of lookup values
             SIZE_WIDTH: positive := 6);  -- Log2(40) rounded up for addressing
    port (
        clk_a : in std_logic;
        clk_b : in std_logic;
        en_a : in std_logic;
        en_b : in std_logic;
        addr_a : in std_logic_vector(SIZE_WIDTH - 1 downto 0);
        addr_b : in std_logic_vector(SIZE_WIDTH - 1 downto 0);
        data_a_o : out std_logic_vector(WIDTH - 1 downto 0);
        data_b_o : out std_logic_vector(WIDTH - 1 downto 0)
    );
end rom;

architecture Behavioral of rom is
    type rom_type is array (0 to SIZE - 1) of std_logic_vector(WIDTH - 1 downto 0);
    signal ROM: rom_type := (
        X"783EAFEF", X"6A1DA04B", X"5DA594B7", X"52A49C64", X"48EEA4C3", X"405CC8FF", 
        X"38CCB63C", X"32202217", X"2C3C515A", X"2709ACE4", X"22736336", X"1E67150B", 
        X"1AD48BC2", X"17AD7873", X"14E53A9C", X"1270AD90", X"1045FBD3", X"0E5C77BB", 
        X"0CAC78AB", X"0B2F3C65", X"09DECBFD", X"08B5E3F0", X"07AFDF11", X"06C8A3EF", 
        X"05FC946A", X"05487F33", X"04A99306", X"041D535C", X"03A18E7D", X"033454B1", 
        X"02D3F07D", X"027EDFD1", X"0233CDF9", X"01F18E48", X"01B71769", X"01837F31", 
        X"0155F6FA", X"012DC868", X"010A528A", X"00EB075A"
    );
    attribute ram_style : string;
    attribute ram_style of ROM : signal is "block";

begin
    process(clk_a, clk_b)
    begin
        if rising_edge(clk_a) then
            if en_a = '1' then
                data_a_o <= ROM(to_integer(unsigned(addr_a)));
            end if;
        end if;
        
        if rising_edge(clk_b) then
            if en_b = '1' then
                data_b_o <= ROM(to_integer(unsigned(addr_b)));
            end if;
        end if;
    end process;
end Behavioral;
