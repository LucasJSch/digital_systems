library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp_math_unit_tb is
end;

architecture fp_math_unit_tb_arch of fp_math_unit_tb is
	component fp_math_unit is
		generic(
			N_BITS : integer := 32;
			EXPONENT_BITS : integer := 8);
        port(
            clk           : in std_logic;
            a             : in std_logic_vector(N_BITS-1 downto 0);
            b             : in std_logic_vector(N_BITS-1 downto 0);
        	-- 00: Sum; 01: Substract ; 10: Multiply; 11: Sum.
            ctrl          : in std_logic_vector(1 downto 0);
            z             : out std_logic_vector(N_BITS-1 downto 0));
    end component;

	constant N_BITS : integer := 32;
	constant N_EXP_BITS : integer := 8;

	signal clk_tb  : std_logic := '0';
	signal a_tb    : std_logic_vector(N_BITS-1 downto 0);
	signal b_tb    : std_logic_vector(N_BITS-1 downto 0);
	signal z_tb    : std_logic_vector(N_BITS-1 downto 0);
	signal ctrl_tb : std_logic_vector(1 downto 0) := "00";

begin

	clk_tb <= not clk_tb after 15 ps;
	ctrl_tb <= "01" after 10 fs, "10" after 20 fs, "11" after 30 fs;
	a_tb <= "11111111011111110001010000000100";
	b_tb <= "00111110000110111001010111010101";

	DUT: fp_math_unit
		generic map(N_BITS, N_EXP_BITS)
		port map(
			clk  => clk_tb,	
			a    => a_tb,
			b    => b_tb,
            ctrl => ctrl_tb,
			z    => z_tb
		);
end;
