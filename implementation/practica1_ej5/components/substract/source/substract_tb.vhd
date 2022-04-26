library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity substract_tb is
end;

architecture substract_tb_arq of substract_tb is
	component substract is
	generic(N_BITS : natural);
		port(
			x1_i : in  std_logic_vector(N_BITS-1 downto 0);
			x2_i : in  std_logic_vector(N_BITS-1 downto 0);
			y_o  : out std_logic_vector(N_BITS-1 downto 0)
		);
	end component;

	signal N : natural := 10;
	signal x1_i_tb: std_logic_vector(N-1 downto 0) := std_logic_vector(to_signed(0, N));
	signal x2_i_tb: std_logic_vector(N-1 downto 0) := std_logic_vector(to_signed(10, N));
	signal y_o_tb : std_logic_vector(N-1 downto 0);

begin
	x1_i_tb <= std_logic_vector(signed(x1_i_tb) + 1) after 15 ns;
	x2_i_tb <= std_logic_vector(signed(x2_i_tb) + 1) after 30 ns;

	DUT: substract
		generic map(
			N_BITS => N
		)
		port map(
			x1_i => x1_i_tb,
			x2_i => x2_i_tb,
			y_o => y_o_tb
		);
end;
