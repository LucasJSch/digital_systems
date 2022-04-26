library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity substract is
    generic(N_BITS : natural);
    port(
        x1_i : in  std_logic_vector(N_BITS-1 downto 0);
        x2_i : in  std_logic_vector(N_BITS-1 downto 0);
        y_o  : out std_logic_vector(N_BITS-1 downto 0)
    );
end entity;

architecture substract_arch of substract is
begin
	y_o <= std_logic_vector(signed(x1_i) - signed(x2_i));
end architecture;