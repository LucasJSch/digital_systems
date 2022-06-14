library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adder is
    generic(N: integer:= 4);
    port(
        X0        : in std_logic_vector(N-1 downto 0);
        X1        : in std_logic_vector(N-1 downto 0);
        carry_in  : in std_logic;
        Y         : out std_logic_vector(N-1 downto 0);
        carry_out : out std_logic
    );
end;

architecture adder_arch of adder is
     signal out_aux: std_logic_vector(N+1 downto 0);
begin
    out_aux <= std_logic_vector(unsigned('0' & X0 & carry_in) + unsigned('0' & X1 & '1'));
    Y <= out_aux(N downto 1);				
    carry_out <= out_aux(N+1);				
end;