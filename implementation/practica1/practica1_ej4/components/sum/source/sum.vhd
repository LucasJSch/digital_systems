library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sum is
    generic(N_BITS : natural);
    port(
        x1_i : in  std_logic_vector(N_BITS-1 downto 0);
        x2_i : in  std_logic_vector(N_BITS-1 downto 0);
        y_o  : out std_logic_vector(N_BITS-1 downto 0)
    );
end entity;

architecture sum_arch of sum is
begin
	y_o <= std_logic_vector(unsigned(x1_i) + unsigned(x2_i));
end architecture;