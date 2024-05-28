library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dsp_unit_3 is
    generic (WIDTH1: natural := 11;
             WIDTH2: natural := 11;
             WIDTH3: natural := 11;
             WIDTH4: natural := 11
);
    port (clk: in std_logic;
          rst: in std_logic;
          u1_i: in std_logic_vector(WIDTH1 - 1 downto 0);
          u2_i: in std_logic_vector(WIDTH2 - 1 downto 0);
          u3_i: in std_logic_vector(WIDTH3 - 1 downto 0);
          u4_i: in std_logic_vector(WIDTH4 - 1 downto 0);

          res_o: out std_logic_vector(WIDTH1 + WIDTH2 - 1 downto 0));
end dsp_unit_3;

architecture Behavioral of dsp_unit_3 is
    attribute use_dsp : string;
    attribute use_dsp of Behavioral : architecture is "yes";
    
    signal u1_reg: std_logic_vector(WIDTH1 - 1 downto 0);
    signal u2_reg: std_logic_vector(WIDTH2 - 1 downto 0);
    signal u3_reg: std_logic_vector(WIDTH3 - 1 downto 0);
    signal u4_reg: std_logic_vector(WIDTH4 - 1 downto 0);

    signal mult1_reg, mult2_reg, sub_reg: std_logic_vector(WIDTH1 + WIDTH2 - 1 downto 0);
begin
    process(clk) is
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                u1_reg <= (others => '0');
                u2_reg <= (others => '0');
                u3_reg <= (others => '0');
                u4_reg <= (others => '0');
                mult1_reg <= (others => '0');
                mult2_reg <= (others => '0');
                sub_reg <= (others => '0');
            else
                    u1_reg <= u1_i;
                    u2_reg <= u2_i;
                    u3_reg <= u3_i;
                    u4_reg <= u4_i;
                    mult1_reg <= std_logic_vector(signed(u1_i) * signed(u2_i));
                    mult2_reg <= std_logic_vector(signed(u3_i) * signed(u4_i));
                    sub_reg <= std_logic_vector(signed(mult1_reg) - signed(mult2_reg));
               
            end if;
        end if;
    end process;
    res_o <= sub_reg;
end Behavioral;