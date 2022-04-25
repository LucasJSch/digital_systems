library IEEE;
use IEEE.std_logic_1164.all;

entity multiplexer is 
port (
        -- Clock line
        clk:  in std_logic;
        -- Input lines
        x1_i: in std_logic;
        x2_i: in std_logic;
        x3_i: in std_logic;
        x4_i: in std_logic;
        -- Selection lines
        s1_i: in std_logic;
        s2_i: in std_logic;
        -- Output
        y_o: out std_logic
    );
end;

architecture multiplexer_arch of multiplexer is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if s2_i = '0' and s1_i = '0' then
                y_o <= x1_i;
            elsif s2_i = '0' and s1_i = '1' then
                y_o <= x2_i;
            elsif s2_i = '1' and s1_i = '0' then
                y_o <= x3_i;
            else
                y_o <= x4_i;
            end if;
        end if;
    end process; 
end;
