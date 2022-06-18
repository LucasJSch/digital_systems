library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp_sum_tb is
end;

architecture fp_sum_tb_arch of fp_sum_tb is
	component fp_sum is
		generic(
			N_BITS : integer := 32;
			EXPONENT_BITS : integer := 8);
		port(
			clk           : in std_logic;
			a             : in std_logic_vector(N_BITS-1 downto 0);
			b             : in std_logic_vector(N_BITS-1 downto 0);
			z             : out std_logic_vector(N_BITS-1 downto 0)
		);
    end component;

	constant N_BITS : integer := 30;
	constant N_EXP_BITS : integer := 8;

	signal clk_tb : std_logic := '0';
	signal a_tb   : std_logic_vector(N_BITS-1 downto 0);
	signal b_tb   : std_logic_vector(N_BITS-1 downto 0);
	signal z_tb   : std_logic_vector(N_BITS-1 downto 0);

begin

	clk_tb <= not clk_tb after 15 ps;
	a_tb <= "001111100110011111010111101001";
	b_tb <= "001111110010101001001110101100";

	DUT: fp_sum
		generic map(N_BITS, N_EXP_BITS)
		port map(
			clk => clk_tb,	
			a   => a_tb,
			b   => b_tb,
			z   => z_tb
		);
end;
