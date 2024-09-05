library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rom is
    generic (
        WIDTH: positive := 48;  -- Izmenjena sirina da odgovara formatu
        SIZE: positive := 40;   -- Broj lookup vrednosti
        SIZE_WIDTH: positive := 6  -- Log2(40) za adresiranje
    );
    port (
        clk_a : in std_logic;
        en_a : in std_logic;
        addr_a : in std_logic_vector(SIZE_WIDTH - 1 downto 0);
        data_a_o : out std_logic_vector(WIDTH - 1 downto 0)
    );
end rom;

architecture Behavioral of rom is
    type rom_type is array (0 to SIZE - 1) of std_logic_vector(WIDTH - 1 downto 0);
    signal ROM: rom_type := (
  
        b"000000000000000000000000000000111100000111110101", -- 0.939411163330078125    --0
		b"000000000000000000000000000000110101000011101101", -- 0.829029083251953125    --1
        b"000000000000000000000000000000101110110100101100", -- 0.7316131591796875      --2
        b"000000000000000000000000000000101001010100100100", -- 0.6456451416015625      --3 
        b"000000000000000000000000000000100100011101110101", -- 0.569782257080078125    --4
        b"000000000000000000000000000000100000001011100110", -- 0.50283050537109375     --5
        b"000000000000000000000000000000011100011001100101", -- 0.443744659423828125    --6
        b"000000000000000000000000000000011001000100000001", -- 0.391605377197265625    --7
        b"000000000000000000000000000000010110000111100010", -- 0.34558868408203125     --8
        b"000000000000000000000000000000010011100001001101", -- 0.304981231689453125    --9 
        b"000000000000000000000000000000010001001110011011", -- 0.269145965576171875    --10
        b"000000000000000000000000000000001111001100111000", -- 0.237518310546875       --11
        b"000000000000000000000000000000001101011010100100", -- 0.2096099853515625      --12
        b"000000000000000000000000000000001011110101101011", -- 0.184978485107421875    --13
        b"000000000000000000000000000000001010011100101001", -- 0.163242340087890625    --14
        b"000000000000000000000000000000001001001110000101", -- 0.144062042236328125    --15
        b"000000000000000000000000000000001000001000101111", -- 0.127132415771484375    --16
		b"000000000000000000000000000000000111001011100011", -- 0.112194061279296875    --17
        b"000000000000000000000000000000000110010101100011", -- 0.099010467529296875    --18
        b"000000000000000000000000000000000101100101111001", -- 0.087375640869140625    --19
        b"000000000000000000000000000000000100111011110110", -- 0.07711029052734375     --20
        b"000000000000000000000000000000000100010110101111", -- 0.068050384521484375    --21
        b"000000000000000000000000000000000011110101111110", -- 0.06005096435546875     --22
        b"000000000000000000000000000000000011011001000101", -- 0.052997589111328125    --23
        b"000000000000000000000000000000000010111111100100", -- 0.0467681884765625      --24
        b"000000000000000000000000000000000010101001000011", -- 0.041271209716796875    --25
        b"000000000000000000000000000000000010010101001100", -- 0.0364227294921875      --26
        b"000000000000000000000000000000000010000011101010", -- 0.03214263916015625     --27
        b"000000000000000000000000000000000001110100001100", -- 0.0283660888671875      --28
        b"000000000000000000000000000000000001100110100010", -- 0.02503204345703125     --29 
        b"000000000000000000000000000000000001011010011111", -- 0.022090911865234375    --30
        b"000000000000000000000000000000000001001111110110", -- 0.01949310302734375     --31
        b"000000000000000000000000000000000001000110011110", -- 0.01720428466796875     --32
        b"000000000000000000000000000000000000111110001100", -- 0.0151824951171875      --33
        b"000000000000000000000000000000000000110110111000", -- 0.013397216796875       --34
        b"000000000000000000000000000000000000110000011011", -- 0.011821746826171875    --35
        b"000000000000000000000000000000000000101010101111", -- 0.010433197021484375    --36
        b"000000000000000000000000000000000000100101101110", -- 0.00920867919921875     --37
        b"000000000000000000000000000000000000100001010010", -- 0.00812530517578125     --38
        b"000000000000000000000000000000000000011101011000"  -- 0.007171630859375       --39
    );
    attribute ram_style : string;
    attribute ram_style of ROM : signal is "block";

begin
    process(clk_a)
    begin
        if rising_edge(clk_a) then
            if en_a = '1' then
                data_a_o <= ROM(to_integer(unsigned(addr_a)));
            end if;
        end if;
    end process;
end Behavioral;

