library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rom is
    generic (
        WIDTH: positive := 48;  -- Izmenjena sirina da odgovara formatu
        SIZE: positive := 40;   -- Broj lookup vrijednosti
        SIZE_WIDTH: positive := 6  -- Log2(40) za adresiranje
    );
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
        x"00003c1f5000",
        x"0000350ed000",
        x"00002ed2c000",
        x"000029524000",
        x"000024775000",
        x"0000202e6000",
        x"00001c665000",
        x"000019101000",
        x"0000161e2000",
        x"00001384d000",
        x"00001139b000",
        x"00000f338000",
        x"00000d6a4000",
        x"00000bd6b000",
        x"00000a729000",
        x"000009385000",
        x"00000822f000",
        x"0000072e3000",
        x"000006563000",
        x"000005979000",
        x"000004ef6000",
        x"0000045af000",
        x"000003d7e000",
        x"000003645000",
        x"000002fe4000",
        x"000002a43000",
        x"00000254c000",
        x"0000020ea000",
        x"000001d0c000",
        x"0000019a2000",
        x"00000169f000",
        x"0000013f6000",
        x"00000119e000",
        x"000000f8c000",
        x"000000db8000",
        x"000000c1b000",
        x"000000aaf000",
        x"00000096e000",
        x"000000852000",
        x"000000758000"
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
