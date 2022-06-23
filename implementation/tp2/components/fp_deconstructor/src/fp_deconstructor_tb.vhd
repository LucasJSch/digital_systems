library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp_deconstructor_tb is
end;

architecture fp_deconstructor_tb_arch of fp_deconstructor_tb is
    component fp_deconstructor is
		generic(N_BITS : integer := 32; EXPONENT_BITS : integer := 8);
        port (
        A          : in std_logic_vector(N_BITS-1 downto 0);
        B          : in std_logic_vector(N_BITS-1 downto 0);
 
        A_sign     : out std_logic;
        B_sign     : out std_logic;
        --One bit is added for signed subtraction
        A_exp      : out std_logic_vector(EXPONENT_BITS downto 0);
        B_exp      : out std_logic_vector(EXPONENT_BITS downto 0);
        -- Two bits are added to mantissas.
        -- One for leading 1 and other one for storing carry.
        A_mantissa : out std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
        B_mantissa : out std_logic_vector(N_BITS-EXPONENT_BITS downto 0));
    end component;

	constant N_BITS : integer := 6;
	constant EXPONENT_BITS : integer := 3;

	signal A_tb          : std_logic_vector(N_BITS-1 downto 0);
	signal B_tb          : std_logic_vector(N_BITS-1 downto 0);
	signal A_sign_tb          : std_logic := '0';
	signal B_sign_tb          : std_logic := '0';
	signal A_exp_tb      : std_logic_vector(EXPONENT_BITS downto 0);
	signal B_exp_tb      : std_logic_vector(EXPONENT_BITS downto 0);
	signal A_mantissa_tb      : std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
	signal B_mantissa_tb      : std_logic_vector(N_BITS-EXPONENT_BITS downto 0);

begin

	A_tb <= "001110" after 10 fs, "000000" after 20 fs;
	B_tb <= "001001" after 10 fs;

	DUT: fp_deconstructor
		generic map(N_BITS, EXPONENT_BITS)
		port map(
            A => A_tb, 
            B => B_tb, 
			A_sign            => A_sign_tb,	
			B_sign        => B_sign_tb,
			A_exp => A_exp_tb,
			B_exp => B_exp_tb,
			A_mantissa => A_mantissa_tb,
			B_mantissa            => B_mantissa_tb);
end;
