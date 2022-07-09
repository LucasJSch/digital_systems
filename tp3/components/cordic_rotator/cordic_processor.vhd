library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- TODO: Add final division 1.647
entity rotation_mode is
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
        x2   : out std_logic_vector(N_BITS_VECTOR downto 0);
        y2   : out std_logic_vector(N_BITS_VECTOR downto 0);
        done : out std_logic);

end;

architecture iterative_arch of rotation_mode is

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
        iteration : in unsigned(N_BITS_ANGLE-1 downto 0);
        -- Mode flag
        -- 0: Rotation mode.
        -- 1: Vectoring mod.
        mode      : in std_logic;
        x_o       : out signed(N_BITS_VECTOR downto 0);
        y_o       : out signed(N_BITS_VECTOR downto 0);
        z_o       : out signed(N_BITS_ANGLE-1 downto 0));
    end component;

    signal iter      : unsigned(N_BITS_ANGLE-1 downto 0) := (others => '0');
    signal x_current : signed(N_BITS_VECTOR downto 0) := (others => '0');
    signal x_next    : signed(N_BITS_VECTOR downto 0) := (others => '0');
    signal y_current : signed(N_BITS_VECTOR downto 0) := (others => '0');
    signal y_next    : signed(N_BITS_VECTOR downto 0) := (others => '0');
    signal z_current : signed(N_BITS_ANGLE-1 downto 0) := (others => '0');
    signal z_next    : signed(N_BITS_ANGLE-1 downto 0) := (others => '0');

    begin

        computation_kernel : cordic_kernel
        generic map(N_BITS_VECTOR, N_BITS_ANGLE)
        port map(
            x_i => x_current,
            y_i => y_current,
            z_i => z_current,
            iteration => iter,
            mode => '1', -- Rotation mode
            x_o => x_next,
            y_o => y_next,
            z_o => z_next);

        process (clk)
        begin
            if rising_edge(clk) then
                if (iter = to_unsigned(0, N_BITS_ANGLE)) then
                    done <= '0';
                    z_current <= signed(beta);
                    x_current <= '0' & signed(x1);
                    y_current <= '0' & signed(y1);
                    iter <= iter + to_unsigned(1, N_BITS_ANGLE);
                elsif (iter >= to_unsigned(N_ITER, N_BITS_ANGLE)) then
                    done <= '1';
                    x2 <= std_logic_vector(x_next);
                    y2 <= std_logic_vector(y_next);
                else
                    iter <= iter + to_unsigned(1, N_BITS_ANGLE);
                    x_current <= x_next;
                    y_current <= y_next;
                    z_current <= z_next;
                end if;
            end if;
        end process;
    end;