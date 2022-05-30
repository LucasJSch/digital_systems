library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp_sum_tb is
end;

architecture fp_sum_tb_arch of fp_sum_tb is
	component fp_sum is
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
	a_tb <= '1' & "10000000" & "10000000000000000000000";
	b_tb <= '0' & "10000001" & "00101010101001010101001";

	DUT: fp_sum
		port map(
			clk => clk_tb,	
			a   => a_tb,
			b   => b_tb,
			z   => z_tb
		);
end;
