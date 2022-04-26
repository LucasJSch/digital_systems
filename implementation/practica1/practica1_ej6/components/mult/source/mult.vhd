library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mult is
    generic(N_BITS : natural);
    port(
        x1_i : in  std_logic_vector(N_BITS-1 downto 0);
        x2_i : in  std_logic_vector(N_BITS-1 downto 0);
        y_o  : out std_logic_vector((2*N_BITS)-1 downto 0)
    );
end entity;

architecture mult_arch of mult is
begin
	y_o <= std_logic_vector(signed(x1_i) * signed(x2_i));
end architecture;