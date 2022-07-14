library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- TODO: Add final division 1.647
entity cordic_processor is
	generic(
        -- Describes the amount of bits per vector element.
        N_BITS_VECTOR : integer:= 32;
        -- Describes the amount of bits to represent the angle.
        N_BITS_ANGLE : integer := 18;
        N_ITER       : integer := 10);
    port(
        clk  : in std_logic;
        x1   : in std_logic_vector(N_BITS_VECTOR-1 downto 0);
        y1   : in std_logic_vector(N_BITS_VECTOR-1 downto 0);
        beta : in signed(N_BITS_ANGLE-1 downto 0);
        -- 0: Rotation mode.
        -- 1: Vectoring mode.
        mode : in std_logic;
        start: in std_logic;
        x2   : out std_logic_vector(N_BITS_VECTOR downto 0);
        y2   : out std_logic_vector(N_BITS_VECTOR downto 0);
        z2   : out std_logic_vector(N_BITS_ANGLE-1 downto 0);
        done : out std_logic);

end;

architecture iterative_arch of cordic_processor is

    component cordic_kernel is
        generic(
        -- Describes the amount of bits per vector element.
        N_BITS_VECTOR : integer:= 32;
        -- Describes the amount of bits to represent the angle.
        N_BITS_ANGLE : integer:= 18);
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
            mode => mode, -- Rotation mode
            x_o => x_next,
            y_o => y_next,
            z_o => z_next);

        process (clk, start)
        begin
            if rising_edge(start) then
                done <= '0';
                iter <= (others => '0');
            elsif rising_edge(clk) then
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
                    z2 <= std_logic_vector(z_next);
                else
                    iter <= iter + to_unsigned(1, N_BITS_ANGLE);
                    x_current <= x_next;
                    y_current <= y_next;
                    z_current <= z_next;
                end if;
            end if;
        end process;
end;

architecture unrolled_arch of cordic_processor is

    component cordic_kernel is
        generic(
        -- Describes the amount of bits per vector element.
        N_BITS_VECTOR : integer:= 32;
        -- Describes the amount of bits to represent the angle.
        N_BITS_ANGLE : integer:= 18);
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

    -- Adds one extra bit to signed vector.
    function ADD_BIT(x : std_logic_vector(N_BITS_VECTOR-1 downto 0))
    return signed is
        variable x_2c          : unsigned(N_BITS_VECTOR-1 downto 0);
        variable x_2c_extended : unsigned(N_BITS_VECTOR downto 0);
        variable x_2c_final : unsigned(N_BITS_VECTOR downto 0);
    begin
        x_2c := unsigned(not(x)) + to_unsigned(1, N_BITS_VECTOR) when x(N_BITS_VECTOR-1) = '1' else
        unsigned(x);
        x_2c_extended := '0' & x_2c;
        x_2c_final := not(x_2c_extended) + to_unsigned(1, N_BITS_VECTOR) when x(N_BITS_VECTOR-1) = '1' else
        x_2c_extended;
        
        return signed(x_2c_final);
    end ADD_BIT;
        
    type x_type is array (0 to N_ITER) of signed(N_BITS_VECTOR downto 0);
    type y_type is array (0 to N_ITER) of signed(N_BITS_VECTOR downto 0);
    type z_type is array (0 to N_ITER) of signed(N_BITS_ANGLE-1 downto 0);

    signal x : x_type;
    signal y : y_type;
    signal z : z_type;
    begin
        generate_label : for iter in 0 to N_ITER-1 generate
        begin
            x(0) <= ADD_BIT(x1);
            y(0) <= ADD_BIT(y1);
            z(0) <= beta;
            computation_kernel_i : cordic_kernel
            generic map(N_BITS_VECTOR, N_BITS_ANGLE)
            port map(
                x_i => x(iter),
                y_i => y(iter),
                z_i => z(iter),
                iteration => to_unsigned(iter+1, N_BITS_ANGLE),
                mode => mode,
                x_o => x(iter+1),
                y_o => y(iter+1),
                z_o => z(iter+1));
        end generate;
        x2 <= std_logic_vector(x(N_ITER-1));
        y2 <= std_logic_vector(y(N_ITER-1));
        z2 <= std_logic_vector(z(N_ITER-1));
    end;