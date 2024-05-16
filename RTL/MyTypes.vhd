library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package MyTypes is
    constant IMG_WIDTH : integer := 128;
    constant IMG_HEIGHT : integer := 128;
    
    subtype pixel_type is signed(47 downto 0);
    type pixel_matrix is array (0 to IMG_WIDTH - 1, 0 to IMG_HEIGHT - 1) of pixel_type;
    --type real_vector is array (natural range <>) of real;
    type index_3d_array is array (0 to 3, 0 to 3, 0 to 3) of signed(47 downto 0);
end MyTypes;