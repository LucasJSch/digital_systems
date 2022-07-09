library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cordic_kernel_tb is
end;

architecture cordic_kernel_arch of cordic_kernel_tb is
    component cordic_kernel is
    generic(
        -- Describes the amount of bits per vector element.
        N_BITS_VECTOR : integer:= 32;
        -- Describes the amount of bits to represent the angle.
        N_BITS_ANGLE : integer:= 17);
    port(
        x_i       : in signed(N_BITS_VECTOR downto 0);
        y_i       : in signed(N_BITS_VECTOR downto 0);
        z_i       : in signed(N_BITS_ANGLE-1 downto 0);
        iteration : in integer;
        -- Mode flag
        -- 0: Rotation mode.
        -- 1: Vectoring mod.
        mode      : in std_logic;
        x_o       : out signed(N_BITS_VECTOR downto 0);
        y_o       : out signed(N_BITS_VECTOR downto 0);
        z_o       : out signed(N_BITS_ANGLE-1 downto 0));
    end component;

	constant N_BITS_VECTOR : integer := 15;
	constant N_BITS_ANGLE  : integer := 17;

	signal clk_tb          : std_logic := '0';

    signal x_i_tb           : signed(N_BITS_VECTOR downto 0) := "0000111111111111";
	signal y_i_tb           : signed(N_BITS_VECTOR downto 0) := "0000111111111111";
    signal z_i_tb           : signed(N_BITS_ANGLE-1 downto 0) := to_signed(32000, N_BITS_ANGLE);

    signal x_o_tb           : signed(N_BITS_VECTOR downto 0);
    signal y_o_tb           : signed(N_BITS_VECTOR downto 0);
    signal z_o_tb           : signed(N_BITS_ANGLE-1 downto 0);

begin

    clk_tb <= not clk_tb after 10 ns;

	DUT: entity work.cordic_kernel(iterative_arch)
		generic map(N_BITS_VECTOR, N_BITS_ANGLE)
		port map(
            x_i   => x_i_tb,
            y_i   => y_i_tb,
            z_i   => z_i_tb,
            iteration    => 2,
            mode    => '0',
            x_o  => x_o_tb,
            y_o    => y_o_tb,
            z_o    => z_o_tb);
end;