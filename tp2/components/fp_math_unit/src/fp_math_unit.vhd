library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp_math_unit is
    generic(
        N_BITS : integer := 32;
        EXPONENT_BITS : integer := 8);
	port(
        clk           : in std_logic;
		a             : in std_logic_vector(N_BITS-1 downto 0);
		b             : in std_logic_vector(N_BITS-1 downto 0);
        -- 00: Sum; 01: Substract ; 10: Multiply; 11: Sum.
        ctrl          : in std_logic_vector(1 downto 0);
		z             : out std_logic_vector(N_BITS-1 downto 0));
end entity;

architecture fp_math_unit_arch of fp_math_unit is

    component fp_sum_sub is
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
    end component;

    component fp_mul is
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
    
    signal z_sum_sub : std_logic_vector(N_BITS-1 downto 0);
    signal z_mul : std_logic_vector(N_BITS-1 downto 0);
    signal sum_sub_ctrl : std_logic;
begin

    sum_sub_unit: fp_sum_sub
    generic map(N_BITS, EXPONENT_BITS)
    port map(
        clk  => clk,	
        a    => a,
        b    => b,
        ctrl => sum_sub_ctrl,
        z    => z_sum_sub);

    multiplication_unit: fp_mul
    generic map(N_BITS, EXPONENT_BITS)
    port map(
        clk => clk,	
        a   => a,
        b   => b,
        z   => z_mul);

    process (ctrl)
    begin
        if (ctrl = "00" or ctrl = "11") then
            sum_sub_ctrl <= '0';
        elsif (ctrl = "01") then
            sum_sub_ctrl <= '1';
        end if;
    end process;
    z <= z_mul when (ctrl = "10") else z_sum_sub;
end;
