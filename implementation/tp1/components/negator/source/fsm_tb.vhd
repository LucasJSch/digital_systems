library IEEE;
use IEEE.std_logic_1164.all;

entity fsm_tb is
end;

architecture fsm_tb_arq of fsm_tb is

	component fsm is
	end component;

begin
	DUT: fsm
		port map(
			a => b
		);
end;
