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
use work.ip_pkg.all;  -- Dodajte ovu liniju

entity ip is
    generic (
        WIDTH : integer := 11;            -- Bit width for various unsigned signals
        PIXEL_SIZE : integer := 14;       -- 128 x 128 pixels
        SUM_WIDTH : integer := 16;         -- Width for summed signals
        FIXED_SIZE : integer := 48;       -- Bit width for fixed-point operations
        INDEX_SIZE : integer := 4;        -- Dimension size for the index array
        IMG_WIDTH : integer := 128;       -- Width of the image
        IMG_HEIGHT : integer := 128       -- Height of the image
        
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
        data1_o_next : out std_logic_vector (8*FIXED_SIZE + 4*WIDTH + 2*SUM_WIDTH - 1 downto 0);           --VIDETI SA CIM POVEZUJEM INTERNO
        c1_data_o : out std_logic;
        addr_do2_o : out std_logic_vector (5 downto 0);
        data2_o_next : out std_logic_vector (8*FIXED_SIZE + 4*WIDTH + 2*SUM_WIDTH - 1 downto 0);         --VIDETI SA CIM POVEZUJEM INTERNO
        c2_data_o : out std_logic;
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

    component rom
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
    end component;

   
    
    type state_type is (
        idle, StartLoop, InnerLoop, 
        ComputeRPos1, ComputeRPos2, ComputeRPos3, ComputeRPos4, ComputeRPos5,
        ComputeCPos1, ComputeCPos2, ComputeCPos3, ComputeCPos4, ComputeCPos5,
        SetRXandCX, BoundaryCheck, PositionValidation, ComputePosition, ProcessSample,
        ComputeDerivatives, FetchDXX1_1, FetchDXX1_2, ComputeDXX1,
        FetchDXX2_1, FetchDXX2_2, ComputeDXX2, FetchDYY1_1, FetchDYY1_2, ComputeDYY1,
        FetchDYY2_1, FetchDYY2_2, ComputeDYY2, CalculateDerivatives, ApplyOrientationTransform,
        SetOrientations, UpdateIndex, ComputeFractionalComponents, ValidateIndices, ComputeWeightsR,ComputeWeightsC, UpdateIndexArray, CheckNextColumn, CheckNextRow,
        NextSample, IncrementI, Finish
    );

    --signal state_reg, state_next : state_type;
    
constant INDEX_SIZE_FP : std_logic_vector(FIXED_SIZE - 1 downto 0) := std_logic_vector(to_unsigned(INDEX_SIZE, FIXED_SIZE));
constant HALF_INDEX_SIZE_FP : std_logic_vector(FIXED_SIZE - 1 downto 0) := std_logic_vector(to_unsigned(INDEX_SIZE / 2, FIXED_SIZE));
constant HALF_FP : std_logic_vector(FIXED_SIZE - 1 downto 0) := std_logic_vector(to_unsigned(1, FIXED_SIZE - 1) & '0'); -- 0.5 u fiksnoj ta?ki


    signal i_reg, i_next : unsigned(WIDTH - 1 downto 0) := to_unsigned(23, WIDTH); -- STA OVDE IDE
    signal j_reg, j_next : unsigned(WIDTH - 1 downto 0) := to_unsigned(23, WIDTH);
    
    signal temp1_rpos_reg, temp1_rpos_next, temp2_rpos_reg, temp2_rpos_next : std_logic_vector(2*WIDTH + FIXED_SIZE - 1 downto 0);
    signal temp3_rpos_reg, temp3_rpos_next, temp4_rpos_reg, temp4_rpos_next : std_logic_vector(2*WIDTH + 2*FIXED_SIZE - 1 downto 0);
    signal temp1_cpos_reg, temp1_cpos_next, temp2_cpos_reg, temp2_cpos_next : std_logic_vector(2*WIDTH + FIXED_SIZE - 1 downto 0);
    signal temp3_cpos_reg, temp3_cpos_next, temp4_cpos_reg, temp4_cpos_next : std_logic_vector(2*WIDTH + 2*FIXED_SIZE - 1 downto 0);
    signal rpos, cpos : std_logic_vector(2*WIDTH + 2*FIXED_SIZE - 1 downto 0);
    signal rpos_next, cpos_next : std_logic_vector(2*WIDTH + 2*FIXED_SIZE - 1 downto 0);
    signal rx, cx, rx_next, cx_next : std_logic_vector( 2*WIDTH + 2*FIXED_SIZE - 1 downto 0);
    signal addSampleStep, addSampleStep_next : unsigned(WIDTH - 1 downto 0);
    signal r, c, r_next, c_next : signed(2*WIDTH - 1 downto 0);
    signal weight, weight_next : std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal dxx1_sum_next, dxx2_sum_next, dyy1_sum_next, dyy2_sum_next : std_logic_vector(SUM_WIDTH - 1 downto 0); -- Accumulators for sum of BRAM data
    signal dxx1_sum_reg, dxx2_sum_reg, dyy1_sum_reg, dyy2_sum_reg : std_logic_vector(SUM_WIDTH - 1 downto 0);
    signal dxx1, dxx2, dyy1, dyy2 : std_logic_vector(SUM_WIDTH - 1 downto 0);
    signal dxx1_next, dxx2_next, dyy1_next, dyy2_next : std_logic_vector(SUM_WIDTH - 1 downto 0);
    signal dxx, dyy, dxx_next, dyy_next :  std_logic_vector(FIXED_SIZE + SUM_WIDTH - 1 downto 0);
    signal dx, dy, dx_next, dy_next :  std_logic_vector(4*FIXED_SIZE + 2*SUM_WIDTH - 1 downto 0);
    signal ori1, ori2 : unsigned(WIDTH - 1 downto 0);
    signal ori1_next, ori2_next : unsigned(WIDTH - 1 downto 0);
    signal ri, ci, ri_next, ci_next : unsigned(WIDTH - 1 downto 0);
    signal rfrac, cfrac :  std_logic_vector(2*WIDTH + 2*FIXED_SIZE - 1 downto 0);
    signal rfrac_next, cfrac_next : std_logic_vector(2*WIDTH + 2*FIXED_SIZE - 1 downto 0);
    signal rweight1, rweight2, rweight1_next, rweight2_next : std_logic_vector(6*FIXED_SIZE + 2*WIDTH + 2*SUM_WIDTH - 1 downto 0);
    signal cweight1, cweight2, cweight1_next, cweight2_next : std_logic_vector(8*FIXED_SIZE + 4*WIDTH + 2*SUM_WIDTH - 1 downto 0);

    signal done : std_logic;

     -- Definisanje internog signala za kombinatornu logiku
    signal rom_data_internal : std_logic_vector(FIXED_SIZE - 1 downto 0);
    signal rom_enable : std_logic;
    signal rom_addr_next : std_logic_vector(5 downto 0);
    signal rom_addr_int : std_logic_vector(5 downto 0);  -- Dodato za internu adresu
    
    -- Definisanje internog signala za adrese ULAZNI bram
    signal bram_addr1_int, bram_addr2_int : std_logic_vector(PIXEL_SIZE-1 downto 0);
    signal bram_addr1_next, bram_addr2_next : std_logic_vector(PIXEL_SIZE-1 downto 0);
    
    
    -- Definisanje internog signala za adrese IZLAZNI bram
    signal data1_o_reg, data2_o_reg : std_logic_vector (8*FIXED_SIZE + 4*WIDTH + 2*SUM_WIDTH - 1 downto 0);  
    signal data1_o_next_int, data2_o_next_int : std_logic_vector (8*FIXED_SIZE + 4*WIDTH + 2*SUM_WIDTH- 1 downto 0);  -- Interne signale za kombinatornu logiku



begin
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
            addr_a => rom_addr_int,
            data_a_o => rom_data_internal
        );

    -- Povezivanje signala za ROM
    rom_enable <= '1' when state_reg = ProcessSample else '0';
    rom_addr_int <= rom_addr_next;

    -- Sekvencijalni proces za registre
    process (clk)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
            state_reg <= idle;
            -- Resetovanje svih signala na po?etne vrednosti
            i_reg <= (others => '0');
            j_reg <= (others => '0');
            ri <= (others => '0');
            ci <= (others => '0');
            addSampleStep <= (others => '0');
            r <= (others => '0');
            c <= (others => '0');
            rpos <= (others => '0');
            cpos <= (others => '0');
            rx <= (others => '0');
            cx <= (others => '0');
            rfrac <= (others => '0');
            cfrac <= (others => '0');
            dx <= (others => '0');
            dy <= (others => '0');
            dxx <= (others => '0');
            dyy <= (others => '0');
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
            data1_o_reg <= (others => '0');
            data2_o_reg <= (others => '0');
            bram_addr1_int <= (others => '0');
            bram_addr2_int <= (others => '0');
            -- Resetovanje registara
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
            
        else
            state_reg <= state_next;
            -- A?uriranje registara sa internim signalima
            i_reg <= i_next;
            j_reg <= j_next;
            ri <= ri_next;
            ci <= ci_next;
            addSampleStep <= addSampleStep_next;
            r <= r_next;
            c <= c_next;
            rpos <= rpos_next;
            cpos <= cpos_next;
            rx <= rx_next;
            cx <= cx_next;
            rfrac <= rfrac_next;
            cfrac <= cfrac_next;
            dx <= dx_next;
            dy <= dy_next;
            dxx <= dxx_next;
            dyy <= dyy_next;
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
            
            data1_o_reg <= data1_o_next_int;
            data2_o_reg <= data2_o_next_int;
            bram_addr1_int <= bram_addr1_next;  -- A?uriranje internog signala za adrese
            bram_addr2_int <= bram_addr2_next;
            
            temp1_rpos_reg <= temp1_rpos_next;
            temp2_rpos_reg <= temp2_rpos_next;
            temp3_rpos_reg <= temp3_rpos_next;
            temp4_rpos_reg <= temp4_rpos_next;
            temp1_cpos_reg <= temp1_cpos_next;
            temp2_cpos_reg <= temp2_cpos_next;
            temp3_cpos_reg <= temp3_cpos_next;
            temp4_cpos_reg <= temp4_cpos_next;
            
            end if;
        end if;
    end process;

    -- Kombinacioni proces za odre?ivanje slede?ih stanja i vrednosti signala
    process (state_reg, start_i, temp1_rpos_reg, temp2_rpos_reg, temp3_rpos_reg, temp4_rpos_reg, temp1_cpos_reg, temp2_cpos_reg, temp3_cpos_reg, temp4_cpos_reg, bram_data1_i, bram_data2_i, iradius, fracr, fracc, spacing, iy, ix, step, i_cose, i_sine, scale, i_reg, j_reg, ri, ci, r, c, rx, cx, rfrac, cfrac, dx, dy, dxx, dyy, weight, rweight1, rweight2, cweight1, cweight2, ori1, ori2, dxx1, dxx2, dyy1, dyy2, rpos, cpos, dxx1_sum_reg, dxx2_sum_reg, dyy1_sum_reg, dyy2_sum_reg, addSampleStep, rom_data_internal, data1_o_reg, data2_o_reg, bram_addr1_int, bram_addr2_int)
    begin
        -- Default assignments
        state_next <= state_reg;
        i_next <= i_reg;
        j_next <= j_reg;
        ri_next <= ri;
        ci_next <= ci;
        addSampleStep_next <= addSampleStep;
        r_next <= r;
        c_next <= c;
        rx_next <= rx;
        cx_next <= cx;
        rfrac_next <= rfrac;
        cfrac_next <= cfrac;
        dx_next <= dx;
        dy_next <= dy;
        dxx_next <= dxx;
        dyy_next <= dyy;
        weight_next <= weight;
        rweight1_next <= rweight1;
        rweight2_next <= rweight2;
        cweight1_next <= cweight1;
        cweight2_next <= cweight2;
        ori1_next <= ori1;
        ori2_next <= ori2;
        dxx1_next <= dxx1;
        dxx2_next <= dxx2;
        dyy1_next <= dyy1;
        dyy2_next <= dyy2;
        rpos_next <= rpos;
        cpos_next <= cpos;
        
        temp1_rpos_next <= temp1_rpos_reg;
        temp2_rpos_next <= temp2_rpos_reg;
        temp3_rpos_next <= temp3_rpos_reg;
        temp4_rpos_next <= temp4_rpos_reg;
        temp1_cpos_next <= temp1_cpos_reg;
        temp2_cpos_next <= temp2_cpos_reg;
        temp3_cpos_next <= temp3_cpos_reg;
        temp4_cpos_next <= temp4_cpos_reg;
        
        data1_o_next_int <= data1_o_reg;  -- Interni signal za kombinatornu logiku
        data2_o_next_int <= data2_o_reg;
        dxx1_sum_next <= dxx1_sum_reg;
        dxx2_sum_next <= dxx2_sum_reg;
        dyy1_sum_next <= dyy1_sum_reg;
        dyy2_sum_next <= dyy2_sum_reg;
        bram_addr1_next <= bram_addr1_int;  -- A?uriranje internog signala za adrese
        bram_addr2_next <= bram_addr2_int;
        
        bram_en1_o <= '0'; -- Defaultna vrednost za bram_en1_o
        bram_we1_o <= '0'; -- Defaultna vrednost za bram_we1_o
        bram_en2_o <= '0'; -- Defaultna vrednost za bram_en2_o
        bram_we2_o <= '0'; -- Defaultna vrednost za bram_we2_o
        rom_addr_next <= (others => '0'); -- Defaultna vrednost za rom_addr
        addr_do1_o <= (others => '0'); -- Defaultna vrednost za addr_do1_o
        addr_do2_o <= (others => '0'); -- Defaultna vrednost za addr_do2_o

        c1_data_o <= '0';
        c2_data_o <= '0';
        ready_o <= '1';

        -- Logika FSM-a
        case state_reg is
            when idle =>
                ready_o <= '1';
                if start_i = '1' then
                    i_next <= TO_UNSIGNED (0, WIDTH);
                    state_next <= StartLoop;
                else
                    state_next <= idle;
                end if;

             when StartLoop =>
                j_next <= TO_UNSIGNED (0, WIDTH);
                state_next <= InnerLoop;

            when InnerLoop =>
                state_next <= ComputeRPos1;

                          when ComputeRPos1 =>
                        -- rpos = (step * (i_cose * (i - iradius) + i_sine * (j - iradius)) - fracr) / spacing;
                        temp1_rpos_next <= std_logic_vector(
                            resize(
                                to_signed(
                                    to_integer(unsigned(step)) *
                                    (to_integer(unsigned(i_cose)) *
                                    (to_integer(signed(i_reg)) - to_integer(signed(iradius))))
                                , 2*WIDTH + FIXED_SIZE
                            ), 2*WIDTH + FIXED_SIZE
                        ));
                        state_next <= ComputeRPos2;
                    
                    when ComputeRPos2 =>
                        temp2_rpos_next <= temp1_rpos_reg;
                        state_next <= ComputeRPos3;
                    
                    when ComputeRPos3 =>
                        temp3_rpos_next <= std_logic_vector(
                            resize(
                                to_signed(
                                    to_integer(signed(temp2_rpos_reg)) +
                                    (to_integer(unsigned(i_sine)) *
                                    (to_integer(signed(j_reg)) - to_integer(signed(iradius))))
                                , 2*WIDTH + 2*FIXED_SIZE
                            ), 2*WIDTH + 2*FIXED_SIZE
                        ));
                        state_next <= ComputeRPos4;
                    
                    when ComputeRPos4 =>
                        temp4_rpos_next <= std_logic_vector(
                            resize(
                                to_signed(
                                    to_integer(signed(temp3_rpos_reg)) -
                                    to_integer(signed(fracr))
                                , 2*WIDTH + 2*FIXED_SIZE
                            ), 2*WIDTH + 2*FIXED_SIZE
                        ));
                        state_next <= ComputeRPos5;
                    
                    when ComputeRPos5 =>
                        rpos_next <= std_logic_vector(
                            resize(
                                to_signed(
                                    to_integer(signed(temp4_rpos_reg)) /
                                    to_integer(signed(spacing))
                                , 2*WIDTH + 2*FIXED_SIZE
                            ), 2*WIDTH + 2*FIXED_SIZE
                        ));

                        state_next <= ComputeCPos1;
                    
                    when ComputeCPos1 =>
                        temp1_cpos_next <= std_logic_vector(
                            resize(
                                to_signed(
                                    to_integer(unsigned(step)) *
                                    (-to_integer(unsigned(i_sine)) *
                                    (to_integer(signed(i_reg)) - to_integer(signed(iradius))))
                                , 2*WIDTH + FIXED_SIZE 
                            ), 2*WIDTH + FIXED_SIZE 
                        ));
                        state_next <= ComputeCPos2;
                    
                    when ComputeCPos2 =>
                        temp2_cpos_next <= temp1_cpos_reg;
                        state_next <= ComputeCPos3;
                    
                    when ComputeCPos3 =>
                        temp3_cpos_next <= std_logic_vector(
                            resize(
                                to_signed(
                                    to_integer(unsigned(temp2_cpos_reg)) +
                                    (to_integer(unsigned(i_cose)) *
                                    (to_integer(signed(j_reg)) - to_integer(signed(iradius))))
                                , 2*WIDTH + 2*FIXED_SIZE
                            ), 2*WIDTH + 2*FIXED_SIZE
                        ));
                        state_next <= ComputeCPos4;
                    when ComputeCPos4 =>
                        temp4_cpos_next <= std_logic_vector(
                            resize(
                                to_signed(
                                    to_integer(signed(temp3_cpos_reg)) -
                                    to_integer(signed(fracc))
                                , 2*WIDTH + 2*FIXED_SIZE
                            ), 2*WIDTH + 2*FIXED_SIZE
                        ));
                        
                 state_next <= ComputeCPos5;
   
               when ComputeCPos5 =>
                    cpos_next <= std_logic_vector(
                        resize(
                            to_signed(
                                to_integer(signed(temp4_cpos_reg)) / to_integer(signed(spacing))
                            , 2*WIDTH + 2*FIXED_SIZE
                        ), 2*WIDTH + 2*FIXED_SIZE
                    ));
                    state_next <= SetRXandCX;



           when SetRXandCX =>
                rx_next <= std_logic_vector(
                    to_signed(
                        to_integer(unsigned(rpos)) +
                        to_integer(unsigned(HALF_INDEX_SIZE_FP)) -
                        to_integer(unsigned(HALF_FP)),
                         2*WIDTH + 2*FIXED_SIZE
                    )
                );
                cx_next <= std_logic_vector(
                    to_signed(
                        to_integer(unsigned(cpos)) +
                        to_integer(unsigned(HALF_INDEX_SIZE_FP)) -
                        to_integer(unsigned(HALF_FP)),
                         2*WIDTH + 2*FIXED_SIZE
                    )
                );

                state_next <= BoundaryCheck;

            when BoundaryCheck =>
                 if (signed(rx) > -1 and signed(rx) < to_signed(INDEX_SIZE, rx'length)) and
       (signed(cx) > -1 and signed(cx) < to_signed(INDEX_SIZE, cx'length)) then
                    state_next <= NextSample;
                else
                    state_next <= PositionValidation;
                end if;

            when PositionValidation =>
                addSampleStep_next <= unsigned(resize(signed(scale), WIDTH));
                
                r_next <= resize(signed(iy) + (signed(resize(i_reg, 2*WIDTH)) - signed(resize(iradius, 2*WIDTH))) * signed(step), 2*WIDTH);
                c_next <= resize(signed(ix) + (signed(resize(j_reg, 2*WIDTH)) - signed(resize(iradius, 2*WIDTH))) * signed(step), 2*WIDTH);
                
                state_next <= ComputePosition; -- Dodato novo stanje ovde

            when ComputePosition =>
                if (r < 1 + signed(addSampleStep) or r >= IMG_HEIGHT - 1 - signed(addSampleStep) or
                    c < 1 + signed(addSampleStep) or c >= IMG_WIDTH - 1 - signed(addSampleStep)) then
                    state_next <= NextSample;
                else
                    state_next <= ProcessSample;
                end if;

           when ProcessSample =>
    -- Generisanje adrese za ROM sa modifikacijom da bude u validnom opsegu
    rom_addr_next <= std_logic_vector(to_unsigned(
        ((to_integer(unsigned(rpos)) * to_integer(unsigned(rpos)) + 
          to_integer(unsigned(cpos)) * to_integer(unsigned(cpos))) + 100000) mod 40, 6));
    weight_next <= std_logic_vector(resize(signed(rom_data_internal), FIXED_SIZE));
    state_next <= ComputeDerivatives;


------ VEROVATNO TREBA NAMESTITI DA SE NE MENJAJU R, C, ADDSAMPLESTEP SVE DOK SE NE OBRADI SVE ADRESE I PODACI OD DXX1 DO DYY2
            when ComputeDerivatives =>
                -- Set BRAM addresses for the first pair of pixels for dxx1
                bram_addr1_next <= std_logic_vector(to_unsigned((to_integer(r) + to_integer(addSampleStep) + 1) * IMG_WIDTH + (to_integer(c) + to_integer(addSampleStep) + 1), PIXEL_SIZE));
                bram_addr2_next <= std_logic_vector(to_unsigned((to_integer(r) - to_integer(addSampleStep)) * IMG_WIDTH + to_integer(c), PIXEL_SIZE));
                bram_en1_o <= '1';  -- Enable BRAM port 1
                bram_en2_o <= '1';  -- Enable BRAM port 2
                state_next <= FetchDXX1_1;

            when FetchDXX1_1 =>
                -- Capture the data from BRAM for dxx1
                dxx1_sum_next <= std_logic_vector(resize(signed(bram_data1_i), SUM_WIDTH) + resize(signed(bram_data2_i), SUM_WIDTH));
                -- Set BRAM addresses for the second pair of pixels for dxx1
                bram_addr1_next <= std_logic_vector(to_unsigned((to_integer(r) - to_integer(addSampleStep)) * IMG_WIDTH + (to_integer(c) + to_integer(addSampleStep) + 1), PIXEL_SIZE));
                bram_addr2_next <= std_logic_vector(to_unsigned((to_integer(r) + to_integer(addSampleStep) + 1) * IMG_WIDTH + to_integer(c), PIXEL_SIZE));
                state_next <= FetchDXX1_2;

            when FetchDXX1_2 =>
                -- Capture the data from BRAM for dxx1
                dxx1_sum_next <= std_logic_vector(resize(signed(dxx1_sum_reg), SUM_WIDTH) - resize(signed(bram_data1_i), SUM_WIDTH) - resize(signed(bram_data2_i), SUM_WIDTH));
                state_next <= ComputeDXX1;

            when ComputeDXX1 =>
                -- Final computation for dxx1
                dxx1_next <= dxx1_sum_reg;
                -- Set BRAM addresses for the first pair of pixels for dxx2
                bram_addr1_next <= std_logic_vector(to_unsigned((to_integer(r) + to_integer(addSampleStep) + 1) * IMG_WIDTH + to_integer(c + 1), PIXEL_SIZE));
                bram_addr2_next <= std_logic_vector(to_unsigned((to_integer(r) - to_integer(addSampleStep)) * IMG_WIDTH + (to_integer(c) - to_integer(addSampleStep)), PIXEL_SIZE));
                state_next <= FetchDXX2_1;

            when FetchDXX2_1 =>
                -- Capture the data from BRAM for dxx2
                dxx2_sum_next <= std_logic_vector(resize(signed(bram_data1_i), SUM_WIDTH) + resize(signed(bram_data2_i), SUM_WIDTH));
                -- Set BRAM addresses for the second pair of pixels for dxx2
                bram_addr1_next <= std_logic_vector(to_unsigned((to_integer(r) - to_integer(addSampleStep)) * IMG_WIDTH + (to_integer(c) + 1), PIXEL_SIZE));
                bram_addr2_next <= std_logic_vector(to_unsigned((to_integer(r) + to_integer(addSampleStep) + 1) * IMG_WIDTH + to_integer(c - to_integer(addSampleStep)), PIXEL_SIZE));
                state_next <= FetchDXX2_2;

            when FetchDXX2_2 =>
                -- Capture the data from BRAM for dxx2
                dxx2_sum_next <= std_logic_vector(resize(signed(dxx2_sum_reg), SUM_WIDTH) - resize(signed(bram_data1_i), SUM_WIDTH) - resize(signed(bram_data2_i), SUM_WIDTH));
                state_next <= ComputeDXX2;

            when ComputeDXX2 =>
                -- Final computation for dxx2
                dxx2_next <= dxx2_sum_reg;
                -- Set BRAM addresses for the first pair of pixels for dyy1
                bram_addr1_next <= std_logic_vector(to_unsigned((to_integer(r + 1) * IMG_WIDTH + to_integer(c - to_integer(addSampleStep))), PIXEL_SIZE));
                bram_addr2_next <= std_logic_vector(to_unsigned((to_integer(r - to_integer(addSampleStep)) * IMG_WIDTH + to_integer(c + to_integer(addSampleStep) + 1)), PIXEL_SIZE));
                state_next <= FetchDYY1_1;

            when FetchDYY1_1 =>
                -- Capture the data from BRAM for dyy1
                dyy1_sum_next <= std_logic_vector(resize(signed(bram_data1_i), SUM_WIDTH) + resize(signed(bram_data2_i), SUM_WIDTH));
                -- Set BRAM addresses for the second pair of pixels for dyy1
                bram_addr1_next <= std_logic_vector(to_unsigned((to_integer(r + 1) * IMG_WIDTH + to_integer(c - to_integer(addSampleStep))), PIXEL_SIZE));
                bram_addr2_next <= std_logic_vector(to_unsigned((to_integer(r - to_integer(addSampleStep)) * IMG_WIDTH + to_integer(c + to_integer(addSampleStep) + 1)), PIXEL_SIZE));
                state_next <= FetchDYY1_2;

            when FetchDYY1_2 =>
                -- Capture the data from BRAM for dyy1
                dyy1_sum_next <= std_logic_vector(resize(signed(dyy1_sum_reg), SUM_WIDTH) - resize(signed(bram_data1_i), SUM_WIDTH) - resize(signed(bram_data2_i), SUM_WIDTH));
                state_next <= ComputeDYY1;

            when ComputeDYY1 =>
                -- Final computation for dyy1
                dyy1_next <= dyy1_sum_reg;
                -- Set BRAM addresses for the first pair of pixels for dyy2
                bram_addr1_next <= std_logic_vector(to_unsigned((to_integer(r + to_integer(addSampleStep) + 1) * IMG_WIDTH + to_integer(c + to_integer(addSampleStep) + 1)), PIXEL_SIZE));
                bram_addr2_next <= std_logic_vector(to_unsigned(to_integer(r) * IMG_WIDTH + to_integer(c - to_integer(addSampleStep)), PIXEL_SIZE));
                state_next <= FetchDYY2_1;

            when FetchDYY2_1 =>
                -- Capture the data from BRAM for dyy2
                dyy2_sum_next <= std_logic_vector(resize(signed(bram_data1_i), SUM_WIDTH) + resize(signed(bram_data2_i), SUM_WIDTH));
                -- Set BRAM addresses for the second pair of pixels for dyy2
                bram_addr1_next <= std_logic_vector(to_unsigned((to_integer(r + to_integer(addSampleStep) + 1) * IMG_WIDTH + to_integer(c - to_integer(addSampleStep))), PIXEL_SIZE));
                bram_addr2_next <= std_logic_vector(to_unsigned(to_integer(r) * IMG_WIDTH + to_integer(c + to_integer(addSampleStep) + 1), PIXEL_SIZE));
                state_next <= FetchDYY2_2;

            when FetchDYY2_2 =>
                -- Capture the data from BRAM for dyy2
                dyy2_sum_next <= std_logic_vector(resize(signed(dyy2_sum_reg), SUM_WIDTH) - resize(signed(bram_data1_i), SUM_WIDTH) - resize(signed(bram_data2_i), SUM_WIDTH));
                state_next <= ComputeDYY2;

            when ComputeDYY2 =>
                -- Final computation for dyy2
                dyy2_next <= dyy2_sum_reg;
                state_next <= CalculateDerivatives;

            when CalculateDerivatives =>
                dxx_next <= std_logic_vector(resize(signed(weight) * (signed(dxx1) - signed(dxx2)), FIXED_SIZE+SUM_WIDTH)); 
                dyy_next <= std_logic_vector(resize(signed(weight) * (signed(dyy1) - signed(dyy2)), FIXED_SIZE+SUM_WIDTH)); 
                state_next <= ApplyOrientationTransform;

            when ApplyOrientationTransform =>
                dx_next <= std_logic_vector(resize(signed(i_cose) * signed(dxx) + signed(i_sine) * signed(dyy), 4*FIXED_SIZE + 2*SUM_WIDTH)); 
                dy_next <= std_logic_vector(resize(signed(i_sine) * signed(dxx) - signed(i_cose) * signed(dyy), 4*FIXED_SIZE + 2*SUM_WIDTH)); 
                state_next <= SetOrientations;

            when SetOrientations =>
                --if signed(dx) < 0 then
                if signed(dx(4*FIXED_SIZE + 2*SUM_WIDTH - 1 downto 4*FIXED_SIZE + 2*SUM_WIDTH - WIDTH)) < 0 then
                    ori1_next <= to_unsigned(0, WIDTH);
                else
                    ori1_next <= to_unsigned(1, WIDTH);
                end if;
                --if signed(dy) < 0 then
                if signed(dy(4*FIXED_SIZE + 2*SUM_WIDTH - 1 downto 4*FIXED_SIZE + 2*SUM_WIDTH - WIDTH)) < 0 then
                    ori2_next <= to_unsigned(2, WIDTH);
                else
                    ori2_next <= to_unsigned(3, WIDTH);
                end if;
                state_next <= UpdateIndex;

            when UpdateIndex =>
                -- Check rx and set ri accordingly
                if signed(rx) < 0 then
                    ri_next <= to_unsigned(0, WIDTH);
                elsif signed(rx) >= to_signed(INDEX_SIZE, 2*WIDTH + 2*FIXED_SIZE) then
                    ri_next <= to_unsigned(INDEX_SIZE - 1, WIDTH);
                else
                    --ri_next <= to_unsigned(to_integer(signed(rx)), WIDTH);
                    ri_next <= unsigned(rx(2*WIDTH + 2*FIXED_SIZE - 1 downto 2*WIDTH + 2*FIXED_SIZE - WIDTH));

                end if;

                -- Check ci and update ci accordingly
                if signed(cx) < 0 then
                    ci_next <= to_unsigned(0, WIDTH);
                elsif signed(cx) >= to_signed(INDEX_SIZE, 2*WIDTH + 2*FIXED_SIZE) then
                    ci_next <= to_unsigned(INDEX_SIZE - 1, WIDTH);
                else
                    --ci_next <= to_unsigned(to_integer(signed(cx)), WIDTH);
                    ci_next <= unsigned(cx(2*WIDTH + 2*FIXED_SIZE - 1 downto 2*WIDTH + 2*FIXED_SIZE - WIDTH));

                end if;
                    state_next <= ComputeFractionalComponents;
                 
           when ComputeFractionalComponents =>          
                -- Compute fractional components
                rfrac_next <= std_logic_vector(signed(rx) - signed(resize(ri, 2*WIDTH + 2*FIXED_SIZE)));
                cfrac_next <= std_logic_vector(signed(cx) - signed(resize(ci, 2*WIDTH + 2*FIXED_SIZE)));
                    state_next <= ValidateIndices;
                    
           when ValidateIndices =>
                if signed(rfrac) < 0 then
                    rfrac_next <= std_logic_vector(to_signed(0, 2*FIXED_SIZE + 2*WIDTH));
                elsif signed(rfrac) >= to_signed(1, 2*FIXED_SIZE + 2*WIDTH) then
                    rfrac_next <= std_logic_vector(to_signed(1, 2*FIXED_SIZE + 2*WIDTH));
                end if;
            
                if signed(cfrac) < 0 then
                    cfrac_next <= std_logic_vector(to_signed(0, 2*FIXED_SIZE + 2*WIDTH));
                elsif signed(cfrac) >= to_signed(1, 2*FIXED_SIZE + 2*WIDTH) then
                    cfrac_next <= std_logic_vector(to_signed(1, 2*FIXED_SIZE + 2*WIDTH));
                end if;
            
                state_next <= ComputeWeightsR;


            when ComputeWeightsR =>
                rweight1_next <= std_logic_vector(resize(unsigned(dx) * (unsigned(to_signed(1, 2*FIXED_SIZE + 2*WIDTH)) - unsigned(rfrac)), 6*FIXED_SIZE + 2*WIDTH + 2*SUM_WIDTH));
                rweight2_next <= std_logic_vector(resize(unsigned(dy) * (unsigned(to_signed(1, 2*FIXED_SIZE + 2*WIDTH)) - unsigned(rfrac)), 6*FIXED_SIZE + 2*WIDTH + 2*SUM_WIDTH));
                state_next <= ComputeWeightsC;
                            
            when ComputeWeightsC =>                

                cweight1_next <= std_logic_vector(resize(unsigned(rweight1) * (unsigned(to_signed(1, 2*FIXED_SIZE + 2*WIDTH)) - unsigned(cfrac)), 8*FIXED_SIZE + 4*WIDTH + 2*SUM_WIDTH));
                cweight1_next <= std_logic_vector(resize(unsigned(rweight2) * (unsigned(to_signed(1, 2*FIXED_SIZE + 2*WIDTH)) - unsigned(cfrac)), 8*FIXED_SIZE + 4*WIDTH + 2*SUM_WIDTH));
                state_next <= UpdateIndexArray;

            when UpdateIndexArray =>
                if ri >= 0 and ri < INDEX_SIZE and ci >= 0 and ci < INDEX_SIZE then
                    addr_do1_o <= std_logic_vector(to_unsigned((to_integer(unsigned(ri)) * (INDEX_SIZE * 4)) + to_integer(unsigned(ci)) * 4 + to_integer(unsigned(ori1)), 6));
                    data1_o_next_int <= std_logic_vector(resize(unsigned(data1_o_reg), 8*FIXED_SIZE + 4*WIDTH + 2*SUM_WIDTH) + resize(unsigned(cweight1) , 8*FIXED_SIZE + 4*WIDTH + 2*SUM_WIDTH));
                    c1_data_o <= '1';
            
                    addr_do2_o <= std_logic_vector(to_unsigned((to_integer(unsigned(ri)) * (INDEX_SIZE * 4)) + to_integer(unsigned(ci)) * 4 + to_integer(unsigned(ori2)), 6));
                    data1_o_next_int <= std_logic_vector(resize(unsigned(data2_o_reg), 8*FIXED_SIZE + 4*WIDTH + 2*SUM_WIDTH) + resize(unsigned(cweight2) , 8*FIXED_SIZE + 4*WIDTH + 2*SUM_WIDTH));
                    c2_data_o <= '1';
            
                    state_next <= CheckNextColumn;
                end if;
            
            when CheckNextColumn =>
                if ci + 1 < INDEX_SIZE then
                    addr_do1_o <= std_logic_vector(to_unsigned(to_integer(unsigned(ri)) * (INDEX_SIZE * 4) + to_integer(unsigned(ci+1)) * 4 + to_integer(unsigned(ori1)), 6));
                    data1_o_next_int <= std_logic_vector(resize(unsigned(data1_o_reg), 8*FIXED_SIZE + 4*WIDTH + 2*SUM_WIDTH) + resize(unsigned(rweight1) * resize(to_unsigned(to_integer(signed(cfrac)), 2*FIXED_SIZE + 2*WIDTH), 2*FIXED_SIZE + 2*WIDTH), 8*FIXED_SIZE + 4*WIDTH + 2*SUM_WIDTH));
                    c1_data_o <= '1';
            
                    addr_do2_o <= std_logic_vector(to_unsigned(to_integer(unsigned(ri)) * (INDEX_SIZE * 4) + to_integer(unsigned(ci+1)) * 4 + to_integer(unsigned(ori2)), 6));
                    data2_o_next_int <= std_logic_vector(resize(unsigned(data2_o_reg), 8*FIXED_SIZE + 4*WIDTH + 2*SUM_WIDTH) + resize(unsigned(rweight2) * resize(to_unsigned(to_integer(signed(cfrac)), 2*FIXED_SIZE + 2*WIDTH), 2*FIXED_SIZE + 2*WIDTH), 8*FIXED_SIZE + 4*WIDTH + 2*SUM_WIDTH));
                    c2_data_o <= '1';
            
                    state_next <= CheckNextRow;
                end if;
                
            when CheckNextRow =>
                if ri + 1 < INDEX_SIZE then
                    addr_do1_o <= std_logic_vector(to_unsigned(to_integer(unsigned(ri + 1)) * (INDEX_SIZE * 4) + to_integer(unsigned(ci)) * 4 + to_integer(unsigned(ori1)), 6));
                    data1_o_next_int <= std_logic_vector(resize(unsigned(data1_o_reg), 8 * FIXED_SIZE + 4 * WIDTH + 2 * SUM_WIDTH) + resize(unsigned(dx) * unsigned(rfrac) * (unsigned(to_signed(1, 2 * WIDTH + 2 * FIXED_SIZE)) - unsigned(cfrac)), 8 * FIXED_SIZE + 4 * WIDTH + 2 * SUM_WIDTH));
                    c1_data_o <= '1';
            
                    addr_do2_o <= std_logic_vector(to_unsigned(to_integer(unsigned(ri + 1)) * (INDEX_SIZE * 4) + to_integer(unsigned(ci)) * 4 + to_integer(unsigned(ori2)), 6));
                    data2_o_next_int <= std_logic_vector(resize(unsigned(data2_o_reg), 8 * FIXED_SIZE + 4 * WIDTH + 2 * SUM_WIDTH) + resize(unsigned(dy) * unsigned(rfrac) * (unsigned(to_signed(1, 2 * WIDTH + 2 * FIXED_SIZE)) - unsigned(cfrac)), 8 * FIXED_SIZE + 4 * WIDTH + 2 * SUM_WIDTH));
                    c2_data_o <= '1';
                end if;

    state_next <= NextSample;


            
            when NextSample =>
                j_next <= j_reg + 1;
                if (j_reg > to_integer(unsigned(2*iradius))) then
                    state_next <= IncrementI;
                else
                    state_next <= InnerLoop;
                end if;

            when IncrementI =>
                i_next <= i_reg + 1;
                if (i_reg > to_integer(unsigned(2*iradius))) then
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

    -- A?uriranje izlaznih portova iz internog signala za adrese
    bram_addr1_o <= bram_addr1_int;
    bram_addr2_o <= bram_addr2_int;
    rom_addr <= rom_addr_next;  -- A?uriranje rom_addr signala

end Behavioral;