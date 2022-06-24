library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adder is
    generic(N: integer:= 4);
    port(
        X0        : in std_logic_vector(N-1 downto 0);
        X1        : in std_logic_vector(N-1 downto 0);
        substract : in std_logic;
        swap_ops  : in std_logic;
        Y         : out std_logic_vector(N-1 downto 0);
        carry_out : out std_logic
    );
end;

architecture adder_arch of adder is
    signal out_aux : std_logic_vector(N downto 0);
    signal X0_aux  : std_logic_vector(N-1 downto 0);
    signal x1_aux  : std_logic_vector(N-1 downto 0);
begin
    X0_aux <= X0 when swap_ops = '0' else X1;
    X1_aux <= X1 when swap_ops = '0' else X0;
    out_aux <= std_logic_vector(unsigned('0' & X0_aux) + unsigned('0' & X1_aux))
               when substract = '0' else
               std_logic_vector(unsigned('0' & X0_aux) - unsigned('0' & X1_aux));
    Y <= out_aux(N-1 downto 0);
    carry_out <= out_aux(N);
end;