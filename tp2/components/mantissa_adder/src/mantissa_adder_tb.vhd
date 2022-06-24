library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mantissa_adder_tb is
end;

architecture mantissa_adder_tb_arch of mantissa_adder_tb is
    component mantissa_adder is
		generic(N_BITS : integer := 32; EXPONENT_BITS : integer := 8);
	    port (
        A_sign     : in std_logic;
        B_sign     : in std_logic;
        A_mantissa : in std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
        B_mantissa : in std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
        
        result_sign     : out std_logic;
        result_mantissa : out std_logic_vector(N_BITS-EXPONENT_BITS downto 0));
    end component;

	constant N_BITS : integer := 6;
	constant EXPONENT_BITS : integer := 3;

	signal A_sign_tb          : std_logic := '0';
	signal B_sign_tb          : std_logic := '0';
	signal A_mantissa_tb      : std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
	signal B_mantissa_tb      : std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
	signal result_sign_tb     : std_logic;
	signal result_mantissa_tb : std_logic_vector(N_BITS-EXPONENT_BITS downto 0);

begin

	A_mantissa_tb <= "0111" after 10 fs, "0000" after 20 fs;
	B_mantissa_tb <= "0001" after 10 fs;

	DUT: mantissa_adder
		generic map(N_BITS, EXPONENT_BITS)
		port map(
			A_sign            => A_sign_tb,	
			B_sign        => B_sign_tb,
			A_mantissa => A_mantissa_tb,
			B_mantissa            => B_mantissa_tb,
			result_sign => result_sign_tb,
			result_mantissa => result_mantissa_tb);
end;
