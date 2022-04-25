library IEEE;
use IEEE.std_logic_1164.all;

entity negator_tb is
end;

architecture negator_tb_arq of negator_tb is

	component negator is
		port(
			a_i: in std_logic;
			b_o: out std_logic
		);
	end component;

	signal a_tb: std_logic := '0';
	signal b_tb: std_logic;
begin

	a_tb <= '1' after 150 ns, '0' after 300 ns, '1' after 450 ns;

	DUT: negator
		port map(
			a_i => a_tb,
			b_o => b_tb
		);

end;
