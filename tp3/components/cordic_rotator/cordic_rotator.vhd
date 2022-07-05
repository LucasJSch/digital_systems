library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- TODO: Make this generic.
entity cordic_rotator is
	generic(
        -- Describes the amount of bits per vector element.
        N_BITS_VECTOR : integer:= 32;
        -- Describes the amount of bits to represent the angle.
        N_BITS_ANGLE : integer:= 17;
        -- Describes the amount of iterations to compute the result.
        N_ITER : integer := 10);
    port(
        clk  : in std_logic;
        x1   : in std_logic_vector(N_BITS_VECTOR-1 downto 0);
        y1   : in std_logic_vector(N_BITS_VECTOR-1 downto 0);
        beta : in signed(N_BITS_ANGLE-1 downto 0);
        x2   : out std_logic_vector(N_BITS_VECTOR-1 downto 0);
        y2   : out std_logic_vector(N_BITS_VECTOR-1 downto 0);
        done : out std_logic);

end;

architecture unrolled_arch of cordic_rotator is

    function ARC_TG(i : unsigned(N_ITER-1 downto 0))
    return signed is
        variable aux : signed(N_BITS_ANGLE-1 downto 0);
    begin
        aux :=  to_signed(32767, N_BITS_ANGLE) when i = to_unsigned(1, N_ITER) else
                to_signed(19344, N_BITS_ANGLE)  when i = to_unsigned(2, N_ITER) else
                to_signed(10221, N_BITS_ANGLE)  when i = to_unsigned(3, N_ITER) else
                to_signed(5188, N_BITS_ANGLE)  when i = to_unsigned(4, N_ITER) else
                to_signed(2604, N_BITS_ANGLE)  when i = to_unsigned(5, N_ITER) else
                to_signed(1303, N_BITS_ANGLE)  when i = to_unsigned(6, N_ITER) else
                to_signed(652, N_BITS_ANGLE)  when i = to_unsigned(7, N_ITER) else
                to_signed(326, N_BITS_ANGLE)  when i = to_unsigned(8, N_ITER) else
                to_signed(163, N_BITS_ANGLE)  when i = to_unsigned(9, N_ITER) else
                to_signed(81, N_BITS_ANGLE)  when i = to_unsigned(10, N_ITER) else
                to_signed(41, N_BITS_ANGLE)  when i = to_unsigned(11, N_ITER) else
                to_signed(20, N_BITS_ANGLE)  when i = to_unsigned(12, N_ITER) else
                to_signed(10, N_BITS_ANGLE)  when i = to_unsigned(13, N_ITER) else
                to_signed(5, N_BITS_ANGLE)  when i = to_unsigned(14, N_ITER) else
                to_signed(3, N_BITS_ANGLE)  when i = to_unsigned(15, N_ITER) else
                to_signed(1, N_BITS_ANGLE);
        return aux;
    end ARC_TG;

    function TG_MUL(x : signed(N_BITS_VECTOR downto 0); i : integer)
    return signed is
    begin
        return signed(shift_right(unsigned(x), i));
    end TG_MUL;

    signal i : integer := 0;

    begin
    process(clk)
    type d_type is array (0 to N_ITER-1) of std_logic;
    type x_type is array (0 to N_ITER-1) of signed(N_BITS_VECTOR downto 0);
    type y_type is array (0 to N_ITER-1) of signed(N_BITS_VECTOR downto 0);
    type z_type is array (0 to N_ITER-1) of signed(N_BITS_ANGLE-1 downto 0);
    variable d : d_type;
    variable x : x_type;
    variable y : y_type;
    variable z : z_type;
    begin
        if rising_edge(clk) then
            -- for i in 0 to N_ITER-1 loop
                if (i = 0) then
                    done <= '0';
                    d(i) := '0';
                    x(i) := '0' & signed(x1);
                    y(i) := '0' & signed(y1);
                    z(i) := signed(beta);
                elsif (i >= N_ITER) then
                    done <= '1';
                    x2 <= std_logic_vector(x(N_ITER-1)(N_BITS_VECTOR-1 downto 0));
                    y2 <= std_logic_vector(y(N_ITER-1)(N_BITS_VECTOR-1 downto 0));
                else
                    if (d(i-1) = '0') then
                        x(i) := x(i-1) - TG_MUL(y(i-1), i-1);
                        y(i) := y(i-1) + TG_MUL(x(i-1), i-1);
                        z(i) := z(i-1) - ARC_TG(to_unsigned(i, N_ITER));
                    else
                        x(i) := x(i-1) + TG_MUL(y(i-1), i-1);
                        y(i) := y(i-1) - TG_MUL(x(i-1), i-1);
                        z(i) := z(i-1) + ARC_TG(to_unsigned(i, N_ITER));
                    end if;
                    if (z(i) > 0) then
                        d(i) := '0';
                    end if;
                end if;
                if (done = '0') then
                    i <= i + 1;
                end if;
            -- end loop;
        end if; 
    end process;
end;

architecture iterative_arch of cordic_rotator is

    function ARC_TG(i : unsigned(N_ITER-1 downto 0))
    return signed is
        variable aux : signed(N_BITS_ANGLE-1 downto 0);
    begin
        aux :=  to_signed(32767, N_BITS_ANGLE) when i = to_unsigned(1, N_ITER) else
                to_signed(19344, N_BITS_ANGLE)  when i = to_unsigned(2, N_ITER) else
                to_signed(10221, N_BITS_ANGLE)  when i = to_unsigned(3, N_ITER) else
                to_signed(5188, N_BITS_ANGLE)  when i = to_unsigned(4, N_ITER) else
                to_signed(2604, N_BITS_ANGLE)  when i = to_unsigned(5, N_ITER) else
                to_signed(1303, N_BITS_ANGLE)  when i = to_unsigned(6, N_ITER) else
                to_signed(652, N_BITS_ANGLE)  when i = to_unsigned(7, N_ITER) else
                to_signed(326, N_BITS_ANGLE)  when i = to_unsigned(8, N_ITER) else
                to_signed(163, N_BITS_ANGLE)  when i = to_unsigned(9, N_ITER) else
                to_signed(81, N_BITS_ANGLE)  when i = to_unsigned(10, N_ITER) else
                to_signed(41, N_BITS_ANGLE)  when i = to_unsigned(11, N_ITER) else
                to_signed(20, N_BITS_ANGLE)  when i = to_unsigned(12, N_ITER) else
                to_signed(10, N_BITS_ANGLE)  when i = to_unsigned(13, N_ITER) else
                to_signed(5, N_BITS_ANGLE)  when i = to_unsigned(14, N_ITER) else
                to_signed(3, N_BITS_ANGLE)  when i = to_unsigned(15, N_ITER) else
                to_signed(1, N_BITS_ANGLE);
        return aux;
    end ARC_TG;

    function TG_MUL(x : signed(N_BITS_VECTOR downto 0); i : integer)
    return signed is
    begin
        return signed(shift_right(unsigned(x), i));
    end TG_MUL;

    signal iter : integer := 0;

    signal x : signed(N_BITS_VECTOR downto 0);
    signal y : signed(N_BITS_VECTOR downto 0);
    signal z : signed(N_BITS_ANGLE-1 downto 0) := (others => '0');
    signal d : std_logic;

    begin
    process (clk)
    begin
        if rising_edge(clk) then
                if (iter = 0) then
                    done <= '0';
                    d <= '0';
                    z <= signed(beta);
                    x <= '0' & signed(x1);
                    y <= '0' & signed(y1);
                elsif (iter >= N_ITER) then
                    done <= '1';
                    x2 <= std_logic_vector(x(N_BITS_VECTOR-1 downto 0));
                    y2 <= std_logic_vector(y(N_BITS_VECTOR-1 downto 0));
                else
                    if (d = '0') then
                        x <= x - TG_MUL(y, iter-1);
                        y <= y + TG_MUL(x, iter-1);
                        z <= z - ARC_TG(to_unsigned(iter, N_ITER));
                    else
                        x <= x + TG_MUL(y, iter-1);
                        y <= y - TG_MUL(x, iter-1);
                        z <= z + ARC_TG(to_unsigned(iter, N_ITER));
                    end if;
                end if;
            if (done = '0') then
                iter <= iter + 1;
            end if;
        end if;
    end process;

    process(z)
    begin
        if (z >= to_signed(0, N_BITS_ANGLE)) then
            d <= '0';
        else
            d <= '1';
        end if;
    end process;
end;