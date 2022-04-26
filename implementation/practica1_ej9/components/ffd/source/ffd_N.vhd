-- FFD with input of N bits, with synchronic reset
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ffd_N is
    generic(N : natural := 8);
    port(
        clk     : in std_logic;
        d_i     : in std_logic_vector(N-1 downto 0);
        rst_i   : in std_logic;
        ena_i   : in std_logic;
        q_o     : out std_logic_vector(N-1 downto 0);
        q_neg_o : out std_logic_vector(N-1 downto 0)
    );
end entity;

architecture ffd_N_arch of ffd_N is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if rst_i = '1' then
                q_o <= (others => '0');
                q_neg_o <= (others => '1');
            elsif ena_i = '1' then
                q_o <= d_i;
                q_neg_o <= not d_i;
            end if;
        end if;
    end process;
end architecture;