library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;


--use work.ip_pkg.all;  
use std.textio.all;
use work.txt_util.all;

entity tb_ip is
end tb_ip;

architecture Behavioral of tb_ip is

file pixels1D : text open read_mode is
	"C:\Users\coa\Desktop\pixels1D.txt";
	file index1Dbin : text open read_mode is
	"C:\Users\coa\Desktop\index1Dbin.txt";
	file izlaz : text open write_mode is "C:\Users\coa\Desktop\izlaz.txt";

    -- Constants
    constant WIDTH : integer := 11;
    constant PIXEL_SIZE : integer := 15;
    constant INDEX_ADDRESS_SIZE : integer := 6;
    constant FIXED_SIZE : integer := 48;
    constant INDEX_SIZE : integer := 4;
    constant IMG_WIDTH : integer := 129;
    constant IMG_HEIGHT : integer := 129;
    
   
    -- Signali za testiranje
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
    signal scale_s : std_logic_vector(FIXED_SIZE - 1 downto 0) := (others => '0');
    
    signal bram_addr1_o_s : std_logic_vector(PIXEL_SIZE-1 downto 0);
    signal bram_data_i_s : std_logic_vector(FIXED_SIZE-1 downto 0) := (others => '0');
    signal bram_en1_o_s : std_logic;
    
    signal addr_do1_o_s : std_logic_vector (5 downto 0);
    signal data1_o_s : std_logic_vector (10*FIXED_SIZE + 4*WIDTH- 1 downto 0);
    signal c1_data_o_s : std_logic;
    signal bram_we1_o_s : std_logic;
    
    signal rom_data_s : std_logic_vector(FIXED_SIZE - 1 downto 0) := (others => '0');
    signal rom_addr_s : std_logic_vector(5 downto 0);
    
    signal start_i_s : std_logic := '0';
    signal ready_o_s : std_logic;
    signal rom_data_a_s : std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal rom_en_a_s : std_logic := '0';

    -- Clock period definition
    constant clk_period : time := 10 ns;

 ------------------Ports for BRAM Initialization-----------------
 
    --ulazni bram port
    signal tb_a_en_i : std_logic;
    signal tb_a_addr_i : std_logic_vector(PIXEL_SIZE-1 downto 0);
    signal tb_a_data_i : std_logic_vector(FIXED_SIZE-1 downto 0);
    signal tb_a_we_i : std_logic;
    

    --izlazni bram
    signal tb_c_en_i : std_logic;
    signal tb_c_addr_i : std_logic_vector(5 downto 0);
    signal tb_c_data_o : std_logic_vector(10*FIXED_SIZE + 4*WIDTH - 1 downto 0);
    signal tb_c_we_i : std_logic;
    

    ------------------------- Ports to IP ---------------------
    
    signal ip_a_en : std_logic;
    signal ip_a_we : std_logic;
    signal ip_a_addr : std_logic_vector(PIXEL_SIZE-1 downto 0);
    signal ip_a_data: std_logic_vector(FIXED_SIZE-1 downto 0);
    
  
    signal ip_c_en : std_logic;
    signal ip_c_we : std_logic;
    signal ip_c_addr : std_logic_vector(5 downto 0);
    signal ip_c_data: std_logic_vector(10*FIXED_SIZE + 4*WIDTH - 1 downto 0);
    



begin

    -- Proces za generisanje taktnog signala
   clk_gen: process is
    begin
        clk_s <= '0', '1' after 10 ns;
        wait for 20 ns;
    end process;

 
    stimulus_generator: process
    variable tv_slika : line;
    begin
    report "Start !";
    
    -- reset signal
    reset_s <= '1';
    wait for 5*20 ns; -- wait for 5 clock cycles
    reset_s <= '0';
    wait for 5*20 ns; -- wait for 5 clock cycles
        
    -- Initialize the core --
    report "Loading the picture dimensions into the core!" ;   
    
   
   -- Load the picture into the memory
    report "Loading picture into the memory!" ;
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
    iradius_s <= to_unsigned(17, WIDTH); -- 17 je decimalna vrednost za iradius
    fracr_s <= "000000000000000000000000000000001010000011000010"; --  0.15699263069083616 u binarnom format
    fracc_s <= "000000000000000000000000000000011100110110110110"; --  0.45089018167010253 u binarnom formatu
    spacing_s <= "000000000000000000000000001001101011111000001110"; -- 9.685600969817237 u binarnom formatu
    iy_s <= to_unsigned(38, WIDTH); -- 38 je decimalna vrednost za iy
    ix_s <= to_unsigned(64, WIDTH); -- 64 je decimalna vrednost za ix
    step_s <= to_unsigned(2, WIDTH); -- 2 je decimalna vrednost za step
    i_cose_s <= "000000000000000000000000000000011011011001010001"; --  0.428043365478515625 u binarnom formatu
    i_sine_s <= "000000000000000000000000000000111001110101110010"; -- 0.90375518798828125 u binarnom formatu
    scale_s <= "000000000000000000000000000011001110101000000100"; -- 3.2285336566057454 u binarnom formatu
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
    report "RESULTS MATCH!";
    wait;

end process;

write_to_output_file : process(clk_s)
    variable data_output_line : line;
    variable data_output_string : string(1 to 10*FIXED_SIZE + 4*WIDTH) := (others => '0'); 
begin
    if falling_edge(clk_s) then
        if tb_c_en_i = '1' then
            data_output_string := (others => '0');
            for i in 0 to 10*FIXED_SIZE + 4*WIDTH - 1 loop
                if tb_c_data_o(i) = '1' then
                    data_output_string(10*FIXED_SIZE + 4*WIDTH - i) := '1';  
                else
                    data_output_string(10*FIXED_SIZE + 4*WIDTH - i) := '0';  
                end if;
            end loop;          
            write(data_output_line, data_output_string);
            writeline(izlaz, data_output_line);
        end if;
    end if;
end process;

checker : process(clk_s)
    variable tv_izlazi : line;  
    variable tmp: std_logic_vector(10*FIXED_SIZE + 4*WIDTH - 1 downto 0);
begin              
    if falling_edge (clk_s) then
        if tb_c_en_i  = '1' then
            readline(index1Dbin, tv_izlazi);
            tmp := to_std_logic_vector(string(tv_izlazi));
            if (tmp /= tb_c_data_o) then
                report "RESULT MISMATCH" severity failure;
            end if;
        end if;
    end if;
end process;
        
     -- Instanciranje IP-a
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
           bram_data_i =>ip_a_data,
           bram_en1_o => ip_a_en,
        
           addr_do1_o => ip_c_addr,
           data1_o => ip_c_data,    
           c1_data_o => ip_c_en,
           bram_we1_o => ip_c_we,
            
            rom_data => rom_data_s,
            rom_addr => rom_addr_s,
            start_i => start_i_s,
            ready_o => ready_o_s
        );
  
  -- Instanciranje ROM-a
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



-- Instanciranje BRAM-a za ulazne podatke
    bram_in: entity work.bram
        generic map (
            WIDTH => FIXED_SIZE,  -- ?irina podataka
            BRAM_SIZE => IMG_WIDTH*IMG_HEIGHT,  -- dubina memorije
            ADDR_WIDTH => 15
        )
        port map (
               clka => clk_s,
               clkb => clk_s,
	           reseta=> reset_s,
	           ena=>tb_a_en_i,
	           wea=> tb_a_we_i,
	           addra=> tb_a_addr_i,
	           dia=> tb_a_data_i,
	           doa=> open,
	
	           resetb=>reset_s,
	           enb=>ip_a_en,
	           web=>ip_a_we,
	           addrb=>ip_a_addr,
	           dib=>(others=>'0'),
	           dob=> ip_a_data
        );

    -- Instanciranje BRAM-a za izlazne podatke
     bram_out: entity work.bram_out
        generic map (
            WIDTH => 10*48 + 4*11,  -- sirina podataka
            BRAM_SIZE => IMG_WIDTH*IMG_HEIGHT,  -- dubina memorije
            ADDR_WIDTH => INDEX_ADDRESS_SIZE
        )
        port map (
               clka => clk_s,
               clkb => clk_s,
	           reseta=> reset_s,
	           ena=> ip_c_en, 
	           wea=> ip_c_we , 
	           addra=> ip_c_addr , 
	           dia=> ip_c_data , 
	           doa=> open,
	
	           resetb=>reset_s,
	           enb=> tb_c_en_i,
	           web=> tb_c_we_i,
	           addrb=> tb_c_addr_i,
	           dib=> (others=>'0'),
	           dob=> tb_c_data_o
        );

end Behavioral;