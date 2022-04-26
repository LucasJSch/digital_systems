library IEEE;
use IEEE.std_logic_1164.all;

entity or_gate is 
    port (
        x1_i: in std_logic;
        x2_i: in std_logic;
        y_o: out std_logic
    );
end;

architecture or_gate_arch of or_gate is
begin
    y_o <= x1_i or x2_i;
end;
