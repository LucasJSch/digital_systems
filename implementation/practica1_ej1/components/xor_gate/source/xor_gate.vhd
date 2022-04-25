library IEEE;
use IEEE.std_logic_1164.all;

entity xor_gate is 
    port (
        x1_i: in std_logic;
        x2_i: in std_logic;
        y_o: out std_logic
    );
end;

architecture xor_gate_arch of xor_gate is
begin
    y_o <= x1_i xor x2_i;
end;
