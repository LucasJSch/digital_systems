-- FFD with synchronic reset
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ffd is
    port(
        clk     : in std_logic;
        d_i     : in std_logic;
        rst_i   : in std_logic;
        ena_i   : in std_logic;
        q_o     : out std_logic;
        q_neg_o : out std_logic
    );
end entity;

architecture ffd_arch of ffd is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if rst_i = '1' then
                q_o <= '0';
                q_neg_o <= '1';
            elsif ena_i = '1' then
                q_o <= d_i;
                q_neg_o <= not d_i;
            end if;
        end if;
    end process;
end architecture;