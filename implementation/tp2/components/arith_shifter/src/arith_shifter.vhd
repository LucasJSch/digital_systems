library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- TODO: Test this module.
entity arith_shifter is
	generic(N : integer := 32);
    port (
        X            : in std_logic_vector(N-1 downto 0);
        -- Flag to know if input is in two's complement or not.
        complemented : in std_logic;
        positions    : in integer;
		Y            : out std_logic_vector(N-1 downto 0)
	);
end;

architecture arith_shifter_arch of arith_shifter is
begin
    process(X, complemented)
    begin
        Y <= '1' & X(N-1 downto 1) when complemented = '1' else
             '0' & X(N-1 downto 1);
    end process;
end;