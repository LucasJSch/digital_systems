-- FFD with input of N bits, with synchronic reset
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity despl is
    generic(N : natural := 8);
    port(
        clk     : in std_logic;
        d_i     : in std_logic;
        rst_i   : in std_logic;
        q_o     : out std_logic_vector(N-1 downto 0)
    );
end entity;

architecture despl_arch of despl is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if rst_i = '1' then
                q_o <= (others => '0');
            else
                q_o <= q_o(N-2 downto 0) & d_i;
            end if;
        end if;
    end process;
end architecture;