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
use work.MyTypes.all;  -- Uklju?ivanje definisanih tipova iz paketa

-- Removed ieee.math_real.all; not typically needed for the types of operations described
-- use ieee.std_logic_unsigned.all; This package is generally considered deprecated in favor of numeric_std

--type real_array is array (integer range <>) of std_logic_vector 

entity ip is
    generic (
        WIDTH : integer := 11;            -- Bit width for various unsigned signals
        FIXED_SIZE : integer := 48;       -- Bit width for fixed-point operations
        INDEX_SIZE : integer := 4;        -- Dimension size for the index array
        ORI_SIZE : integer := 4;          -- Dimension size for orientation data
        PIXEL_ARRAY_SIZE : integer := 256;-- Not necessary if image size is constant
        LOOKUP2_SIZE : integer := 40;     -- Size of the lookup table
        IMG_WIDTH : integer := 128;       -- Width of the image
        IMG_HEIGHT : integer := 128       -- Height of the image
    );
    port (
        i_height : in unsigned(WIDTH - 1 downto 0);
        i_width : in unsigned(WIDTH - 1 downto 0);
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
        pixelMatrix : in pixel_matrix;--(IMG_WIDTH - 1 downto 0, IMG_HEIGHT - 1 downto 0);
      --  pixelMatrix : in pixel_matrix;
      --ROM  lookupTable2 : in real_array(0 to LOOKUP2_SIZE-1);
        index : out index_3d_array;

        start_i : in std_logic;
        ready_o : out std_logic
    );
end ip;


architecture Behavioral of ip is
-- Define the type for the lookup table
    type lookup_table_type is array (0 to LOOKUP2_SIZE-1) of std_logic_vector(15 downto 0);

    -- Define the constant lookup table
    constant lookupTable2 : lookup_table_type := (
        "1111000001100111", "1110000100010001", "1101010101000111", "1100101000111110",
        "1011111001010001", "1011011000110101", "1010110011100110", "1010010001000101",
        "1001110100101000", "1001011111011000", "1001000110011011", "1000110010111100",
        "1000011100011111", "1000001011100011", "0111111101101100", "0111110001010000",
        "0111100101000100", "0111011010010001", "0111010000100011", "0111000111111110",
        "0110111111011001", "0110111000100111", "0110110010110111", "0110101101100101",
        "0110101000101111", "0110100011101110", "0110011111001010", "0110011010110101",
        "0110010110101011", "0110010010100110", "0110001110111001", "0110001011010011",
        "0110000111101100", "0110000100100111", "0110000001011111", "0101111110100000",
        "0101111011101000", "0101111000111000", "0101110110010001", "0101110011101000"
    );
	type state_type is (idle, StartLoop, InnerLoop, BoundaryCheck, PositionValidation, ProcessSample,
		ComputeDerivatives, CalculateWeightedDerivatives, ApplyOrientationTransform,
		SetOrientations, UpdateIndex, ComputeWeights, UpdateIndexArray, CheckNextColumn, CheckNextRow,
		NextSample, IncrementI, Finish);
		
	

--KOJA VREDNOST IDE	I DA LI TREBA JER IMA U PORT constant iradius : integer := 3;  -- Define the radius

--za SIGNALE VIDETI KOJI JE TIP I SIRINA
	signal state_reg, state_next : state_type;

	signal i_reg, i_next : integer range -to_integer(unsigned(iradius)) to to_integer(unsigned(iradius));
	signal j_reg, j_next : integer range -to_integer(unsigned(iradius)) to to_integer(unsigned(iradius));
	
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
    signal px1, px2, px3, px4, px5, px6, px7, px8, px9, px10, px11, px12 : std_logic_vector(FIXED_SIZE-1 downto 0);
    signal px1_next, px2_next, px3_next, px4_next, px5_next, px6_next, px7_next, px8_next, px9_next, px10_next, px11_next, px12_next : std_logic_vector(FIXED_SIZE-1 downto 0);
    signal dxx1, dxx2, dyy1, dyy2 : std_logic_vector(FIXED_SIZE-1 downto 0);
    signal dxx1_next, dxx2_next, dyy1_next, dyy2_next : std_logic_vector(FIXED_SIZE-1 downto 0);

	signal indexMatrix : index_3d_array(0 to 3, 0 to 3, 0 to 3); 
   -- signal pixelMatrix : pixel_matrix(i_width - 1 downto 0, i_height - 1 downto 0);
    signal done : std_logic;

begin
	--State and data registers
	process (clk, reset)
	begin
		if reset = '1' then
			state_reg <= idle;
            i_reg <= -to_integer(unsigned(iradius));
			j_reg <= -to_integer(unsigned(iradius));
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
            px1 <= (others => '0');
            px2 <= (others => '0');
            px3 <= (others => '0');
            px4 <= (others => '0');
            px5 <= (others => '0');
            px6 <= (others => '0');
            px7 <= (others => '0');
            px8 <= (others => '0');
            px9 <= (others => '0');
            px10 <= (others => '0');
            px11 <= (others => '0');
            px12 <= (others => '0');
            dxx1 <= (others => '0');
            dxx2 <= (others => '0');
            dyy1 <= (others => '0');
            dyy2 <= (others => '0');
            
             for i in 0 to INDEX_SIZE-1 loop
                for j in 0 to INDEX_SIZE-1 loop
                    for k in 0 to ORI_SIZE-1 loop
						indexMatrix(i, j, k) <= to_signed(0, 48);
                    end loop;
                end loop;
            end loop;
            
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
            px1 <= px1_next; 
			px2 <= px2_next; 
			px3 <= px3_next; 
			px4 <= px4_next;
            px5 <= px5_next; 
			px6 <= px6_next; 
			px7 <= px7_next; 
			px8 <= px8_next;
            px9 <= px9_next; 
			px10 <= px10_next; 
			px11 <= px11_next; 
			px12 <= px12_next;
            dxx1 <= dxx1_next; 
			dxx2 <= dxx2_next; 
			dyy1 <= dyy1_next; 
			dyy2 <= dyy2_next;
        end if;
	end process;

	--Combinatorial circuits
	    -- Kombinacioni deo
    process (state_reg, start_i, i_height, i_width, iradius, fracr, fracc, spacing, iy, ix, step, i_cose, i_sine, scale, i_reg, j_reg, ri, ci, r, c, rx, cx, rfrac, cfrac, dx, dy, dxx, dyy, weight, rweight1, rweight2, cweight1, cweight2, ori1, ori2, px1, px2, px3, px4, px5, px6, px7, px8, px9, px10, px11, px12, dxx1, dxx2, dyy1, dyy2, rpos, cpos)
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
        px1_next <= px1;
        px2_next <= px2;
        px3_next <= px3;
        px4_next <= px4;
        px5_next <= px5;
        px6_next <= px6;
        px7_next <= px7;
        px8_next <= px8;
        px9_next <= px9;
        px10_next <= px10;
        px11_next <= px11;
        px12_next <= px12;
        dxx1_next <= dxx1;
        dxx2_next <= dxx2;
        dyy1_next <= dyy1;
        dyy2_next <= dyy2;
        rpos_next <= rpos;
        cpos_next <= cpos;

			ready_o <= '0';
 
			case state_reg is
				when idle =>
					ready_o <= '1';
					if start_i = '1' then
						state_next <= StartLoop;
					end if;
	
				when StartLoop =>
					i_next <= -to_integer(unsigned(iradius));
					j_next <= -to_integer(unsigned(iradius));
					state_next <= InnerLoop;
	
				when InnerLoop =>
					if j_reg > to_integer(unsigned(iradius)) then
						state_next <= IncrementI;
					else
						-- Compute positions
						rpos_next <= std_logic_vector(
							resize(
								to_unsigned(
									(to_integer(unsigned(step)) *
									(to_integer(unsigned(i_cose)) * i_reg + to_integer(unsigned(i_sine)) * j_reg) -
									to_integer(unsigned(fracr))) / to_integer(unsigned(spacing)),
									FIXED_SIZE  -- Make sure the width matches the size of rpos_next
								),
								FIXED_SIZE  -- Make sure the width matches the size of rpos_next
							)
						);
					
						cpos_next <= std_logic_vector(
							resize(
								to_unsigned(
									(to_integer(unsigned(step)) *
									(-to_integer(unsigned(i_sine)) * i_reg + to_integer(unsigned(i_cose)) * j_reg) -
									to_integer(unsigned(fracc))) / to_integer(unsigned(spacing)),
									FIXED_SIZE  -- Make sure the width matches the size of cpos_next
								),
								FIXED_SIZE  -- Make sure the width matches the size of cpos_next
							)
						);
						rx_next <= std_logic_vector(to_unsigned(to_integer(unsigned(rpos)), rpos'length) + to_unsigned(0, rpos'length) / 2 - 1);
                        cx_next <= std_logic_vector(to_unsigned(to_integer(unsigned(cpos)), cpos'length) + to_unsigned(0, cpos'length) / 2 - 1);
						state_next <= BoundaryCheck;
					end if;
	
				when BoundaryCheck =>
					if to_integer(unsigned(rx)) <= -1 or to_integer(unsigned(rx)) >= INDEX_SIZE or to_integer(unsigned(cx)) <= -1 or to_integer(unsigned(cx)) >= INDEX_SIZE then
						state_next <= NextSample;
					else
						state_next <= PositionValidation;
					end if;
	
				when PositionValidation =>
                addSampleStep_next <= unsigned(scale); 
 --DA LI U IF IDE _NEXT I GDE                
                if (r_next < 1 + addSampleStep_next or r_next >= i_height - 1 - addSampleStep_next or
					c_next < 1 + addSampleStep_next or c_next >= i_width - 1 - addSampleStep_next) then
						state_next <= NextSample;
					else
						state_next <= ProcessSample;
					end if;
	
				when ProcessSample =>
					weight_next <= lookupTable2(to_integer(unsigned(rpos) * unsigned(rpos) + unsigned(cpos) * unsigned(cpos)));
					state_next <= ComputeDerivatives;
	
				when ComputeDerivatives =>
				    px1_next <= std_logic_vector(pixelMatrix(to_integer(r + addSampleStep + 1), to_integer(c + addSampleStep + 1)));
                    px2_next <= std_logic_vector(pixelMatrix(to_integer(r - addSampleStep), to_integer(c)));
                    px3_next <= std_logic_vector(pixelMatrix(to_integer(r - addSampleStep), to_integer(c + addSampleStep + 1)));
                    px4_next <= std_logic_vector(pixelMatrix(to_integer(r + addSampleStep + 1), to_integer(c)));
                    px5_next <= std_logic_vector(pixelMatrix(to_integer(r + addSampleStep + 1), to_integer(c + 1)));
                    px6_next <= std_logic_vector(pixelMatrix(to_integer(r - addSampleStep), to_integer(c - addSampleStep)));
                    px7_next <= std_logic_vector(pixelMatrix(to_integer(r - addSampleStep), to_integer(c + 1)));
                    px8_next <= std_logic_vector(pixelMatrix(to_integer(r + addSampleStep + 1), to_integer(c - addSampleStep)));
                    px9_next <= std_logic_vector(pixelMatrix(to_integer(r + 1), to_integer(c + addSampleStep + 1)));
                    px10_next <= std_logic_vector(pixelMatrix(to_integer(r + 1), to_integer(c - addSampleStep)));
                    px11_next <= std_logic_vector(pixelMatrix(to_integer(r), to_integer(c - addSampleStep)));
                    px12_next <= std_logic_vector(pixelMatrix(to_integer(r), to_integer(c + addSampleStep + 1)));
					state_next <= CalculateWeightedDerivatives;
	
				when CalculateWeightedDerivatives =>
					dxx1_next <= std_logic_vector(signed(px1) + signed(px2) - signed(px3) - signed(px4));
                    dxx2_next <= std_logic_vector(signed(px5) + signed(px6) - signed(px7) - signed(px8));
                    dyy1_next <= std_logic_vector(signed(px9) + signed(px6) - signed(px3) - signed(px10));
                    dyy2_next <= std_logic_vector(signed(px1) + signed(px11) - signed(px12) - signed(px8));
					state_next <= ApplyOrientationTransform;
	
				when ApplyOrientationTransform =>
                    dx_next <= std_logic_vector(signed(i_cose) * signed(dxx1) - signed(i_sine) * signed(dyy1));					
                    dy_next <= std_logic_vector(signed(i_sine) * signed(dxx1) + signed(i_cose) * signed(dyy1));
                    if signed(dy_next) < 0 then
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
                        indexMatrix(to_integer(ri), to_integer(ci), to_integer(ori1)) <= indexMatrix(to_integer(ri), to_integer(ci), to_integer(ori1)) + to_integer(signed(cweight1));
                        indexMatrix(to_integer(ri), to_integer(ci), to_integer(ori2)) <= indexMatrix(to_integer(ri), to_integer(ci), to_integer(ori2)) + to_integer(signed(cweight2));
                    	state_next <= CheckNextColumn;
                	end if;

				when CheckNextColumn =>
					if ci + 1 < INDEX_SIZE then
                        indexMatrix(to_integer(ri), to_integer(ci) + 1, to_integer(ori1)) <= 
            indexMatrix(to_integer(ri), to_integer(ci) + 1, to_integer(ori1)) + 
            to_integer(unsigned(rweight1)) * to_integer(unsigned(cfrac));

        indexMatrix(to_integer(ri), to_integer(ci) + 1, to_integer(ori2)) <= 
            indexMatrix(to_integer(ri), to_integer(ci) + 1, to_integer(ori2)) + 
            to_integer(unsigned(rweight2)) * to_integer(unsigned(cfrac));
                        state_next <= CheckNextRow;
					end if;
	
				when CheckNextRow =>
					if ri + 1 < INDEX_SIZE then
						 indexMatrix(to_integer(ri) + 1, to_integer(ci), to_integer(ori1)) <= 
            indexMatrix(to_integer(ri) + 1, to_integer(ci), to_integer(ori1)) + 
            to_integer(signed(dx)) * to_integer(signed(rfrac)) * (1 - to_integer(signed(cfrac)));

        indexMatrix(to_integer(ri) + 1, to_integer(ci), to_integer(ori2)) <= 
            indexMatrix(to_integer(ri) + 1, to_integer(ci), to_integer(ori2)) + 
            to_integer(signed(dy)) * to_integer(signed(rfrac)) * (1 - to_integer(signed(cfrac)));			
						end if;
					state_next <= NextSample;
	
				when NextSample =>
					j_next <= j_reg + 1;
					state_next <= InnerLoop;
	
				when IncrementI =>
					i_next <= i_reg + 1;
					j_next <= -to_integer(unsigned(iradius));
					state_next <= StartLoop;
	
				when Finish =>
					done <= '1';
					state_next <= StartLoop;
	
				when others =>
					state_next <= StartLoop;
			end case;
		end process;
	
		index <= indexMatrix;
		
	end Behavioral;