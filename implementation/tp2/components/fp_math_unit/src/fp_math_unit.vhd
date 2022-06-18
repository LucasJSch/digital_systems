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
		z             : out std_logic_vector(N_BITS-1 downto 0)
	);
end entity;

architecture fp_math_unit_arch of fp_math_unit is

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

    component fp_sub is
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
    
    signal z_sum : std_logic_vector(N_BITS-1 downto 0);
    signal z_sub : std_logic_vector(N_BITS-1 downto 0);
    signal z_mul : std_logic_vector(N_BITS-1 downto 0);
begin

    sum_unit: fp_sum
    generic map(N_BITS, EXPONENT_BITS)
    port map(
        clk => clk,	
        a   => a,
        b   => b,
        z   => z_sum);

    substract_unit: fp_sub
    generic map(N_BITS, EXPONENT_BITS)
    port map(
        clk => clk,	
        a   => a,
        b   => b,
        z   => z_sub);

    multiplication_unit: fp_mul
    generic map(N_BITS, EXPONENT_BITS)
    port map(
        clk => clk,	
        a   => a,
        b   => b,
        z   => z_mul);

    z <= z_sum when (ctrl = "00" or ctrl = "11") else
         z_sub when (ctrl = "01")                else
         z_mul when (ctrl = "10");
end;
