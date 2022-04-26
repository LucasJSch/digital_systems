library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity despl_tb is
end;

architecture despl_tb_arq of despl_tb is
	component despl is
		generic(N : natural := 8);
		port(
			clk     : in std_logic;
			d_i     : in std_logic;
			rst_i   : in std_logic;
			q_o     : out std_logic_vector(N-1 downto 0)
		);
	end component;

	signal N_tb       : integer := 6;
	signal clk_tb     : std_logic := '0';
	signal d_i_tb     : std_logic := '0';
	signal rst_i_tb   : std_logic := '0';
	signal q_o_tb     : std_logic_vector(N_tb-1 downto 0);

begin
	clk_tb   <= not clk_tb after 15 ns;
	d_i_tb   <= '1' after 30 ns, '0' after 90 ns, '1' after 150 ns, '0' after 240 ns, '1' after 270 ns, '0' after 300 ns; 
	rst_i_tb <= not rst_i_tb after 360 ns;

	DUT: despl
		generic map(N => N_tb)
		port map(
			clk     => clk_tb,
			d_i     => d_i_tb,
			rst_i   => rst_i_tb,
			q_o     => q_o_tb
		);
end;
