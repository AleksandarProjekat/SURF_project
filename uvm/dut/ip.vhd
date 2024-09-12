----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 04/16/2024 14:10:51 PM
-- Design Name:
-- Module Name: ip - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.ip_pkg.all; 

entity ip is
    generic (
        WIDTH : integer := 11;            -- Bit width for various unsigned signals
        PIXEL_SIZE : integer := 17;       -- 129 x 129 pixels
        INDEX_ADDRESS_SIZE : integer := 8;
        FIXED_SIZE : integer := 48;       -- Bit width for fixed-point operations
        BRAM_32_DATA : integer := 32;
        BRAM_16_DATA : integer := 16;
        INDEX_SIZE : integer := 4;        -- Dimension size for the index array
        IMG_WIDTH : integer := 129;       -- Width of the image
        IMG_HEIGHT : integer := 129       -- Height of the image
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        iradius : in std_logic_vector(WIDTH - 1 downto 0);
        fracr : in std_logic_vector(FIXED_SIZE - 1 downto 0);
        fracc : in std_logic_vector(FIXED_SIZE - 1 downto 0);
        spacing : in std_logic_vector(FIXED_SIZE - 1 downto 0);
        iy : in std_logic_vector(WIDTH - 1 downto 0);
        ix : in std_logic_vector(WIDTH - 1 downto 0);
        step : in std_logic_vector(WIDTH - 1 downto 0);
        i_cose : in std_logic_vector(FIXED_SIZE - 1 downto 0);
        i_sine : in std_logic_vector(FIXED_SIZE - 1 downto 0);
        scale : in std_logic_vector(WIDTH - 1 downto 0);
        ---------------MEM INTERFEJSI ZA SLIKU--------------------
        bram_addr1_o : out std_logic_vector(PIXEL_SIZE -1 downto 0);
        bram_addr2_o : out std_logic_vector(PIXEL_SIZE -1 downto 0);
        bram_data32_i : in std_logic_vector(BRAM_32_DATA -1 downto 0);
        bram_data16_i : in std_logic_vector(BRAM_16_DATA -1 downto 0);
        bram_en1_o : out std_logic;
        bram_en2_o : out std_logic;
        ---------------MEM INTERFEJSI ZA IZLAZ--------------------
        addr_do1_o : out std_logic_vector (7 downto 0);
        addr_do2_o : out std_logic_vector (7 downto 0);
        data32_o : out std_logic_vector (BRAM_32_DATA - 1 downto 0);          
        data16_o : out std_logic_vector (BRAM_16_DATA - 1 downto 0);          
        c1_data_o : out std_logic;
        bram_we1_o : out std_logic;
        c2_data_o : out std_logic;
        bram_we2_o : out std_logic;
        ---------------INTERFEJS ZA ROM--------------------
        rom_data : in std_logic_vector(FIXED_SIZE - 1 downto 0);
        rom_addr : out std_logic_vector(5 downto 0);  
        ---------------KOMANDNI INTERFEJS------------------------
        start_i : in std_logic;
        ---------------STATUSNI INTERFEJS------------------------
        ready_o : out std_logic
    );
end ip;

architecture Behavioral of ip is
    signal state_reg, state_next : state_type;

         component dsp1 is
      generic (
               WIDTH : integer := 11; 
               FIXED_SIZE : integer := 48
              -- ADD_SUB : string:= "add" 
              );
      port (
            clk : in  std_logic;   
            rst : in std_logic;
            u1_i : in std_logic_vector(WIDTH - 1 downto 0); 
            u2_i : in std_logic_vector(WIDTH - 1 downto 0); 
            u3_i : in std_logic_vector(FIXED_SIZE - 1 downto 0); 
            res_o : out std_logic_vector(FIXED_SIZE -1 downto 0)
           );
        end component;
        
         component dsp2 is
               generic (
          FIXED_SIZE : integer := 48
          );
    port (
          clk : in std_logic;
          rst : in std_logic;
          u1_i : in std_logic_vector(FIXED_SIZE - 1 downto 0);
          u2_i : in std_logic_vector(FIXED_SIZE - 1 downto 0); 
          ADD_SUB : in std_logic; 
          res_o : out std_logic_vector(FIXED_SIZE - 1 downto 0)
          );
        end component;
        
         component dsp3 is
      generic (
               WIDTH : integer := 11;  
               FIXED_SIZE : integer := 48  
              );
      port (
            clk : in  std_logic;    
            rst : in std_logic;
            u1_i : in std_logic_vector(WIDTH - 1 downto 0); 
            u2_i : in std_logic_vector (FIXED_SIZE -1 downto 0); 
            u3_i : in std_logic_vector(FIXED_SIZE - 1 downto 0); 
            res_o : out std_logic_vector(FIXED_SIZE -1 downto 0));
        end component;
        
         component dsp4 is
        generic ( 
              FIXED_SIZE : integer := 48);          
        port (clk: in std_logic;
              rst: in std_logic;
              u1_i: in std_logic_vector(FIXED_SIZE - 1 downto 0);
              spacing : in std_logic_vector(FIXED_SIZE - 1 downto 0);
              res_o: out std_logic_vector(FIXED_SIZE - 1 downto 0));
        end component;
        
         component dsp5 is
      generic ( 
               FIXED_SIZE : integer := 48
              );
      port (
            clk : in  std_logic; 
            rst : in std_logic;
            u1_i : in std_logic_vector(FIXED_SIZE - 1 downto 0); 
            u2_i : in std_logic_vector(FIXED_SIZE - 1 downto 0); 
            u3_i : in std_logic_vector(FIXED_SIZE - 1 downto 0); 
            res_o : out std_logic_vector(FIXED_SIZE -1 downto 0) 
           );
        end component;
        
             component dsp6 is
        generic (
              FIXED_SIZE : integer:= 48;
              WIDTH : integer:= 11
              );
        port (clk: in std_logic;
              rst: in std_logic;
              u1_i: in std_logic_vector(FIXED_SIZE - 1 downto 0); 
              u2_i: in std_logic_vector(WIDTH - 1 downto 0);
              ADD_SUB : in std_logic;
              res_o: out std_logic_vector(FIXED_SIZE - 1 downto 0));
        end component;
        
            component dsp7 is
          generic (
              WIDTH : integer := 11
                  );
          port (
                clk : in  std_logic;   
                rst : in std_logic;
                u1_i : in std_logic_vector(WIDTH - 1 downto 0); 
                u2_i : in std_logic_vector(WIDTH - 1 downto 0); 
                u3_i : in std_logic_vector(WIDTH - 1 downto 0); 
                u4_i : in std_logic_vector(WIDTH - 1 downto 0);
                res_o : out std_logic_vector(WIDTH -1 downto 0)
               );
        end component;
        
             component dsp8 is
         generic (
                   FIXED_SIZE : integer := 48
                  );
          port (
                clk : in  std_logic;     
                rst : in std_logic;
                u1_i : in std_logic_vector(FIXED_SIZE - 1 downto 0); 
                u2_i : in std_logic_vector(FIXED_SIZE - 1 downto 0); 
                u3_i : in std_logic_vector(FIXED_SIZE - 1 downto 0); 
                res_o : out std_logic_vector(FIXED_SIZE -1 downto 0) 
               );
        end component;        
        
        component rom
            generic (
                WIDTH: positive := 48;  
                SIZE: positive := 40;   
                SIZE_WIDTH: positive := 6  
            );
            port (
                clk_a : in std_logic;
                en_a : in std_logic;
                addr_a : in std_logic_vector(SIZE_WIDTH - 1 downto 0);
                data_a_o : out std_logic_vector(WIDTH - 1 downto 0)
            );
        end component;


 type state_type is (
            idle, StartLoop, InnerLoop, 
            ComputeRPos1, ComputeRPos2, ComputeRPos3, ComputeRPos4, ComputeRPos5,           
            SetRXandCX, BoundaryCheck, ComputePosition, ProcessSample,
            ComputeDerivatives,
            WaitForData1,WaitForData2,WaitForData3,WaitForData4,
            WaitForData5,WaitForData6,WaitForData7,WaitForData8,
            WaitForData9,WaitForData10,WaitForData11,WaitForData12,
            WaitForData13,WaitForData14,WaitForData15,WaitForData16,
            FetchDXX1_1, FetchDXX1_2, FetchDXX1_3, FetchDXX1_4, ComputeDXX1,
            FetchDXX2_1, FetchDXX2_2, FetchDXX2_3, FetchDXX2_4, ComputeDXX2, 
            FetchDYY1_1, FetchDYY1_2, FetchDYY1_3, FetchDYY1_4, ComputeDYY1,
            FetchDYY2_1, FetchDYY2_2, FetchDYY2_3, FetchDYY2_4, ComputeDYY2, 
        CalculateDerivatives, ApplyOrientationTransform_1, ApplyOrientationTransform,
        SetOrientations, UpdateIndex, ComputeFractionalComponents, ValidateRfrac, ValidateCfrac,
        ComputeWeightsR, ComputeWeightsC, UpdateIndexArray0, UpdateIndexArray1,
        NextSample, IncrementI, Finish
    );

    constant INDEX_SIZE_FP : std_logic_vector(FIXED_SIZE - 1 downto 0) := std_logic_vector(to_unsigned(8*131072, FIXED_SIZE));  -- 4.0
    constant HALF_INDEX_SIZE_FP : std_logic_vector(FIXED_SIZE - 1 downto 0) := std_logic_vector(to_unsigned(4*131072, FIXED_SIZE));  -- 2.0
    constant ONE_FP : std_logic_vector(FIXED_SIZE - 1 downto 0) := std_logic_vector(to_unsigned(2*131072, FIXED_SIZE));  -- 1.0
    constant HALF_FP : std_logic_vector(FIXED_SIZE - 1 downto 0) := std_logic_vector(to_unsigned(131072, FIXED_SIZE));  -- 0.5
    constant MINUS_ONE_FP : std_logic_vector(FIXED_SIZE - 1 downto 0) := std_logic_vector(to_signed(-2*131072, FIXED_SIZE));  -- -1.0

signal temp1_rpos_delayed, temp1_rpos_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);
signal temp2_rpos_delayed, temp2_rpos_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);
signal temp3_rpos_delayed, temp3_rpos_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);
signal temp4_rpos_delayed, temp4_rpos_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);
signal rpos_delayed, rpos_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);

signal temp1_cpos_delayed, temp1_cpos_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);
signal temp2_cpos_delayed, temp2_cpos_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);
signal temp3_cpos_delayed, temp3_cpos_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);
signal temp4_cpos_delayed, temp4_cpos_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);
signal cpos_delayed, cpos_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);

signal rx_delayed, rx_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);
signal cx_delayed, cx_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);

signal r_delayed, r_delayed1 : std_logic_vector(WIDTH - 1 downto 0);
signal c_delayed, c_delayed1 : std_logic_vector(WIDTH - 1 downto 0);


signal dxx_delayed, dxx_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);
signal dyy_delayed, dyy_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);

signal dx1_delayed, dx1_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);
signal dx2_delayed, dx2_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);

signal dy1_delayed, dy1_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);
signal dy2_delayed, dy2_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);

signal dx_delayed, dx_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);
signal dy_delayed, dy_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);

signal rfrac_delayed, rfrac_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);
signal cfrac_delayed, cfrac_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);

signal rweight1_delayed, rweight1_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);
signal rweight2_delayed, rweight2_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);

signal cweight1_delayed, cweight1_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);
signal cweight2_delayed, cweight2_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);

    signal i_reg, i_next : unsigned(WIDTH - 1 downto 0);
    signal j_reg, j_next : unsigned(WIDTH - 1 downto 0);
    signal neg_i_sine : std_logic_vector(FIXED_SIZE - 1 downto 0); 

    signal temp1_rpos_reg, temp1_rpos_next, temp2_rpos_reg, temp2_rpos_next : std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal temp3_rpos_reg, temp3_rpos_next, temp4_rpos_reg, temp4_rpos_next : std_logic_vector(FIXED_SIZE - 1 downto 0);
   
    signal temp1_cpos_reg, temp1_cpos_next, temp2_cpos_reg, temp2_cpos_next : std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal temp3_cpos_reg, temp3_cpos_next, temp4_cpos_reg, temp4_cpos_next : std_logic_vector(FIXED_SIZE - 1 downto 0);
    
    signal rpos_reg, cpos_reg : std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal rpos_next, cpos_next : std_logic_vector(FIXED_SIZE - 1 downto 0);
    
    signal rx, cx, rx_next, cx_next : std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal addSampleStep, addSampleStep_next : unsigned(WIDTH - 1 downto 0);
    
    signal r, c, r_next, c_next : signed(WIDTH - 1 downto 0);
    
    signal weight, weight_next : std_logic_vector(FIXED_SIZE - 1 downto 0);
    
    signal dxx1_sum_next, dxx2_sum_next, dyy1_sum_next, dyy2_sum_next : std_logic_vector(FIXED_SIZE - 1 downto 0); -- Accumulators for sum of BRAM data
    signal dxx1_sum_reg, dxx2_sum_reg, dyy1_sum_reg, dyy2_sum_reg : std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal dxx1, dxx2, dyy1, dyy2 : std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal dxx1_next, dxx2_next, dyy1_next, dyy2_next : std_logic_vector(FIXED_SIZE - 1 downto 0);

    signal dxx_reg, dyy_reg, dxx_next, dyy_next :  std_logic_vector(FIXED_SIZE -1 downto 0);
    
    signal dx1_reg, dx2_reg, dx1_next, dx2_next :  std_logic_vector(FIXED_SIZE- 1 downto 0);
    signal dx_reg, dx_next :  std_logic_vector(FIXED_SIZE- 1 downto 0);
    
    signal dy1_reg, dy2_reg, dy1_next, dy2_next :  std_logic_vector(FIXED_SIZE- 1 downto 0);
    signal dy_reg, dy_next :  std_logic_vector(FIXED_SIZE- 1 downto 0);
    
    signal ori1, ori2 : unsigned(WIDTH - 1 downto 0);
    signal ori1_next, ori2_next : unsigned(WIDTH - 1 downto 0);
    
    signal ri, ci, ri_next, ci_next : unsigned(WIDTH - 1 downto 0);
    
    signal rfrac, cfrac :  std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal rfrac_next, cfrac_next : std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal rfrac_mux_out, cfrac_mux_out : std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal rfrac_mux_next, cfrac_mux_next : std_logic_vector(FIXED_SIZE - 1 downto 0);

    signal rweight1, rweight2, rweight1_next, rweight2_next : std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal cweight1, cweight2, cweight1_next, cweight2_next : std_logic_vector(FIXED_SIZE - 1 downto 0);

    signal done : std_logic;

    -- Definisanje internog signala za kombinatornu logiku
    signal rom_data_reg : std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal rom_data_internal : std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal rom_enable : std_logic;
    signal rom_addr_int, rom_addr_next : std_logic_vector(5 downto 0);  -- Dodato za internu adresu
    
    signal rpos_squared_delayed, rpos_squared_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal cpos_squared_delayed, cpos_squared_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);
    
    signal rpos_squared_reg : std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal cpos_squared_reg : std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal rpos_squared_next : std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal cpos_squared_next : std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal rom_adress_delayed, rom_adress_delayed1 : std_logic_vector(FIXED_SIZE - 1 downto 0);

    -- Definisanje internog signala za adrese i podatke za ULAZNI bram
    signal bram_addr1_o_next, bram_addr2_o_next : std_logic_vector(PIXEL_SIZE-1 downto 0);

    -- Definisanje internog signala za adrese IZLAZNI bram
    signal bram2_phase : integer range 0 to 1 := 0;  -- Faza pristupa BRAM-u
    signal bram2_phase_next : integer range 0 to 1;  -- Pomocni signal za fazu pristupa BRAM-u   
    signal bram_addr1_int : std_logic_vector(INDEX_ADDRESS_SIZE-1 downto 0);
    signal bram_addr2_int : std_logic_vector(INDEX_ADDRESS_SIZE-1 downto 0);

    signal bram_en1_int : std_logic := '0';
    signal bram_we1_int : std_logic := '0';
    signal bram_en2_int : std_logic := '0';
    signal bram_we2_int : std_logic := '0';


signal counter, counter_next : integer range 0 to 3 := 0;


begin

    neg_i_sine <= std_logic_vector(-signed(i_sine));

-- rpos = (step * ((i_cose * (i - iradius)) + i_sine * (j - iradius))) - fracr) * spacing;
                --temp1= i_cose*(i-iradius)
                --temp2= i_sine*(j-iradius)
                --temp3 = temp1+temp2
                --temp4 = (step*temp3)-fracr 
                --rpos = temp4*spacing
                
    temp1_rpos_inc_dsp: dsp1
     generic map ( WIDTH => WIDTH,
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => std_logic_vector(i_reg),
             u2_i => std_logic_vector(iradius),
             u3_i => i_cose,
            res_o => temp1_rpos_delayed);
            
    delay_temp1_rpos: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => temp1_rpos_delayed,  -- Signal sa DSP-a
        dout => temp1_rpos_delayed1  -- Signal nakon kasnjenja
    ); 
            
      temp2_rpos_inc_dsp: dsp1
     generic map ( WIDTH => WIDTH,
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => std_logic_vector(j_reg),
             u2_i => std_logic_vector(iradius),
             u3_i => i_sine,
            res_o => temp2_rpos_delayed);  
            
delay_temp2_rpos: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => temp2_rpos_delayed,  -- Signal sa DSP-a
        dout => temp2_rpos_delayed1  -- Signal nakon kasnjenja
    ); 
      
     temp3_rpos_inc_dsp: dsp2
     generic map (
           FIXED_SIZE => FIXED_SIZE
            )
    port map(clk => clk,
             rst => reset,
             u1_i => temp1_rpos_delayed1,
             u2_i => temp2_rpos_delayed1,
            ADD_SUB => '0',  
            res_o => temp3_rpos_delayed);
            
       delay_temp3_rpos: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => temp3_rpos_delayed,  -- Signal sa DSP-a
        dout => temp3_rpos_delayed1  -- Signal nakon kasnjenja
    );      
      temp4_rpos_inc_dsp: dsp3
     generic map ( WIDTH => WIDTH,
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => std_logic_vector(step),
             u2_i => temp3_rpos_delayed1,
             u3_i => fracr,
            res_o => temp4_rpos_delayed);
            
     delay_temp4_rpos: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => temp4_rpos_delayed,  -- Signal sa DSP-a
        dout => temp4_rpos_delayed1  -- Signal nakon kasnjenja
    );      
            
      rpos_inc_dsp: dsp4
     generic map (
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => temp4_rpos_delayed1,
             spacing => spacing,
            res_o => rpos_delayed);  
               
     delay_rpos: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => rpos_delayed,  -- Signal sa DSP-a
        dout => rpos_delayed1 -- Signal nakon kasnjenja
        );  
        
            
 --cpos = (step * ((- i_sine * (i - iradius)) + i_cose * (j - iradius))) - fracc) * spacing;
          --temp1=  - i_sine*(i-iradius)
          --temp2= i_cose*(j-iradius)
          --temp3 = temp1+temp2
          --temp4 = (step*temp3)-fracc
          --cpos = temp4*spacing
          
     temp1_cpos_inc_dsp: dsp1
     generic map ( WIDTH => WIDTH,
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => std_logic_vector(i_reg),
             u2_i => std_logic_vector(iradius),
             u3_i => neg_i_sine,
            res_o => temp1_cpos_delayed);
            
     delay_temp1_cpos: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => temp1_cpos_delayed,  -- Signal sa DSP-a
        dout => temp1_cpos_delayed1  -- Signal nakon kasnjenja
    );       
     temp2_cpos_inc_dsp: dsp1
     generic map ( WIDTH => WIDTH,
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => std_logic_vector(j_reg),
             u2_i => std_logic_vector(iradius),
             u3_i => i_cose,
            res_o => temp2_cpos_delayed);
            
      delay_temp2_cpos: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => temp2_cpos_delayed,  -- Signal sa DSP-a
        dout => temp2_cpos_delayed1  -- Signal nakon kasnjenja
    );     
            
     temp3_cpos_inc_dsp: dsp2
     generic map (
           FIXED_SIZE => FIXED_SIZE
            )
    port map(clk => clk,
             rst => reset,
             u1_i => temp1_cpos_delayed1,
             u2_i => temp2_cpos_delayed1,
             ADD_SUB => '0',
            res_o => temp3_cpos_delayed);
            
     delay_temp3_cpos: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => temp3_cpos_delayed,  -- Signal sa DSP-a
        dout => temp3_cpos_delayed1  -- Signal nakon kasnjenja
    );     
            
      temp4_cpos_inc_dsp: dsp3
     generic map ( WIDTH => WIDTH,
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => std_logic_vector(step),
             u2_i => temp3_cpos_delayed1,
             u3_i => fracc,
            res_o => temp4_cpos_delayed);      
        
        delay_temp4_cpos: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => temp4_cpos_delayed,  -- Signal sa DSP-a
        dout => temp4_cpos_delayed1  -- Signal nakon kasnjenja
    );      
        
       cpos_inc_dsp: dsp4
     generic map (
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => temp4_cpos_delayed1,
             spacing => spacing,
            res_o => cpos_delayed); 
              
       delay_cpos: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => cpos_delayed,  -- Signal sa DSP-a
        dout => cpos_delayed1 -- Signal nakon kasnjenja
        );     
           
      rx_inc_dsp: dsp5
     generic map (
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => rpos_delayed1,
             u2_i => HALF_INDEX_SIZE_FP, --2.0
             u3_i => HALF_FP,   --0.5
            res_o => rx_delayed);
            
     delay_rx: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => rx_delayed,  -- Signal sa DSP-a
        dout => rx_delayed1 -- Signal nakon kasnjenja
        );             
      cx_inc_dsp: dsp5
     generic map (
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => cpos_delayed1,
             u2_i => HALF_INDEX_SIZE_FP, --2.0
             u3_i => HALF_FP,   --0.5
            res_o => cx_delayed);   
            
      delay_cx: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => cx_delayed,  -- Signal sa DSP-a
        dout => cx_delayed1 -- Signal nakon kasnjenja
        );    
     
      r_inc_dsp: dsp7
     generic map (
           WIDTH => WIDTH)
    port map(clk => clk,
             rst => reset,
             u1_i => std_logic_vector(i_reg),
             u2_i => std_logic_vector(iradius), 
             u3_i => std_logic_vector(step),   
             u4_i => std_logic_vector(iy),
            res_o => r_delayed);   
            
      delay_r: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => WIDTH
    )
    port map (
        clk => clk,
        rst => reset,
        din => r_delayed,  -- Signal sa DSP-a
        dout => r_delayed1 -- Signal nakon kasnjenja
        );  
          
      c_inc_dsp: dsp7
     generic map (
           WIDTH => WIDTH)
    port map(clk => clk,
             rst => reset,
             u1_i => std_logic_vector(j_reg),
             u2_i => std_logic_vector(iradius), 
             u3_i => std_logic_vector(step),   
             u4_i => std_logic_vector(ix),
            res_o => c_delayed);   
            
      delay_c: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => WIDTH
    )
    port map (
        clk => clk,
        rst => reset,
        din => c_delayed,  -- Signal sa DSP-a
        dout => c_delayed1 -- Signal nakon kasnjenja
        ); 
    
    --ZA GENERISANJE ADRESE ROM
   rpos_squared_inc_dsp: dsp4
     generic map (
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => rpos_reg,
             spacing => rpos_reg,
            res_o => rpos_squared_delayed);  
               
     delay_rpos_squared: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => rpos_squared_delayed,  -- Signal sa DSP-a
        dout => rpos_squared_delayed1 -- Signal nakon kasnjenja
        );
                   
    cpos_squared_inc_dsp: dsp4
     generic map (
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => cpos_reg,
             spacing => cpos_reg,
            res_o => cpos_squared_delayed);  
               
     delay_cpos_squared: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => cpos_squared_delayed,  -- Signal sa DSP-a
        dout => cpos_squared_delayed1 -- Signal nakon kasnjenja
        );     
              
    rom_adress_inc_dsp: dsp2
     generic map (
           FIXED_SIZE => FIXED_SIZE
            )
    port map(clk => clk,
             rst => reset,
             u1_i => rpos_squared_reg,
             u2_i => cpos_squared_reg,
            ADD_SUB => '0',  
            res_o => rom_adress_delayed);
            
       delay_rom_adress: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => rom_adress_delayed,  -- Signal sa DSP-a
        dout => rom_adress_delayed1  -- Signal nakon kasnjenja
    );      
          
        dxx_inc_dsp: dsp8
     generic map (
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => dxx1,
             u2_i => dxx2, 
             u3_i => weight,
            res_o => dxx_delayed);   
            
      delay_dxx: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => dxx_delayed,  -- Signal sa DSP-a
        dout => dxx_delayed1 -- Signal nakon kasnjenja
        );   
        
 dyy_inc_dsp: dsp8
     generic map (
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => dyy1,
             u2_i => dyy2, 
             u3_i => weight,
            res_o => dyy_delayed);   
            
      delay_dyy: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => dyy_delayed,  -- Signal sa DSP-a
        dout => dyy_delayed1 -- Signal nakon kasnjenja
        );  
                
    dx1_inc_dsp: dsp4
     generic map (
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => i_cose,
             spacing => dxx_delayed1,
            res_o => dx1_delayed);  
               
     delay_dx1: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => dx1_delayed,  -- Signal sa DSP-a
        dout => dx1_delayed1 -- Signal nakon kasnjenja
        );    
        
       dx2_inc_dsp: dsp4
     generic map (
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => i_sine,
             spacing => dyy_delayed1,
            res_o => dx2_delayed);  
               
     delay_dx2: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => dx2_delayed,  -- Signal sa DSP-a
        dout => dx2_delayed1 -- Signal nakon kasnjenja
        );           
        
         dx_inc_dsp: dsp2
     generic map (
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => dx1_delayed1,
             u2_i => dx2_delayed1,
             ADD_SUB => '0',
            res_o => dx_delayed);  
               
     delay_dx: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => dx_delayed,  -- Signal sa DSP-a
        dout => dx_delayed1 -- Signal nakon kasnjenja
        );    
        
            dy1_inc_dsp: dsp4
     generic map (
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => i_sine,
             spacing => dxx_delayed1,
            res_o => dy1_delayed);  
               
     delay_dy1: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => dy1_delayed,  -- Signal sa DSP-a
        dout => dy1_delayed1 -- Signal nakon kasnjenja
        );    
        
       dy2_inc_dsp: dsp4
     generic map (
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => i_cose,
             spacing => dyy_delayed1,
            res_o => dy2_delayed);  
               
     delay_dy2: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => dy2_delayed,  -- Signal sa DSP-a
        dout => dy2_delayed1 -- Signal nakon kasnjenja
        );           
        
         dy_inc_dsp: dsp2
     generic map (
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => dy1_delayed1,
             u2_i => dy2_delayed1,
             ADD_SUB => '1',
            res_o => dy_delayed);  
               
     delay_dy: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => dy_delayed,  -- Signal sa DSP-a
        dout => dy_delayed1 -- Signal nakon kasnjenja
        ); 
          
    rfrac_inc_dsp: dsp6
     generic map (
           FIXED_SIZE => FIXED_SIZE,
           WIDTH => WIDTH)
    port map(clk => clk,
             rst => reset,
             u1_i => rx_delayed1,
             u2_i => std_logic_vector(ri),
             ADD_SUB => '1',
            res_o => rfrac_delayed);  
               
     delay_rfrac: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => rfrac_delayed,  -- Signal sa DSP-a
        dout => rfrac_delayed1 -- Signal nakon kasnjenja
        );   
        
        cfrac_inc_dsp: dsp6
     generic map (
           FIXED_SIZE => FIXED_SIZE,
           WIDTH => WIDTH)
    port map(clk => clk,
             rst => reset,
             u1_i => cx_delayed1,
             u2_i => std_logic_vector(ci),
             ADD_SUB => '1',
            res_o => cfrac_delayed);  
               
     delay_cfrac: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => cfrac_delayed,  -- Signal sa DSP-a
        dout => cfrac_delayed1 -- Signal nakon kasnjenja
        );      
        
    rweight1_inc_dsp: dsp8
     generic map (
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => ONE_FP,
             u2_i => rfrac_mux_out, 
             u3_i => dx_delayed1,
            res_o => rweight1_delayed);   
            
      delay_rweight1: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => rweight1_delayed,  -- Signal sa DSP-a
        dout => rweight1_delayed1 -- Signal nakon kasnjenja
        );   
          
      rweight2_inc_dsp: dsp8
     generic map (
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => ONE_FP,
             u2_i => rfrac_mux_out, 
             u3_i => dy_delayed1,
            res_o => rweight2_delayed);   
            
      delay_rweight2: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => rweight2_delayed,  -- Signal sa DSP-a
        dout => rweight2_delayed1 -- Signal nakon kasnjenja
        );   
          
      cweight1_inc_dsp: dsp8
     generic map (
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => ONE_FP,
             u2_i => cfrac_mux_out, 
             u3_i => rweight1_delayed1,
            res_o => cweight1_delayed);   
            
      delay_cweight1: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => cweight1_delayed,  -- Signal sa DSP-a
        dout => cweight1_delayed1 -- Signal nakon kasnjenja
        ); 
         
           cweight2_inc_dsp: dsp8
     generic map (
           FIXED_SIZE => FIXED_SIZE)
    port map(clk => clk,
             rst => reset,
             u1_i => ONE_FP,
             u2_i => cfrac_mux_out, 
             u3_i => rweight2_delayed1,
            res_o => cweight2_delayed);   
            
      delay_cweight2: entity work.delay
    generic map (
        DELAY_CYCLES => 3,
        SIGNAL_WIDTH => FIXED_SIZE
    )
    port map (
        clk => clk,
        rst => reset,
        din => cweight2_delayed,  -- Signal sa DSP-a
        dout => cweight2_delayed1 -- Signal nakon kasnjenja
        );         
             
    -- Instanciranje ROM-a
    ROM_inst : rom
        generic map (
            WIDTH => FIXED_SIZE,
            SIZE => 40,
            SIZE_WIDTH => 6
        )
        port map (
            clk_a => clk,
            en_a => rom_enable,
            addr_a => rom_addr_next,
            data_a_o => rom_data_internal
        );

    -- Povezivanje signala za ROM
    rom_enable <= '1' when state_reg = ProcessSample else '0';
    
    
-- Sekvencijalni proces za registre
process (clk)
begin
    if (rising_edge(clk)) then
        if (reset = '1') then
            -- Reset logika
            state_reg <= idle;
            
            counter <= 0; -- Reset broja?a

            -- Reset svih registara i signala
            i_reg <= (others => '0');
            j_reg <= (others => '0');
            ri <= (others => '0');
            ci <= (others => '0');
            addSampleStep <= (others => '0');
            r <= (others => '0');
            c <= (others => '0');
            rpos_reg <= (others => '0');
            cpos_reg <= (others => '0');
            rx <= (others => '0');
            cx <= (others => '0');
            rfrac <= (others => '0');
            cfrac <= (others => '0');
            rfrac_mux_out <= (others => '0');            
            cfrac_mux_out <= (others => '0');
            
            dx1_reg <= (others => '0');
            dx2_reg <= (others => '0');
            dx_reg <= (others => '0');
            dy1_reg <= (others => '0');
            dy2_reg <= (others => '0');
            dy_reg <= (others => '0');
            dxx_reg <= (others => '0');
            dyy_reg <= (others => '0');
            weight <= (others => '0');
            rweight1 <= (others => '0');
            rweight2 <= (others => '0');
            cweight1 <= (others => '0');
            cweight2 <= (others => '0');
            ori1 <= (others => '0');
            ori2 <= (others => '0');
            dxx1 <= (others => '0');
            dxx2 <= (others => '0');
            dyy1 <= (others => '0');
            dyy2 <= (others => '0');
            
            dxx1_sum_reg <= (others => '0');
            dxx2_sum_reg <= (others => '0');
            dyy1_sum_reg <= (others => '0');
            dyy2_sum_reg <= (others => '0');
            
            temp1_rpos_reg <= (others => '0');
            temp2_rpos_reg <= (others => '0');
            temp3_rpos_reg <= (others => '0');
            temp4_rpos_reg <= (others => '0');

            temp1_cpos_reg <= (others => '0');
            temp2_cpos_reg <= (others => '0');
            temp3_cpos_reg <= (others => '0');
            temp4_cpos_reg <= (others => '0');
            
            rom_addr_int <= (others => '0');
            rom_data_reg <= (others => '0');
            rpos_squared_reg <= (others => '0');
            cpos_squared_reg <= (others => '0');
            
            bram2_phase <= 0;
            bram_addr1_o <= (others => '0');
            bram_addr2_o <= (others => '0');


        else
                -- Predji u sledece stanje i a?uriraj sve registre
                state_reg <= state_next;
            counter <= counter_next; -- A?uriranje broja?a

                -- A?uriranje registara sa internim signalima
                i_reg <= i_next;
                j_reg <= j_next;
                ri <= ri_next;
                ci <= ci_next;
                addSampleStep <= addSampleStep_next;
                r <= r_next;
                c <= c_next;
                rpos_reg <= rpos_next;
                cpos_reg <= cpos_next;
                rx <= rx_next;
                cx <= cx_next;
                
                rfrac <= rfrac_next;
                cfrac <= cfrac_next;
                
                rfrac_mux_out <= rfrac_mux_next;
                cfrac_mux_out <= cfrac_mux_next;
                
                dx1_reg <= dx1_next;
                dx2_reg <= dx2_next;
                dx_reg <= dx_next;
                dy1_reg <= dy1_next;
                dy2_reg <= dy2_next;
                dy_reg <= dy_next;
                dxx_reg <= dxx_next;
                dyy_reg <= dyy_next;
                weight <= weight_next;
                rweight1 <= rweight1_next;
                rweight2 <= rweight2_next;
                cweight1 <= cweight1_next;
                cweight2 <= cweight2_next;
                ori1 <= ori1_next;
                ori2 <= ori2_next;
                dxx1 <= dxx1_next;
                dxx2 <= dxx2_next;
                dyy1 <= dyy1_next;
                dyy2 <= dyy2_next;

                dxx1_sum_reg <= dxx1_sum_next;
                dxx2_sum_reg <= dxx2_sum_next;
                dyy1_sum_reg <= dyy1_sum_next;
                dyy2_sum_reg <= dyy2_sum_next;
                
                bram2_phase <= bram2_phase_next;

                --bram_data_out <= bram_data_out_next;
                bram_addr1_o <= bram_addr1_o_next;
                bram_addr2_o <= bram_addr2_o_next;

                temp1_rpos_reg <= temp1_rpos_next;
                temp2_rpos_reg <= temp2_rpos_next;
                temp3_rpos_reg <= temp3_rpos_next;
                temp4_rpos_reg <= temp4_rpos_next;

                temp1_cpos_reg <= temp1_cpos_next;
                temp2_cpos_reg <= temp2_cpos_next;
                temp3_cpos_reg <= temp3_cpos_next;
                temp4_cpos_reg <= temp4_cpos_next;

rpos_squared_reg <= rpos_squared_next;
cpos_squared_reg <= cpos_squared_next;

--rom_data_internal <= rom_data;
               
                
               
                end if;
            end if;
end process;


    -- Kombinacioni proces za odredjivanje sledecih stanja i vrednosti signala
process (rfrac_mux_out, cfrac_mux_out, rom_adress_delayed1, rpos_squared_delayed1, cpos_squared_delayed1, counter, bram_data32_i, bram_data16_i, state_reg, start_i, i_reg, j_reg, iradius, fracr, fracc, spacing, iy, ix, step, i_cose, i_sine, scale, ri, ci, weight, ori1, ori2, dxx1_sum_reg, dxx2_sum_reg, dyy1_sum_reg, dyy2_sum_reg, addSampleStep, rom_data_internal, rom_addr_int , bram_addr1_o_next, bram_addr2_o_next, temp1_rpos_delayed1, temp2_rpos_delayed1, temp3_rpos_delayed1, temp4_rpos_delayed1, temp1_cpos_delayed1, temp2_cpos_delayed1, temp3_cpos_delayed1, temp4_cpos_delayed1, rpos_delayed1, cpos_delayed1, rx_delayed1, cx_delayed1, r_delayed1, c_delayed1, dxx_delayed1, dyy_delayed1, dx1_delayed1, dx2_delayed1, dx_delayed1, dy1_delayed1, dy2_delayed1, dy_delayed1, rfrac_delayed1, cfrac_delayed1, rweight1_delayed1, rweight2_delayed1, cweight1_delayed1, cweight2_delayed1, cfrac, rfrac)
    begin
        -- Default assignments
        state_next <= state_reg;
        i_next <= i_reg;
        j_next <= j_reg;
        
        counter_next <= counter; -- Podrazumevano stanje broja?a

        temp1_rpos_next <= temp1_rpos_delayed1;
        temp2_rpos_next <= temp2_rpos_delayed1;
        temp3_rpos_next <= temp3_rpos_delayed1;
        temp4_rpos_next <= temp4_rpos_delayed1;

        temp1_cpos_next <= temp1_cpos_delayed1;
        temp2_cpos_next <= temp2_cpos_delayed1;
        temp3_cpos_next <= temp3_cpos_delayed1;
        temp4_cpos_next <= temp4_cpos_delayed1;
        
        rpos_next <= rpos_delayed1;
        cpos_next <= cpos_delayed1;
        
        rx_next <= rx_delayed1;
        cx_next <= cx_delayed1;
        
        rpos_squared_next <= rpos_squared_delayed1;
        cpos_squared_next <= cpos_squared_delayed1;
        
 
        addSampleStep_next <= addSampleStep;
        r_next <= signed(r_delayed1);
        c_next <= signed(c_delayed1);
       
        weight_next <= weight;

        dxx1_sum_next <= dxx1_sum_reg;
        dxx2_sum_next <= dxx2_sum_reg;
        dyy1_sum_next <= dyy1_sum_reg;
        dyy2_sum_next <= dyy2_sum_reg;
        
        dxx_next <= dxx_delayed1;
        dyy_next <= dyy_delayed1;
        
        dx1_next <= dx1_delayed1;
        dx2_next <= dx2_delayed1;
        dx_next <= dx_delayed1;
        
        dy1_next <= dy1_delayed1;
        dy2_next <= dy2_delayed1;
        dy_next <= dy_delayed1;

        
        rfrac_next <= rfrac_delayed1;
        cfrac_next <= cfrac_delayed1;      
        
        rfrac_mux_next <= rfrac_mux_out;
        cfrac_mux_next <= cfrac_mux_out;
        
        ori1_next <= ori1;
        ori2_next <= ori2;
        dxx1_next <= dxx1;
        dxx2_next <= dxx2;
        dyy1_next <= dyy1;
        dyy2_next <= dyy2;
        
        ri_next <= ri;
        ci_next <= ci;
       
        rweight1_next <= rweight1_delayed1;
        rweight2_next <= rweight2_delayed1;
        cweight1_next <= cweight1_delayed1;
        cweight2_next <= cweight2_delayed1;
       
        
        
        bram_en1_int <= '0'; 
        bram_we1_int <= '0';
        bram_en2_int <= '0'; 
        bram_we2_int <= '0';  
        
        rom_addr_next <= rom_adress_delayed1(23 downto 18); -- Defaultna vrednost za rom_addr_next
        
        bram2_phase_next <= bram2_phase;  

        bram_addr1_int <= (others => '0');
        bram_addr2_int <= (others => '0');

        --c1_data_o <= '0';
        ready_o <= '0';


        -- Logika FSM-a
        case state_reg is
             when idle =>
                ready_o <= '1';
                bram_we1_int <= '0';
                bram_en1_int <= '0';
                bram_we2_int <= '0';
                bram_en2_int <= '0';
                if start_i = '1' then
                    i_next <= TO_UNSIGNED (0, WIDTH);
                    state_next <= StartLoop;
                else
                    state_next <= idle;
                end if;


        when StartLoop =>
            if counter = 3 then
                counter_next <= 0;
                j_next <= TO_UNSIGNED(0, WIDTH);
                state_next <= InnerLoop;
            else
                counter_next <= counter + 1;
                state_next <= StartLoop;
            end if;

        when InnerLoop =>
            if counter = 3 then
                counter_next <= 0;
                state_next <= ComputeRPos1;
                dxx1_sum_next <= (others => '0');
                dxx2_sum_next <= (others => '0');
                dyy1_sum_next <= (others => '0');
                dyy2_sum_next <= (others => '0');
            else
                counter_next <= counter + 1;
                state_next <= InnerLoop;
            end if;

        when ComputeRPos1 =>
            if counter = 3 then
                counter_next <= 0;
                temp1_rpos_next <= temp1_rpos_delayed1;
                temp1_cpos_next <= temp1_cpos_delayed1;
                
                addSampleStep_next <= unsigned(scale);
                
                r_next <= signed(r_delayed1);
                c_next <= signed(c_delayed1);
                state_next <= ComputeRPos2;

            else
                counter_next <= counter + 1;
                state_next <= ComputeRPos1;
            end if;

        when ComputeRPos2 =>
            if counter = 3 then
                counter_next <= 0;
                temp2_rpos_next <= temp2_rpos_delayed1;
                temp2_cpos_next <= temp2_cpos_delayed1;

                state_next <= ComputeRPos3;
            else
                counter_next <= counter + 1;
                state_next <= ComputeRPos2;
            end if;

        when ComputeRPos3 =>
            if counter = 3 then
                counter_next <= 0;
                temp3_rpos_next <= temp3_rpos_delayed1;
                temp3_cpos_next <= temp3_cpos_delayed1;
                
                state_next <= ComputeRPos4;
            else
                counter_next <= counter + 1;
                state_next <= ComputeRPos3;
            end if;

        when ComputeRPos4 =>
            if counter = 3 then
                counter_next <= 0;
                temp4_rpos_next <= temp4_rpos_delayed1;
                temp4_cpos_next <= temp4_cpos_delayed1;

                state_next <= ComputeRPos5;
            else
                counter_next <= counter + 1;
                state_next <= ComputeRPos4;
            end if;

        when ComputeRPos5 =>
            if counter = 3 then
                counter_next <= 0;
                rpos_next <= rpos_delayed1;
                cpos_next <= cpos_delayed1;

                state_next <= SetRXandCX;
            else
                counter_next <= counter + 1;
                state_next <= ComputeRPos5;
            end if;
     
        when SetRXandCX =>
            if counter = 3 then
                counter_next <= 0;
                rx_next <= rx_delayed1;
                cx_next <= cx_delayed1;
                state_next <= BoundaryCheck;
            else
                counter_next <= counter + 1;
                state_next <= SetRXandCX;
            end if;

        when BoundaryCheck =>
            if counter = 3 then
                counter_next <= 0;
                if (signed(rx) > signed(MINUS_ONE_FP) and signed(rx) < signed(INDEX_SIZE_FP) and
                   (signed(cx) > signed(MINUS_ONE_FP) and signed(cx) <  signed(INDEX_SIZE_FP))) then
                    state_next <= ComputePosition;
                else
                    state_next <= NextSample;
                end if;
            else
                counter_next <= counter + 1;
                state_next <= BoundaryCheck;
            end if;
      

        when ComputePosition =>   
            if counter = 3 then
                counter_next <= 0;
                if (r < 1 + signed(addSampleStep) or r >= IMG_HEIGHT - 1 - signed(addSampleStep) or
                    c < 1 + signed(addSampleStep) or c >= IMG_WIDTH - 1 - signed(addSampleStep)) then
                    state_next <= NextSample;
                else
                    state_next <= ProcessSample;
                end if;
            else
                counter_next <= counter + 1;
                state_next <= ComputePosition;
            end if;

            when ProcessSample =>
    rom_addr_next <= rom_adress_delayed1(23 downto 18);
             
                state_next <= ComputeDerivatives;

             when ComputeDerivatives =>
      weight_next <= std_logic_vector(rom_data_internal);

                -- Set BRAM addresses for the first pixel for dxx1
                bram_en1_o <= '1';  -- Enable BRAM port
                bram_en2_o <= '1';  -- Enable BRAM port

                bram_addr1_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r) + to_integer(addSampleStep) + 1) * IMG_WIDTH + (to_integer(c) + to_integer(addSampleStep) + 1)), PIXEL_SIZE));
                bram_addr2_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r) + to_integer(addSampleStep) + 1) * IMG_WIDTH + (to_integer(c) + to_integer(addSampleStep) + 1)), PIXEL_SIZE));

                state_next <= WaitForData1;
                
 when WaitForData1 =>
  state_next <= FetchDXX1_1;
  
            when FetchDXX1_1 =>
                -- Capture the data from BRAM for the first pixel of dxx1
                dxx1_sum_next <= bram_data32_i & bram_data16_i;  
                -- Set BRAM addresses for the second pixel for dxx1
                bram_addr1_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r) - to_integer(addSampleStep)) * IMG_WIDTH + to_integer(c)), PIXEL_SIZE));
                bram_addr2_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r) - to_integer(addSampleStep)) * IMG_WIDTH + to_integer(c)), PIXEL_SIZE));

                state_next <= WaitForData2;
            
             when WaitForData2 =>
  state_next <= FetchDXX1_2;
  
            when FetchDXX1_2 =>
                -- Capture the data from BRAM for the second pixel of dxx1
                dxx1_sum_next <= std_logic_vector(signed(dxx1_sum_reg) + signed(bram_data32_i & bram_data16_i));                
                -- Set BRAM addresses for the third pixel for dxx1
                bram_addr1_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r) - to_integer(addSampleStep)) * IMG_WIDTH + (to_integer(c) + to_integer(addSampleStep) + 1)), PIXEL_SIZE));
                bram_addr2_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r) - to_integer(addSampleStep)) * IMG_WIDTH + (to_integer(c) + to_integer(addSampleStep) + 1)), PIXEL_SIZE));
                
                state_next <= WaitForData3;
                
 when WaitForData3 =>
  state_next <= FetchDXX1_3;
  
            when FetchDXX1_3 =>
                -- Capture the data from BRAM for the third pixel of dxx1
                dxx1_sum_next <= std_logic_vector(signed(dxx1_sum_reg) - signed(bram_data32_i & bram_data16_i));                
                -- Set BRAM addresses for the fourth pixel for dxx1
                bram_addr1_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r) + to_integer(addSampleStep) + 1) * IMG_WIDTH + to_integer(c)), PIXEL_SIZE));
                bram_addr2_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r) + to_integer(addSampleStep) + 1) * IMG_WIDTH + to_integer(c)), PIXEL_SIZE));

                state_next <= WaitForData4;
                
  when WaitForData4 =>           
   state_next <= FetchDXX1_4; 
             when FetchDXX1_4 =>
                  -- Capture the data from BRAM for the fourth pixel of dxx1
                dxx1_sum_next <= std_logic_vector(signed(dxx1_sum_reg) - signed(bram_data32_i & bram_data16_i));                
                state_next <= ComputeDXX1;
            
            when ComputeDXX1 =>
                -- Final computation for dxx1
                dxx1_next <= dxx1_sum_reg;
                -- Set BRAM addresses for the first pixel for dxx2
                bram_addr1_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r) + to_integer(addSampleStep) + 1) * IMG_WIDTH + to_integer(c + 1)), PIXEL_SIZE));
                bram_addr2_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r) + to_integer(addSampleStep) + 1) * IMG_WIDTH + to_integer(c + 1)), PIXEL_SIZE));

                state_next <= WaitForData5;
                
  when WaitForData5 =>
  state_next <= FetchDXX2_1;
  
            when FetchDXX2_1 =>
                -- Capture the data from BRAM for the first pixel of dxx2
                dxx2_sum_next <= bram_data32_i & bram_data16_i;
                -- Set BRAM addresses for the second pixel for dxx2
                bram_addr1_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r) - to_integer(addSampleStep)) * IMG_WIDTH + (to_integer(c) - to_integer(addSampleStep))), PIXEL_SIZE));
                bram_addr2_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r) - to_integer(addSampleStep)) * IMG_WIDTH + (to_integer(c) - to_integer(addSampleStep))), PIXEL_SIZE));
   
                state_next <= WaitForData6;
                
  when WaitForData6 =>
  state_next <= FetchDXX2_2;
  
            when FetchDXX2_2 =>
                -- Capture the data from BRAM for the second pixel of dxx2
                dxx2_sum_next <= std_logic_vector(signed(dxx2_sum_reg) + signed(bram_data32_i & bram_data16_i)); 
                -- Set BRAM addresses for the third pixel for dxx2
                bram_addr1_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r) - to_integer(addSampleStep)) * IMG_WIDTH + (to_integer(c) + 1)), PIXEL_SIZE));
                bram_addr2_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r) - to_integer(addSampleStep)) * IMG_WIDTH + (to_integer(c) + 1)), PIXEL_SIZE));

                state_next <= WaitForData7;
                
     when WaitForData7 =>
  state_next <= FetchDXX2_3; 
        
            when FetchDXX2_3 =>
                -- Capture the data from BRAM for the third pixel of dxx2
                dxx2_sum_next <= std_logic_vector(signed(dxx2_sum_reg) - signed(bram_data32_i & bram_data16_i));
                -- Set BRAM addresses for the fourth pixel for dxx2
                bram_addr1_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r) + to_integer(addSampleStep) + 1) * IMG_WIDTH + to_integer(c - to_integer(addSampleStep))), PIXEL_SIZE));
                bram_addr2_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r) + to_integer(addSampleStep) + 1) * IMG_WIDTH + to_integer(c - to_integer(addSampleStep))), PIXEL_SIZE));

                state_next <= WaitForData8;
                
   when WaitForData8 =>
  state_next <= FetchDXX2_4;
           
            when FetchDXX2_4 =>
                -- Capture the data from BRAM for the fourth pixel of dxx2
                dxx2_sum_next <= std_logic_vector(signed(dxx2_sum_reg) - signed(bram_data32_i & bram_data16_i));
                state_next <= ComputeDXX2;
            
            when ComputeDXX2 =>
                -- Final computation for dxx2
                dxx2_next <= dxx2_sum_reg;
                -- Set BRAM addresses for the first pixel for dyy1
                bram_addr1_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r + 1) * IMG_WIDTH + to_integer(c + to_integer(addSampleStep) + 1))), PIXEL_SIZE));
                bram_addr2_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r + 1) * IMG_WIDTH + to_integer(c + to_integer(addSampleStep) + 1))), PIXEL_SIZE));

                state_next <= WaitForData9;
                
  when WaitForData9 =>
  state_next <= FetchDYY1_1;   
         
            when FetchDYY1_1 =>
                -- Capture the data from BRAM for the first pixel of dyy1
                dyy1_sum_next <= bram_data32_i & bram_data16_i;
                -- Set BRAM addresses for the second pixel for dyy1
                bram_addr1_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r - to_integer(addSampleStep)) * IMG_WIDTH + to_integer(c - to_integer(addSampleStep)))), PIXEL_SIZE));
                bram_addr2_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r - to_integer(addSampleStep)) * IMG_WIDTH + to_integer(c - to_integer(addSampleStep)))), PIXEL_SIZE));

                state_next <= WaitForData10;
                
 when WaitForData10 =>
  state_next <= FetchDYY1_2; 
            
            when FetchDYY1_2 =>
                -- Capture the data from BRAM for the second pixel of dyy1
                dyy1_sum_next <= std_logic_vector(signed(dyy1_sum_reg) + signed(bram_data32_i & bram_data16_i));
                -- Set BRAM addresses for the third pixel for dyy1
                bram_addr1_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r - to_integer(addSampleStep)) * IMG_WIDTH + to_integer(c + to_integer(addSampleStep) + 1))), PIXEL_SIZE));
                bram_addr2_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r - to_integer(addSampleStep)) * IMG_WIDTH + to_integer(c + to_integer(addSampleStep) + 1))), PIXEL_SIZE));

                state_next <= WaitForData11;
                
 when WaitForData11 =>
  state_next <= FetchDYY1_3; 
            
            when FetchDYY1_3 =>
                -- Capture the data from BRAM for the third pixel of dyy1
                dyy1_sum_next <= std_logic_vector(signed(dyy1_sum_reg) - signed(bram_data32_i & bram_data16_i));                 
                -- Set BRAM addresses for the fourth pixel for dyy1
                bram_addr1_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r + 1) * IMG_WIDTH + to_integer(c - to_integer(addSampleStep)))), PIXEL_SIZE));
                bram_addr2_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r + 1) * IMG_WIDTH + to_integer(c - to_integer(addSampleStep)))), PIXEL_SIZE));

                state_next <= WaitForData12;
                
 when WaitForData12 =>
  state_next <= FetchDYY1_4;      
       
            when FetchDYY1_4 =>
                -- Capture the data from BRAM for the fourth pixel of dyy1
                dyy1_sum_next <= std_logic_vector(signed(dyy1_sum_reg) - signed(bram_data32_i & bram_data16_i));
                state_next <= ComputeDYY1;
            
            when ComputeDYY1 =>
                -- Final computation for dyy1
                dyy1_next <= dyy1_sum_reg;
                -- Set BRAM addresses for the first pixel for dyy2
                bram_addr1_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r + to_integer(addSampleStep) + 1) * IMG_WIDTH + to_integer(c + to_integer(addSampleStep) + 1))), PIXEL_SIZE));
                bram_addr2_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r + to_integer(addSampleStep) + 1) * IMG_WIDTH + to_integer(c + to_integer(addSampleStep) + 1))), PIXEL_SIZE));

                state_next <= WaitForData13;
                
 when WaitForData13 =>
  state_next <= FetchDYY2_1; 
            
            when FetchDYY2_1 =>
                -- Capture the data from BRAM for the first pixel of dyy2
                dyy2_sum_next <= bram_data32_i & bram_data16_i;
                -- Set BRAM addresses for the second pixel for dyy2
                bram_addr1_o_next <= std_logic_vector(to_unsigned(4*(to_integer(r) * IMG_WIDTH + to_integer(c - to_integer(addSampleStep))), PIXEL_SIZE));
                bram_addr2_o_next <= std_logic_vector(to_unsigned(4*(to_integer(r) * IMG_WIDTH + to_integer(c - to_integer(addSampleStep))), PIXEL_SIZE));

                state_next <= WaitForData14;
                
  when WaitForData14 =>
  state_next <= FetchDYY2_2;    
        
            when FetchDYY2_2 =>
                -- Capture the data from BRAM for the second pixel of dyy2
                dyy2_sum_next <= std_logic_vector(signed(dyy2_sum_reg) + signed(bram_data32_i & bram_data16_i));
                -- Set BRAM addresses for the third pixel for dyy2
                bram_addr1_o_next <= std_logic_vector(to_unsigned(4*(to_integer(r) * IMG_WIDTH + to_integer(c + to_integer(addSampleStep) + 1)), PIXEL_SIZE));
                bram_addr2_o_next <= std_logic_vector(to_unsigned(4*(to_integer(r) * IMG_WIDTH + to_integer(c + to_integer(addSampleStep) + 1)), PIXEL_SIZE));

                state_next <= WaitForData15;
                
  when WaitForData15 =>
  state_next <= FetchDYY2_3;
            
            when FetchDYY2_3 =>
                -- Capture the data from BRAM for the third pixel of dyy2
                dyy2_sum_next <= std_logic_vector(signed(dyy2_sum_reg) - signed(bram_data32_i & bram_data16_i));
                -- Set BRAM addresses for the fourth pixel for dyy2
                bram_addr1_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r + to_integer(addSampleStep) + 1) * IMG_WIDTH + to_integer(c - to_integer(addSampleStep)))), PIXEL_SIZE));
                bram_addr2_o_next <= std_logic_vector(to_unsigned(4*((to_integer(r + to_integer(addSampleStep) + 1) * IMG_WIDTH + to_integer(c - to_integer(addSampleStep)))), PIXEL_SIZE));
 
                state_next <= WaitForData16;
                
 when WaitForData16 =>
  state_next <= FetchDYY2_4;
             
            when FetchDYY2_4 =>
                -- Capture the data from BRAM for the fourth pixel of dyy2
                dyy2_sum_next <= std_logic_vector(signed(dyy2_sum_reg) - signed(bram_data32_i & bram_data16_i));
                state_next <= ComputeDYY2;
            
            when ComputeDYY2 =>
                -- Final computation for dyy2
                dyy2_next <= dyy2_sum_reg;
                state_next <= CalculateDerivatives;

            when CalculateDerivatives =>
            if counter = 3 then
                counter_next <= 0;
                dxx_next <= dxx_delayed1; 
                dyy_next <= dyy_delayed1; 
                state_next <= ApplyOrientationTransform_1;
            else
                counter_next <= counter + 1;
            end if;

        when ApplyOrientationTransform_1 =>
            if counter = 3 then
                counter_next <= 0;
                dx1_next <= dx1_delayed1; 
                dx2_next <= dx2_delayed1; 
                dy1_next <= dy1_delayed1;
                dy2_next <= dy2_delayed1;

                state_next <= ApplyOrientationTransform;
            else
                counter_next <= counter + 1;
            end if;
                

        when ApplyOrientationTransform =>
            if counter = 3 then
                counter_next <= 0;
                dx_next <= dx_delayed1; 
                dy_next <= dy_delayed1;
                state_next <= SetOrientations;
            else
                counter_next <= counter + 1;
            end if;

               when SetOrientations =>
                        if counter = 9 then
                     counter_next <= 0;

                if signed(dx_reg) < 0 then
                    ori1_next <= to_unsigned(0, WIDTH);
                else
                    ori1_next <= to_unsigned(1, WIDTH);
                end if;
                if signed(dy_reg) < 0 then
                    ori2_next <= to_unsigned(2, WIDTH);
                else
                    ori2_next <= to_unsigned(3, WIDTH);
                end if;
                state_next <= UpdateIndex;
             else
                counter_next <= counter + 1;
            end if;
            
            when UpdateIndex =>
                -- Check rx and set ri accordingly
                if signed(rx) < 0 then
                    ri_next <= to_unsigned(0, WIDTH);
              elsif signed(rx) >= signed(INDEX_SIZE_FP) then
                    ri_next <= to_unsigned(INDEX_SIZE - 1, WIDTH);
                else
                    ri_next <= to_unsigned(to_integer(unsigned(rx(47 downto 18))), WIDTH);                
                end if;

                -- Check ci and update ci accordingly
                if signed(cx) < 0 then
                    ci_next <= to_unsigned(0, WIDTH);
                elsif signed(cx) >= signed(to_signed(to_integer(unsigned(INDEX_SIZE_FP)), INDEX_SIZE_FP'length)) then
                    ci_next <= to_unsigned(INDEX_SIZE - 1, WIDTH);
                else
                    ci_next <= to_unsigned(to_integer(unsigned(cx(47 downto 18))), WIDTH);                
                end if;
                state_next <= ComputeFractionalComponents;

           when ComputeFractionalComponents =>
              if counter = 7 then
                     counter_next <= 0;
                    rfrac_next <= rfrac_delayed1;
                    cfrac_next <= cfrac_delayed1;

                     state_next <= ValidateRfrac;
              else
                    counter_next <= counter + 1;
            end if;
            
            when ValidateRfrac =>
            
                     if signed(rfrac_delayed1) < 0 then
                        rfrac_mux_next <= std_logic_vector(to_signed(0, FIXED_SIZE));
                        
                    elsif signed(rfrac_delayed1) >= signed(ONE_FP) then
                         rfrac_mux_next <= ONE_FP; 
                          
                    else
                        rfrac_mux_next <= rfrac_next;
                    end if;
                    
                     state_next <= ValidateCfrac;
           
          

           when ValidateCfrac =>
  
                    if signed(cfrac_delayed1) < 0 then
                        cfrac_mux_next <= std_logic_vector(to_signed(0, FIXED_SIZE));

                    elsif signed(cfrac_delayed1) >= signed(ONE_FP) then
                        cfrac_mux_next <= ONE_FP; 
                        
                    else
                        cfrac_mux_next <= cfrac_next;
                        
                    end if;
                    
                        state_next <= ComputeWeightsR;
                        
            
             when ComputeWeightsR =>

            if counter = 4 then
                counter_next <= 0;
                rweight1_next <= rweight1_delayed1;
                rweight2_next <= rweight2_delayed1;
                state_next <= ComputeWeightsC;
            else
                counter_next <= counter + 1;
            end if;

        when ComputeWeightsC =>  
                        bram2_phase_next <= 0;
              
            if counter = 4 then
                counter_next <= 0;
                cweight1_next <= cweight1_delayed1;
                cweight2_next <= cweight2_delayed1;

                state_next <= UpdateIndexArray0;
            else
                counter_next <= counter + 1;
            end if;
                
           when UpdateIndexArray0 =>
          if counter = 4 then
                counter_next <= 0;
                if ri >= 0 and ri < INDEX_SIZE and ci >= 0 and ci < INDEX_SIZE then
                    if bram2_phase = 0 then
                        bram_addr1_int <= std_logic_vector(to_unsigned(4*((to_integer(unsigned(ri)) * (INDEX_SIZE * 4)) + to_integer(unsigned(ci)) * 4 + to_integer(unsigned(ori1))), INDEX_ADDRESS_SIZE));
                        data32_o <= cweight1(47 downto 16);
                        bram_addr2_int <= std_logic_vector(to_unsigned(4*((to_integer(unsigned(ri)) * (INDEX_SIZE * 4)) + to_integer(unsigned(ci)) * 4 + to_integer(unsigned(ori1))), INDEX_ADDRESS_SIZE));
                        data16_o <= cweight1(15 downto 0);

                        bram_en1_int <= '1';
                        bram_we1_int <= '1';
                        bram_en2_int <= '1';
                        bram_we2_int <= '1';
                        bram2_phase_next <= 1;
                        state_next <= UpdateIndexArray1;
                    end if;
              else
                state_next<= NextSample;
              end if;
        else
                counter_next <= counter + 1;
            end if;
      
        when UpdateIndexArray1 =>
           
                if bram2_phase = 1 then
                    bram_addr1_int <= std_logic_vector(to_unsigned(4*((to_integer(unsigned(ri)) * (INDEX_SIZE * 4)) + to_integer(unsigned(ci)) * 4 + to_integer(unsigned(ori2))), INDEX_ADDRESS_SIZE));
                    data32_o <= cweight2(47 downto 16);
                    bram_addr2_int <= std_logic_vector(to_unsigned(4*((to_integer(unsigned(ri)) * (INDEX_SIZE * 4)) + to_integer(unsigned(ci)) * 4 + to_integer(unsigned(ori2))), INDEX_ADDRESS_SIZE));
                    data16_o <= cweight2(15 downto 0);
                    
                       bram_en1_int <= '1';
                       bram_we1_int <= '1';
                       bram_en2_int <= '1';
                       bram_we2_int <= '1';
                    bram2_phase_next <= 0;
                    state_next <= NextSample;
                end if;
                                    
            when NextSample =>
                j_next <= j_reg + 1;
                if (j_next >= to_unsigned(2 * to_integer(unsigned(iradius)), WIDTH)) then
                    state_next <= IncrementI;
                else
                    state_next <= InnerLoop;
                end if;

            when IncrementI =>
                i_next <= i_reg + 1;
                if (i_next >= to_unsigned(2 * to_integer(unsigned(iradius)), WIDTH)) then
                    state_next <= Finish;
                else
                    state_next <= StartLoop;
                end if;

            when Finish =>
                done <= '1';
                state_next <= idle;

            when others =>
                state_next <= idle;
        end case;
    end process;

    -- Azuriranje izlaznih portova 
    addr_do1_o <= bram_addr1_int;
    addr_do2_o <= bram_addr2_int;

    c1_data_o <= bram_en1_int;
    bram_we1_o <= bram_we1_int;
    c2_data_o <= bram_en2_int;
    bram_we2_o <= bram_we2_int;
    
    rom_addr <= rom_addr_next;  -- Azuriranje rom_addr signala
    
end Behavioral;