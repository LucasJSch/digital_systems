library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp_deconstructor is
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
end;

architecture fp_deconstructor_arch of fp_deconstructor is
    constant MANTISSA_BITS : integer := N_BITS - EXPONENT_BITS - 1;
begin
    A_sign <= A(N_BITS-1);
    B_sign <= B(N_BITS-1);

    --One bit is added for signed subtraction
    A_exp <= '0' & A(N_BITS-2 downto MANTISSA_BITS); 
    B_exp <= '0' & B(N_BITS-2 downto MANTISSA_BITS);

    --Two bits are added extra, one for leading 1 and other one for storing carry
    A_mantissa <= "01" & A(MANTISSA_BITS-1 downto 0);
    B_mantissa <= "01" & B(MANTISSA_BITS-1 downto 0);
end;