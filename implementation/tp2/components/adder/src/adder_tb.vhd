library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adder_tb is
end;

architecture adder_tb_arch of adder_tb is
    component adder is
        generic(N: integer:= 4);
        port(
            X0        : in std_logic_vector(N-1 downto 0);
            X1        : in std_logic_vector(N-1 downto 0);
			substract : in std_logic;
			swap_ops  : in std_logic;
			Y         : out std_logic_vector(N-1 downto 0);
            carry_out : out std_logic);
    end component;

	signal X0_tb        : std_logic_vector(3 downto 0) := "0000";
	signal X1_tb        : std_logic_vector(3 downto 0) := "0100";
	signal Y_tb         : std_logic_vector(3 downto 0);
	signal carry_out_tb : std_logic;
	signal substract_tb : std_logic := '1';

begin

	X0_tb       <= "0000" after 10 fs,
				   "0001" after 20 fs,
				   "0010" after 30 fs,
				   "0011" after 40 fs,
				   "0100" after 50 fs,
				   "0101" after 60 fs,
				   "0110" after 70 fs,
				   "0111" after 80 fs,
				   "1000" after 90 fs,
				   "1001" after 100 fs,
				   "1010" after 110 fs,
				   "1011" after 120 fs,
				   "1100" after 130 fs,
				   "1101" after 140 fs,
				   "1110" after 150 fs,
				   "1111" after 160 fs;

	DUT: adder
		port map(
			X0        => X0_tb,	
			X1        => X1_tb,
			substract => substract_tb,
			swap_ops  => '1',
			carry_out => carry_out_tb,
			Y         => Y_tb);
end;
