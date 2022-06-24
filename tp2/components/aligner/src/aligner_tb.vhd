library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity aligner_tb is
end;

architecture aligner_tb_arch of aligner_tb is
    component aligner is
		generic(N_BITS : integer := 32; EXPONENT_BITS : integer := 8);
        port (
        A_sign     : in std_logic;
        B_sign     : in std_logic;
        A_exp      : in std_logic_vector(EXPONENT_BITS downto 0);
        B_exp      : in std_logic_vector(EXPONENT_BITS downto 0);
        A_mantissa : in std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
        B_mantissa : in std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
        
        result_sign : out std_logic;
        result_exp  : out std_logic_vector(EXPONENT_BITS downto 0);
        result_mantissa : out std_logic_vector(N_BITS-EXPONENT_BITS downto 0);

        A_mantissa_out : out std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
        B_mantissa_out : out std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
        
        result_ready   : out std_logic);
    end component;

	constant N_BITS : integer := 6;
	constant EXPONENT_BITS : integer := 3;

	signal A_sign_tb          : std_logic := '0';
	signal B_sign_tb          : std_logic := '0';
	signal A_exp_tb      : std_logic_vector(EXPONENT_BITS downto 0);
	signal B_exp_tb      : std_logic_vector(EXPONENT_BITS downto 0);
	signal A_mantissa_tb      : std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
	signal B_mantissa_tb      : std_logic_vector(N_BITS-EXPONENT_BITS downto 0);

    signal result_sign_tb : std_logic;
    signal result_exp_tb : std_logic_vector(EXPONENT_BITS downto 0);
    signal result_mantissa_tb : std_logic_vector(N_BITS-EXPONENT_BITS downto 0);

    signal A_mantissa_out_tb : std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
    signal B_mantissa_out_tb : std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
    signal result_ready_tb : std_logic;

begin

	A_exp_tb <= "0011" after 10 fs, "0000" after 20 fs;
	B_exp_tb <= "0001" after 10 fs;
	A_mantissa_tb <= "0010" after 10 fs;
	B_mantissa_tb <= "0101" after 10 fs;

	DUT: aligner
		generic map(N_BITS, EXPONENT_BITS)
		port map(
            A_sign => A_sign_tb, 
            B_sign => B_sign_tb, 
			A_exp => A_exp_tb,
			B_exp => B_exp_tb,
			A_mantissa => A_mantissa_tb,
			B_mantissa => B_mantissa_tb,
            
            result_sign => result_sign_tb,
            result_exp => result_exp_tb,
            result_mantissa => result_mantissa_tb,

            A_mantissa_out => A_mantissa_out_tb,
            B_mantissa_out => B_mantissa_out_tb,
            result_ready => result_ready_tb);
end;
