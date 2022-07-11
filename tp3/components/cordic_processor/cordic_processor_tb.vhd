library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cordic_processor_tb is
end;

architecture cordic_processor_arch of cordic_processor_tb is
    component cordic_processor is
    generic(
        -- Describes the amount of bits per vector element.
        N_BITS_VECTOR : integer:= 32;
        -- Describes the amount of bits to represent the angle.
        N_BITS_ANGLE : integer := 17;
        N_ITER       : integer := 10);
    port(
        clk  : in std_logic;
        x1   : in std_logic_vector(N_BITS_VECTOR-1 downto 0);
        y1   : in std_logic_vector(N_BITS_VECTOR-1 downto 0);
        beta : in signed(N_BITS_ANGLE-1 downto 0);
        -- 0: Rotation mode.
        -- 1: Vectoring mode.
        mode : std_logic;
        x2   : out std_logic_vector(N_BITS_VECTOR downto 0);
        y2   : out std_logic_vector(N_BITS_VECTOR downto 0);
        z2   : out std_logic_vector(N_BITS_ANGLE-1 downto 0);
        done : out std_logic);
    end component;

	constant N_BITS_VECTOR : integer := 15;
	constant N_BITS_ANGLE  : integer := 17;
	constant N_ITER        : integer := 15;

	signal clk_tb          : std_logic := '0';

    signal x1_tb           : std_logic_vector(N_BITS_VECTOR-1 downto 0) := "000111111111111";
	signal y1_tb           : std_logic_vector(N_BITS_VECTOR-1 downto 0) := "000000000000000";
    signal beta_tb         : signed(N_BITS_ANGLE-1 downto 0) := to_signed(32760, N_BITS_ANGLE);

    signal x2_tb           : std_logic_vector(N_BITS_VECTOR downto 0);
    signal y2_tb           : std_logic_vector(N_BITS_VECTOR downto 0);
    signal done_tb         : std_logic;

begin

    clk_tb <= not clk_tb after 10 ns;

	DUT: entity work.cordic_processor(iterative_arch)
		generic map(N_BITS_VECTOR, N_BITS_ANGLE, N_ITER)
		port map(
            clk   => clk_tb,
            x1    => x1_tb,
            y1    => y1_tb,
            beta  => beta_tb,
            mode  => '0',
            x2    => x2_tb,
            y2    => y2_tb,
            done  => done_tb);
end;