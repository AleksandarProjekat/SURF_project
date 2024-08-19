library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fifo_buffer is
    generic (
        FIXED_SIZE : integer := 48;
        DEPTH : integer := 4  -- Dubina bafera
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        data_in : in std_logic_vector(FIXED_SIZE - 1 downto 0);
        data_out : out std_logic_vector(FIXED_SIZE - 1 downto 0);
        wr_en : in std_logic;  -- Upisna kontrola
        rd_en : in std_logic;  -- ?itana kontrola
        empty : out std_logic;  -- Indikator praznog bafera
        full : out std_logic  -- Indikator punog bafera
    );
end fifo_buffer;

architecture Behavioral of fifo_buffer is
    type buffer_array is array(0 to DEPTH-1) of std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal fifo_buffer_array : buffer_array := (others => (others => '0'));
    signal rd_ptr, wr_ptr : integer range 0 to DEPTH-1 := 0;
    signal buffer_count : integer range 0 to DEPTH := 0;
    signal internal_empty, internal_full : std_logic;
begin
    process (clk, reset)
    begin
        if reset = '1' then
            rd_ptr <= 0;
            wr_ptr <= 0;
            buffer_count <= 0;
            internal_empty <= '1';
            internal_full <= '0';
            data_out <= (others => '0');
        elsif rising_edge(clk) then
            if wr_en = '1' and internal_full = '0' then
                fifo_buffer_array(wr_ptr) <= data_in;
                wr_ptr <= (wr_ptr + 1) mod DEPTH;
                buffer_count <= buffer_count + 1;
            end if;
            if rd_en = '1' and internal_empty = '0' then
                data_out <= fifo_buffer_array(rd_ptr);
                rd_ptr <= (rd_ptr + 1) mod DEPTH;
                buffer_count <= buffer_count - 1;
            end if;

            if buffer_count = 0 then
                internal_empty <= '1';
            else
                internal_empty <= '0';
            end if;

            if buffer_count = DEPTH then
                internal_full <= '1';
            else
                internal_full <= '0';
            end if;
        end if;
    end process;

    empty <= internal_empty;
    full <= internal_full;

end Behavioral;
