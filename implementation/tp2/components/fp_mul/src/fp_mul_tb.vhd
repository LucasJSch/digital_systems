library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp_mul_tb is
end;

architecture fp_mul_tb_arq of fp_mul_tb is
	component fp_mul is
        port(
			clk : in  std_logic;
			a   : in  std_logic_vector(31 downto 0);
			b   : out std_logic_vector(31 downto 0);
			z   : out std_logic_vector(31 downto 0)
        );
    end component;

	signal clk_tb : std_logic := '0';
	signal a_tb   : std_logic_vector(31 downto 0);
	signal b_tb   : std_logic_vector(31 downto 0);
	signal z_tb   : std_logic_vector(31 downto 0);

	signal abc : signed(3 downto 0);
	signal def : unsigned(3 downto 0);

begin

	abc <= to_signed(-3, 4);
	def <= unsigned(abc);

	clk_tb <= not clk_tb after 15 ps;
	a_tb <= '1' & "10000000" & "00000000000000000010101";
	b_tb <= '0' & "10000001" & "00000000000000000001110";

	DUT: fp_mul
		port map(
			clk => clk_tb,	
			a   => a_tb,
			b   => b_tb,
			z   => z_tb
		);
end;
