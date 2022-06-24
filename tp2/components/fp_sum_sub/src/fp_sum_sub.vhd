library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp_sum_sub is
    generic(
        N_BITS : integer := 32;
        EXPONENT_BITS : integer := 8);
	port(
        clk           : in std_logic;
		a             : in std_logic_vector(N_BITS-1 downto 0);
		b             : in std_logic_vector(N_BITS-1 downto 0);
        ctrl          : in std_logic; -- 0: Sum; 1: Sub;
		z             : out std_logic_vector(N_BITS-1 downto 0)
	);
end entity;

architecture fp_sum_sub_arch of fp_sum_sub is

    component fp_sum is
        generic(
            N_BITS : integer := 32;
            EXPONENT_BITS : integer := 8);
        port(
            clk           : in std_logic;
            a             : in std_logic_vector(N_BITS-1 downto 0);
            b             : in std_logic_vector(N_BITS-1 downto 0);
            z             : out std_logic_vector(N_BITS-1 downto 0)
        );
    end component;
    
    signal aux_b : std_logic_vector(N_BITS-1 downto 0) := not(b(N_BITS-1)) & b(N_BITS-2 downto 0);
begin

    process(a, b, ctrl)
    begin
        if ctrl = '0' then
            aux_b <= b;
        else
            aux_b <= not(b(N_BITS-1)) & b(N_BITS-2 downto 0);
        end if;
    end process;

    sum_module : fp_sum
    generic map(N_BITS, EXPONENT_BITS)
    port map (
        clk  => clk,
        a  => a,	
        b  => aux_b,
        z  => z);
end;
