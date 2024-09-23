library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity delay is
    generic (
        DELAY_CYCLES : integer := 3;  -- Broj ciklusa kašnjenja
        SIGNAL_WIDTH : integer := 48  -- Širina signala
    );
    port (
        clk   : in  std_logic;  -- Ulazni klok signal
        rst   : in  std_logic;  -- Reset signal (sinhroni)
        din   : in  std_logic_vector(SIGNAL_WIDTH - 1 downto 0);  -- Ulazni signal
        dout  : out std_logic_vector(SIGNAL_WIDTH - 1 downto 0)   -- Izlazni signal
    );
end delay;

architecture Behavioral of delay is
    -- Definicija tipa za pipeline kašnjenja
    type pipeline_type is array (0 to DELAY_CYCLES-1) of std_logic_vector(SIGNAL_WIDTH - 1 downto 0);
    
    -- Signal za skladištenje pipeline vrednosti, bez inicijalizacije
    signal pipeline : pipeline_type;
    
begin
    -- Proces koji implementira kašnjenje signala
    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset pipeline signala
                pipeline <= (others => (others => '0'));
            else
                -- Pomeri sve vrednosti u pipeline-u za jedan korak
                pipeline(0) <= din;
                for i in 1 to DELAY_CYCLES-1 loop
                    pipeline(i) <= pipeline(i-1);
                end loop;
            end if;
        end if;
    end process;

    -- Izlazni signal dobija vrednost nakon DELAY_CYCLES
    dout <= pipeline(DELAY_CYCLES-1);
    
end Behavioral;

