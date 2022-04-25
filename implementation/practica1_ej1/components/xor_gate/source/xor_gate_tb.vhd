library IEEE;
use IEEE.std_logic_1164.all;

entity xor_gate_tb is
end;

architecture xor_gate_tb_arq of xor_gate_tb is

    component xor_gate is
        port (
            x1_i: in std_logic;
            x2_i: in std_logic;
            y_o: out std_logic
        );
    end component;

	signal x1_i_tb: std_logic := '0';
	signal x2_i_tb: std_logic := '0';
	signal y_o_tb: std_logic;
begin

	x1_i_tb <= '1' after 10 ns, '0' after 310 ns;
	x2_i_tb <= '1' after 10 ns, '0' after 160 ns, '1' after 310 ns, '0' after 460 ns, '1' after 610 ns;

	DUT: xor_gate
		port map(
			x1_i => x1_i_tb,
			x2_i => x2_i_tb,
			y_o => y_o_tb
		);

end;
