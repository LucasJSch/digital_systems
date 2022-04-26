library IEEE;
use IEEE.std_logic_1164.all;

entity negator is
	port(
		a_i: in std_logic;
		b_o: out std_logic
	);
end;

architecture neg_arq of negator is
begin
	b_o <= not a_i;
end;
