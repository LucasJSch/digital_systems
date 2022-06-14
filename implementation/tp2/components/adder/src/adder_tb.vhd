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
            carry_in  : in std_logic;
            Y         : out std_logic_vector(N-1 downto 0);
            carry_out : out std_logic);
    end component;

	signal X0_tb        : std_logic_vector(3 downto 0) := "0000";
	signal X1_tb        : std_logic_vector(3 downto 0) := "0100";
	signal carry_in_tb  : std_logic := '0';
	signal Y_tb         : std_logic_vector(3 downto 0);
	signal carry_out_tb : std_logic;

begin

	X0_tb       <= "0000" after 100 fs, "1100" after 150 fs, "1100" after 200 fs, "1011" after 250 fs, "1011" after 300 fs;
	carry_in_tb <=    '1' after 100 fs,    '0' after 150 fs,    '1' after 200 fs,    '0' after 250 fs,    '1' after 300 fs;

	DUT: adder
		port map(
			X0        => X0_tb,	
			X1        => X1_tb,
			carry_in  => carry_in_tb,
			carry_out => carry_out_tb,
			Y         => Y_tb);
end;
