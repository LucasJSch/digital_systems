library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity normalizer_tb is
end;

architecture normalizer_tb_arch of normalizer_tb is
    component normalizer is
        generic(N: integer:= 4; M: integer := 4);
        port(
            X            : in std_logic_vector(N-1 downto 0);
            g_bit        : in std_logic;
            shifted_bits : out unsigned(M-1 downto 0);
            Y            : out std_logic_vector(N-1 downto 0)
        );
    end component;

	signal X_tb            : std_logic_vector(3 downto 0) := "0000";
	signal g_bit_tb        : std_logic := '0';
	signal shifted_bits_tb : unsigned(3 downto 0);
	signal Y_tb            : std_logic_vector(3 downto 0);

begin

	X_tb <= "0101" after 50 ps, "1010" after 100 ps, "0001" after 150 ps, "0011" after 200 ps;

	DUT: normalizer
		port map(
			X            => X_tb,	
			g_bit        => g_bit_tb,
			shifted_bits => shifted_bits_tb,
			Y            => Y_tb
		);
end;
