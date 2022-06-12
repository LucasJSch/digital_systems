library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- TODO: Test this
entity normalizer is
    generic(N: integer:= 4; M: integer := 4);
    port(
        X            : in std_logic_vector(N-1 downto 0);
        g_bit        : in std_logic;
        shifted_bits : out unsigned(M-1 downto 0);
        Y            : out std_logic_vector(N-1 downto 0)
    );
end;

architecture normalizer_arch of normalizer is
begin
    process (X, g_bit)
        type out_array_type        is array (0 to N-1) of std_logic_vector(N-1 downto 0);
        type out_shifted_bits_type is array (0 to N-1) of unsigned(M-1 downto 0);
        variable out_aux : out_array_type;
        variable shifted_bits_aux : out_shifted_bits_type;
        begin
            for i in 0 to N-1 loop
                if (X(X'left) = '1') then
                    out_aux(N-1) := X;
                    shifted_bits_aux(N-1) := (others => '0');
                elsif (i = 0) then
                    out_aux(i) := X(N-2 downto 0) & g_bit;
                    shifted_bits_aux(i) := (0 => '1', others => '0');
                elsif (out_aux(i-1)(N-1) = '1') then
                    out_aux(N-1) := out_aux(i-1);
                    shifted_bits_aux(N-1) := shifted_bits_aux(i-1);
                    exit;
                else
                    out_aux(i) := out_aux(i-1)(N-2 downto 0) & '0';
                    shifted_bits_aux(i) := shifted_bits_aux(i-1) + 1;
                end if;
            end loop;
            Y <= out_aux(N-1);				
            shifted_bits <= shifted_bits_aux(N-1);				
    end process;
end;
