library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mantissa_adder is
	generic(N_BITS : integer := 32; EXPONENT_BITS : integer := 8);
    port (
        A_sign     : in std_logic;
        B_sign     : in std_logic;
        A_mantissa : in std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
        B_mantissa : in std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
        
        result_sign     : out std_logic;
        result_mantissa : out std_logic_vector(N_BITS-EXPONENT_BITS downto 0));
end;

architecture mantissa_adder_arch of mantissa_adder is
    constant MANTISSA_BITS : integer := N_BITS - EXPONENT_BITS - 1;
begin
    process(A_sign, B_sign, A_mantissa, B_mantissa)
    begin
        if (A_sign xor B_sign) = '0' then
            result_mantissa <= std_logic_vector((unsigned(A_mantissa) + unsigned(B_mantissa)));
            result_sign      <= A_sign;
        elsif unsigned(A_mantissa) >= unsigned(B_mantissa) then
            result_mantissa <= std_logic_vector((unsigned(A_mantissa) - unsigned(B_mantissa)));
            result_sign      <= A_sign;
        else
            result_mantissa <= std_logic_vector((unsigned(B_mantissa) - unsigned(A_mantissa)));
            result_sign      <= B_sign;
        end if;
    end process;
end;