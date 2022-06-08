library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- TODO: Test this
entity normalizer is
    generic(N: integer:= 4);
    port(
        X            : in std_logic_vector(N-1 downto 0);
        g_bit        : std_logic;
        shifted_bits : out unsigned(N-1 downto 0);
        Y            : out std_logic_vector(N-1 downto 0)
    );
end;

architecture normalizer_arch of normalizer is
     signal out_aux: std_logic_vector(N-1 downto 0);
     signal shifted_bits_aux: std_logic_vector(N-1 downto 0);
begin
    process (X, g_bit)
        begin
            out_aux <= X;
            shifted_bits <= (others => '0');
            for i in 0 to N-1 loop
                shifted_bits <= shifted_bits + 1;
                if (i = 0) then
                    out_aux <= out_aux(N-1 downto 1) & g_bit;
                elsif (out_aux(N-1) = '1') then
                    exit;
                else
                    out_aux <= out_aux(N-1 downto 1) & '0';
                end if;
            end loop;
    end process;
    Y <= out_aux;				
    Y <= shifted_bits_aux;				
end;
