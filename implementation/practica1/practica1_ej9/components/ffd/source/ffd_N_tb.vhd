library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ffd_N_tb is
end;

architecture ffd_N_tb_arq of ffd_N_tb is
	component ffd_N is
		generic(N : natural := 8);
    	port(
			clk     : in std_logic;
			d_i     : in std_logic_vector(N-1 downto 0);
			rst_i   : in std_logic;
			ena_i   : in std_logic;
			q_o     : out std_logic_vector(N-1 downto 0);
			q_neg_o : out std_logic_vector(N-1 downto 0)
    	);
	end component;

	signal N_tb       : integer := 4;
	signal clk_tb     : std_logic := '0';
	signal d_i_tb     : std_logic_vector(N_tb-1 downto 0) := (others => '0');
	signal rst_i_tb   : std_logic := '0';
	signal ena_i_tb   : std_logic := '1';
	signal q_o_tb     : std_logic_vector(N_tb-1 downto 0);
	signal q_neg_o_tb : std_logic_vector(N_tb-1 downto 0);

begin
	clk_tb   <= not clk_tb after 15 ns;
	d_i_tb   <= std_logic_vector(unsigned(d_i_tb) + 1) after 30 ns;
	-- rst_i_tb <= not rst_i_tb after 45 ns;
	ena_i_tb <= not ena_i_tb after 90 ns;

	DUT: ffd_N
		generic map(N => N_tb)
		port map(
			clk     => clk_tb,
			d_i     => d_i_tb,
			rst_i   => rst_i_tb,
			ena_i   => ena_i_tb,
			q_o     => q_o_tb,
			q_neg_o => q_neg_o_tb
		);
end;
