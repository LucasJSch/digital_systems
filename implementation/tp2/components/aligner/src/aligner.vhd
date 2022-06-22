library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity aligner is
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
end;

architecture aligner_arch of aligner is
    constant MANTISSA_BITS : integer := N_BITS - EXPONENT_BITS - 1;
begin
    process(A_exp, B_exp, A_sign, B_sign, A_mantissa, B_mantissa)
    variable diff : signed(A_exp'length-1 downto 0);
    begin
        diff := signed(A_exp) - signed(B_exp);
        if unsigned(A_exp) > unsigned(B_exp) then
            A_mantissa_out <= A_mantissa;
            if diff > MANTISSA_BITS then
                result_mantissa <= A_mantissa;
                result_exp <= A_exp;
                result_sign      <= A_sign;
                B_mantissa_out <= B_mantissa;
                result_ready <= '1';
            else       
                result_ready <= '0';
                result_sign <= result_sign;
                result_exp <= A_exp;
                result_mantissa <= result_mantissa;
                B_mantissa_out(MANTISSA_BITS+1-to_integer(diff) downto 0)  <= B_mantissa(MANTISSA_BITS+1 downto to_integer(diff));
                if (diff > 1) then
                    B_mantissa_out(MANTISSA_BITS+1 downto MANTISSA_BITS+2-to_integer(diff)) <= (others => '0');
                else
                    B_mantissa_out(MANTISSA_BITS+1) <= '0';
                end if;
            end if;
        elsif unsigned(A_exp) < unsigned(B_exp)  then
            B_mantissa_out <= B_mantissa;
            if diff < -MANTISSA_BITS then
                result_mantissa <= B_mantissa;
                result_sign      <= B_sign;
                result_exp      <= B_exp; 
                A_mantissa_out <= A_mantissa;
                result_ready <= '1';
            else       
                result_ready <= '0';
                result_sign <= result_sign;
                result_mantissa <= result_mantissa;
                result_exp <= B_exp;
                A_mantissa_out(MANTISSA_BITS+1+to_integer(diff) downto 0)  <= A_mantissa(MANTISSA_BITS+1 downto -1*to_integer(diff));
                if (diff < -1) then
                    A_mantissa_out(MANTISSA_BITS+1 downto MANTISSA_BITS+2+to_integer(diff)) <= (others => '0');
                else
                    A_mantissa_out(MANTISSA_BITS+1) <= '0';
                end if;
            end if;
        else
            result_ready <= '0';
            result_sign <= result_sign;
            result_mantissa <= result_mantissa;
            result_exp <= A_exp;
            B_mantissa_out(MANTISSA_BITS+1-to_integer(diff) downto 0)  <= B_mantissa(MANTISSA_BITS+1 downto to_integer(diff));
            B_mantissa_out(MANTISSA_BITS+1 downto MANTISSA_BITS+2-to_integer(diff)) <= (others => '0');
            A_mantissa_out <= A_mantissa;
        end if;
end process;
end;