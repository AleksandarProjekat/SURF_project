----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 02/16/2024 12:10:51 PM
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


-- Removed ieee.math_real.all; not typically needed for the types of operations described
-- use ieee.std_logic_unsigned.all; This package is generally considered deprecated in favor of numeric_std

entity ip is
    generic (
        WIDTH : integer := 11;            -- Bit width for various unsigned signals
        FIXED_SIZE : integer := 48;       -- Bit width for fixed-point operations
        INDEX_SIZE : integer := 4;        -- Dimension size for the index array
        ORI_SIZE : integer := 4;          -- Dimension size for orientation data
        LOOKUP2_SIZE : integer := 40;     -- Size of the lookup table
        IMG_WIDTH : integer := 128;       -- Width of the image
        IMG_HEIGHT : integer := 128       -- Height of the image
        --
    );
    port (
        i_height : in unsigned(WIDTH - 1 downto 0);
        i_width : in unsigned(WIDTH - 1 downto 0);
        clk : in std_logic;
        reset : in std_logic;
        iradius : in signed(WIDTH - 1 downto 0);
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
		addr_di_o : out std_logic_vector (4 * WIDTH - 1 downto 0);
		data_i : in std_logic_vector (7 downto 0);
		ctrl_data_o : out std_logic;
		---------------MEM INTERFEJS ZA IZLAZ--------------------
		addr_do_o : out std_logic_vector (4 * WIDTH - 1 downto 0);
		data_o : out std_logic_vector (3 * WIDTH - 1 downto 0);
		c_data_o : out std_logic;
		---------------INTERFEJS ZA ROM--------------------
        rom_addr : out std_logic_vector(5 downto 0);  -- Izlazna adresa za ROM, pretpostavlja se 6 bita za adresiranje
        rom_data : in std_logic_vector(FIXED_SIZE - 1 downto 0);  -- Ulazni podaci iz ROM-a
		---------------KOMANDNI INTERFEJS------------------------
        start_i : in std_logic;
         ---------------STATUSNI INTERFEJS------------------------
        ready_o : out std_logic
    );
end ip;


architecture Behavioral of ip is


	type state_type is (idle, StartLoop, InnerLoop, BoundaryCheck, PositionValidation, ProcessSample,
		ComputeDerivatives, CalculateDerivatives, ApplyOrientationTransform,
		SetOrientations, UpdateIndex, ComputeWeights, UpdateIndexArray, CheckNextColumn, CheckNextRow,
		NextSample, IncrementI, Finish);
		

--za SIGNALE VIDETI KOJI JE TIP I SIRINA
	signal state_reg, state_next : state_type;

	
	signal i_reg, i_next : unsigned(WIDTH - 1 downto 0) := to_unsigned(23, WIDTH);
    signal j_reg, j_next : unsigned(WIDTH - 1 downto 0) := to_unsigned(23, WIDTH);
	signal ri, ci : unsigned(WIDTH - 1 downto 0);
    signal ri_next, ci_next : unsigned(WIDTH - 1 downto 0);
	signal r, c : unsigned(WIDTH - 1 downto 0);
	signal r_next, c_next : unsigned(WIDTH - 1 downto 0);	
	signal addSampleStep, addSampleStep_next : unsigned(WIDTH - 1 downto 0);		
	signal rpos, cpos : std_logic_vector(FIXED_SIZE-1 downto 0);
    signal rpos_next, cpos_next : std_logic_vector(FIXED_SIZE-1 downto 0);
    signal rx, cx, rfrac, cfrac, dx, dy, dxx, dyy, weight :  std_logic_vector(FIXED_SIZE-1 downto 0);
    signal rx_next, cx_next, rfrac_next, cfrac_next, dx_next, dy_next, dxx_next, dyy_next, weight_next : std_logic_vector(FIXED_SIZE-1 downto 0);
    signal rweight1, rweight2, cweight1, cweight2 : std_logic_vector(FIXED_SIZE-1 downto 0);
    signal rweight1_next, rweight2_next, cweight1_next, cweight2_next : std_logic_vector(FIXED_SIZE-1 downto 0);
    signal ori1, ori2 : unsigned(WIDTH - 1 downto 0);
    signal ori1_next, ori2_next : unsigned(WIDTH - 1 downto 0);
   
    signal dxx1, dxx2, dyy1, dyy2 : std_logic_vector(FIXED_SIZE-1 downto 0);
    signal dxx1_next, dxx2_next, dyy1_next, dyy2_next : std_logic_vector(FIXED_SIZE-1 downto 0);

    signal done : std_logic;
    
    signal pixels1D : std_logic_vector(IMG_WIDTH * IMG_HEIGHT * 8 - 1 downto 0);

begin
	--State and data registers
	process (clk, reset)
	begin
		if reset = '1' then
			state_reg <= idle;
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
            
		elsif (rising_edge(clk)) then
			state_reg <= state_next;
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
        end if;
	end process;

	--Combinatorial circuits
	    -- Kombinacioni deo
    process (state_reg, start_i, i_height, i_width, iradius, fracr, fracc, spacing, iy, ix, step, i_cose, i_sine, scale, i_reg, j_reg, ri, ci, r, c, rx, cx, rfrac, cfrac, dx, dy, dxx, dyy, weight, rweight1, rweight2, cweight1, cweight2, ori1, ori2, dxx1, dxx2, dyy1, dyy2, rpos, cpos)
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
   
   --VIDETI NA KOJE VREDNOSTI IDU addr_di_o    addr_do_o
      
        addr_di_o <= std_logic_vector(unsigned(r) * unsigned(i_width) + unsigned(c));
        pixels1D(to_integer(unsigned(r) * unsigned(i_width) + unsigned(c)) * 3 + 2 downto to_integer(unsigned(r) * unsigned(i_width) + unsigned(c)) * 3) <= data_i;

		--	addr_do_o <= --std_logic_vector((i_reg * unsigned(cols_i) + j_reg) * 4);		

			ctrl_data_o <= '1';
			
			c_data_o <= '0';

			data_o <= (others => '0');

			ready_o <= '0';
 
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
						-- Compute positions
						
rpos_next <= std_logic_vector(
    resize(
        to_unsigned(
            shift_right(
                to_integer(
                    unsigned(step) * (  -- Convert 'step' to integer after casting to unsigned
                        to_integer(unsigned(i_cose)) * (to_integer(unsigned(i_reg)) - to_integer(unsigned(iradius))) + 
                        to_integer(unsigned(i_sine)) * (to_integer(unsigned(j_reg)) - to_integer(unsigned(iradius))) -
                        to_integer(unsigned(fracr))
                    )
                ), 30  -- Shift right to adjust the fixed-point scale
            ) / to_integer(unsigned(spacing)),  -- Division by 'spacing' after converting it to integer
            FIXED_SIZE  -- Resize to the FIXED_SIZE
        ), 
        FIXED_SIZE  -- Ensure the final output matches the fixed size needed
    )
);



                        
                        cpos_next <= std_logic_vector(
                            resize(
                                to_unsigned(
                                    (to_integer(unsigned(step)) *
                                     (-to_integer(unsigned(i_sine)) * (to_integer(signed(i_reg)) - to_integer(signed(iradius))) + 
                                      to_integer(unsigned(i_cose)) * (to_integer(signed(j_reg)) - to_integer(signed(iradius)))) -
                                     to_integer(unsigned(fracc))) / to_integer(unsigned(spacing)),
                                FIXED_SIZE
                            ),
                            FIXED_SIZE
                        ));

                        
                        
						rx_next <= std_logic_vector(to_unsigned(to_integer(unsigned(rpos)), rpos'length) + to_unsigned(0, rpos'length) / 2 - 1);
                        cx_next <= std_logic_vector(to_unsigned(to_integer(unsigned(cpos)), cpos'length) + to_unsigned(0, cpos'length) / 2 - 1);
						state_next <= BoundaryCheck;
						
				when BoundaryCheck =>
					if to_integer(unsigned(rx)) <= -1 or to_integer(unsigned(rx)) >= INDEX_SIZE or to_integer(unsigned(cx)) <= -1 or to_integer(unsigned(cx)) >= INDEX_SIZE then
						state_next <= NextSample;
					else
						state_next <= PositionValidation;
					end if;
	
				when PositionValidation =>
                addSampleStep_next <= unsigned(scale); 
              
                r_next <= iy + to_unsigned(to_integer(signed(i_reg)) - to_integer(iradius), WIDTH) * step;
                c_next <= ix + to_unsigned(to_integer(signed(j_reg)) - to_integer(iradius), WIDTH) * step;
 --DA LI U IF IDE _NEXT I GDE                
                if (r_next < 1 + addSampleStep or r_next >= i_height - 1 - addSampleStep or
					c_next < 1 + addSampleStep or c_next >= i_width - 1 - addSampleStep) then
						state_next <= NextSample;
					else
						state_next <= ProcessSample;
					end if;
	
				when ProcessSample =>
					rom_addr <= std_logic_vector(to_unsigned(to_integer(unsigned(rpos) * unsigned(rpos) + unsigned(cpos) * unsigned(cpos)), 6)); -- Izra?unavanje adrese za ROM
                    weight_next <= rom_data;  -- ?itanje težine direktno iz ROM-a
					state_next <= ComputeDerivatives;
	
				when ComputeDerivatives =>
                        dxx1_next <= pixels1D(to_integer((unsigned(r) + unsigned(addSampleStep) + 1) * unsigned(i_width) + (unsigned(c) + unsigned(addSampleStep) + 1)) * 3 + 2 downto to_integer((unsigned(r) + unsigned(addSampleStep) + 1) * unsigned(i_width) + (unsigned(c) + unsigned(addSampleStep) + 1)) * 3)
                      + pixels1D(to_integer((unsigned(r) - unsigned(addSampleStep)) * unsigned(i_width) + unsigned(c)) * 3 + 2 downto to_integer((unsigned(r) - unsigned(addSampleStep)) * unsigned(i_width) + unsigned(c)) * 3)
                      - pixels1D(to_integer((unsigned(r) - unsigned(addSampleStep)) * unsigned(i_width) + (unsigned(c) + unsigned(addSampleStep) + 1)) * 3 + 2 downto to_integer((unsigned(r) - unsigned(addSampleStep)) * unsigned(i_width) + (unsigned(c) + unsigned(addSampleStep) + 1)) * 3)
                      - pixels1D(to_integer((unsigned(r) + unsigned(addSampleStep) + 1) * unsigned(i_width) + unsigned(c)) * 3 + 2 downto to_integer((unsigned(r) + unsigned(addSampleStep) + 1) * unsigned(i_width) + unsigned(c)) * 3);

                dxx2_next <= pixels1D(to_integer((unsigned(r) + unsigned(addSampleStep) + 1) * unsigned(i_width) + (unsigned(c) + 1)) * 3 + 2 downto to_integer((unsigned(r) + unsigned(addSampleStep) + 1) * unsigned(i_width) + (unsigned(c) + 1)) * 3)
                      + pixels1D(to_integer((unsigned(r) - unsigned(addSampleStep)) * unsigned(i_width) + (unsigned(c) - unsigned(addSampleStep))) * 3 + 2 downto to_integer((unsigned(r) - unsigned(addSampleStep)) * unsigned(i_width) + (unsigned(c) - unsigned(addSampleStep))) * 3)
                      - pixels1D(to_integer((unsigned(r) - unsigned(addSampleStep)) * unsigned(i_width) + (unsigned(c) + 1)) * 3 + 2 downto to_integer((unsigned(r) - unsigned(addSampleStep)) * unsigned(i_width) + (unsigned(c) + 1)) * 3)
                      - pixels1D(to_integer((unsigned(r) + unsigned(addSampleStep) + 1) * unsigned(i_width) + (unsigned(c) - unsigned(addSampleStep))) * 3 + 2 downto to_integer((unsigned(r) + unsigned(addSampleStep) + 1) * unsigned(i_width) + (unsigned(c) - unsigned(addSampleStep))) * 3);

                dyy1_next <= pixels1D(to_integer((unsigned(r) + 1) * unsigned(i_width) + (unsigned(c) + unsigned(addSampleStep) + 1)) * 3 + 2 downto to_integer((unsigned(r) + 1) * unsigned(i_width) + (unsigned(c) + unsigned(addSampleStep) + 1)) * 3)
                      + pixels1D(to_integer((unsigned(r) - unsigned(addSampleStep)) * unsigned(i_width) + (unsigned(c) - unsigned(addSampleStep))) * 3 + 2 downto to_integer((unsigned(r) - unsigned(addSampleStep)) * unsigned(i_width) + (unsigned(c) - unsigned(addSampleStep))) * 3)
                      - pixels1D(to_integer((unsigned(r) - unsigned(addSampleStep)) * unsigned(i_width) + (unsigned(c) + unsigned(addSampleStep) + 1)) * 3 + 2 downto to_integer((unsigned(r) - unsigned(addSampleStep)) * unsigned(i_width) + (unsigned(c) + unsigned(addSampleStep) + 1)) * 3)
                      - pixels1D(to_integer((unsigned(r) + 1) * unsigned(i_width) + (unsigned(c) - unsigned(addSampleStep))) * 3 + 2 downto to_integer((unsigned(r) + 1) * unsigned(i_width) + (unsigned(c) - unsigned(addSampleStep))) * 3);

                dyy2_ne <= pixels1D(to_integer((unsigned(r) + unsigned(addSampleStep) + 1) * unsigned(i_width) + (unsigned(c) + unsigned(addSampleStep) + 1)) * 3 + 2 downto to_integer((unsigned(r) + unsigned(addSampleStep) + 1) * unsigned(i_width) + (unsigned(c) + unsigned(addSampleStep) + 1)) * 3)
                      + pixels1D(to_integer(unsigned(r) * unsigned(i_width) + (unsigned(c) - unsigned(addSampleStep))) * 3 + 2 downto to_integer(unsigned(r) * unsigned(i_width) + (unsigned(c) - unsigned(addSampleStep))) * 3)
                      - pixels1D(to_integer(unsigned(r) * unsigned(i_width) + (unsigned(c) + unsigned(addSampleStep) + 1)) * 3 + 2 downto to_integer(unsigned(r) * unsigned(i_width) + (unsigned(c) + unsigned(addSampleStep) + 1)) * 3)
                      - pixels1D(to_integer((unsigned(r) + unsigned(addSampleStep) + 1) * unsigned(i_width) + (unsigned(c) - unsigned(addSampleStep))) * 3 + 2 downto to_integer((unsigned(r) + unsigned(addSampleStep) + 1) * unsigned(i_width) + (unsigned(c) - unsigned(addSampleStep))) * 3);
	            when CalculateDerivatives =>
	               dxx_next <= weight * (dxx1 - dxx2);
	               dyy_next <= weight * (dyy1 - dyy2);
	               state_next <= ApplyOrientationTransform;
	               
				when ApplyOrientationTransform =>
                    --dx_next <= std_logic_vector(signed(i_cose) * signed(dxx) + signed(i_sine) * signed(dyy)); -- Old
                    dx_next <= std_logic_vector(shift_right(signed(i_cose) * signed(dxx) + signed(i_sine) * signed(dyy), 30)); -- Adjusted for fixed-point
                    dy_next <= std_logic_vector(signed(i_sine) * signed(dxx) - signed(i_cose) * signed(dyy));
                    state_next <= SetOrientations;
                    
                when SetOrientations =>    
                    if signed(dx_next) < 0 then
						ori1_next <= to_unsigned(0, WIDTH);
					else
						ori1_next <= to_unsigned(1, WIDTH);
					end if;
                    if signed(dy_next) < 0 then
						ori2_next <= to_unsigned(2, WIDTH);
					else
						ori2_next <= to_unsigned(3, WIDTH);
					end if;
					state_next <= UpdateIndex;
	
				when UpdateIndex =>
					-- Check rx and set ri accordingly
					if signed(rx) < 0 then
						ri_next <= to_unsigned(0, WIDTH);
					elsif signed(rx) >= INDEX_SIZE then
                        ri_next <= to_unsigned(INDEX_SIZE - 1, WIDTH);
					else
                        ri_next <= to_unsigned(to_integer(signed(rx)), WIDTH);  
					end if;
	
					-- Check ci and update ci accordingly
					if signed(cx) < 0 then
						ci_next <= to_unsigned(0, WIDTH);
					elsif signed(cx) >= INDEX_SIZE then
						ci_next <= to_unsigned(INDEX_SIZE - 1, WIDTH);
					else
						ci_next <= to_unsigned(to_integer(signed(cx)), WIDTH); 
					end if;
	
					-- Compute fractional components
					rfrac_next <= std_logic_vector(signed(rx) - signed(ri));
                    cfrac_next <= std_logic_vector(signed(cx) - signed(ci));
	
					if signed(rfrac_next) < 0 then
                        rfrac_next <= std_logic_vector(to_signed(0, rfrac_next'length));
                    elsif signed(rfrac_next) >= 2**WIDTH then
                        rfrac_next <= std_logic_vector(to_signed(2**WIDTH - 1, rfrac_next'length));
                    end if;
            
                    if signed(cfrac_next) < 0 then
                        cfrac_next <= std_logic_vector(to_signed(0, cfrac_next'length));
                    elsif signed(cfrac_next) >= 2**WIDTH then
                        cfrac_next <= std_logic_vector(to_signed(2**WIDTH - 1, cfrac_next'length));
                    end if;
            
					state_next <= ComputeWeights;
	
				when ComputeWeights =>
				    rweight1_next <= std_logic_vector(resize(unsigned(dx) * (unsigned((2**WIDTH - 1) - unsigned(rfrac_next))), FIXED_SIZE));
                    rweight2_next <= std_logic_vector(resize(unsigned(dx) * unsigned(rfrac_next), FIXED_SIZE));
                    cweight1_next <= std_logic_vector(resize(unsigned(rweight1) * (unsigned((2**WIDTH - 1) - unsigned(cfrac_next))), FIXED_SIZE));
                    cweight2_next <= std_logic_vector(resize(unsigned(rweight2) * unsigned(cfrac_next), FIXED_SIZE));
					state_next <= UpdateIndexArray;

--PROVERITI GDE IDE _NEXT A GDE NE IDE
				when UpdateIndexArray =>
                	if ri >= 0 and ri < INDEX_SIZE and ci >= 0 and ci < INDEX_SIZE then
                        index1D[ri * (INDEX_SIZE * 4) + ci * 4 + ori1] += cweight1;
			            index1D[ri * (INDEX_SIZE * 4) + ci * 4 + ori2] += cweight2;
                    	
                    	state_next <= CheckNextColumn;
                	end if;

				when CheckNextColumn =>
					if ci + 1 < INDEX_SIZE then
                        index1D[ri * (INDEX_SIZE * 4) + (ci + 1) * 4 + ori1] += rweight1 * cfrac;
			            index1D[ri * (INDEX_SIZE * 4) + (ci + 1) * 4 + ori2] += rweight2 * cfrac;
			            
                        state_next <= CheckNextRow;
					end if;
	
				when CheckNextRow =>
					if ri + 1 < INDEX_SIZE then
						 index1D[(ri + 1) * (INDEX_SIZE * 4) + ci * 4 + ori1] += dx * rfrac * (1.0 - cfrac);
			             index1D[(ri + 1) * (INDEX_SIZE * 4) + ci * 4 + ori2] += dy * rfrac * (1.0 - cfrac);	
			             	
					end if;
					
					state_next <= NextSample;
--- OD 0 DO 2*IRADIUS	
				when NextSample =>
					j_next <= j_reg + 1;
					if (j_next > to_integer(unsigned(2*iradius))) then
					   state_next <= IncrementI;
					else
					   state_next <= InnerLoop;
	                end if;
				when IncrementI =>
					i_next <= i_reg + 1;
					if (i_next > to_integer(unsigned(2*iradius))) then
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
	
		
	end Behavioral;