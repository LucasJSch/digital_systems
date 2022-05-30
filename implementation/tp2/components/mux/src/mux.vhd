library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- TODO: Test this module.
entity mux is
	generic(N :integer:= 32);
    port (
        -- Input lines
        X0    : in std_logic_vector(N-1 downto 0);
        X1    : in std_logic_vector(N-1 downto 0);
		X2    : in std_logic_vector(N-1 downto 0);
		X3    : in std_logic_vector(N-1 downto 0);
        -- Selection line
		sel   : in std_logic_vector(1 downto 0);
        -- Output line
		Y     : out std_logic_vector(N-1 downto 0)
		);
end;

architecture mux_arch of mux is

begin
    process(X0, X1, X2, X3, sel)
    begin
        if (sel = "00") then
            Y <= X0;
		elsif (sel = "01") then
			Y <= X1;
		elsif (sel = "10") then
			Y <= X2;
		else
        Y <= X3;
		end if;
    end process;
end;