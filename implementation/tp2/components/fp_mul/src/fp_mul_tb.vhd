library IEEE;
use IEEE.std_logic_1164.all;

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

begin

	clk_tb <= not clk_tb after 15 ps;
	a_tb <= '0' & "00000001" & "01010101010101001010101";
	b_tb <= '0' & "00000001" & "01010101010101001010101";

	DUT: fp_mul
		port map(
			clk => clk_tb,	
			a   => a_tb,
			b   => b_tb,
			z   => z_tb
		);
end;
