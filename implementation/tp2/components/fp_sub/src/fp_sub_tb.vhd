library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp_sub_tb is
end;

architecture fp_sub_tb_arch of fp_sub_tb is
	component fp_sub is
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

	constant N_BITS : integer := 32;
	constant N_EXP_BITS : integer := 8;

	signal clk_tb : std_logic := '0';
	signal a_tb   : std_logic_vector(N_BITS-1 downto 0);
	signal b_tb   : std_logic_vector(N_BITS-1 downto 0);
	signal z_tb   : std_logic_vector(N_BITS-1 downto 0);

begin

	clk_tb <= not clk_tb after 15 ps;
	a_tb <= "00111101110001000111000000100000";
	b_tb <= "00111110110101010111010001000100";

	DUT: fp_sub
		generic map(N_BITS, N_EXP_BITS)
		port map(
			clk => clk_tb,	
			a   => a_tb,
			b   => b_tb,
			z   => z_tb
		);
end;
