library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- TODO: Make this generic.
entity cordic_kernel is
	generic(
        -- Describes the amount of bits per vector element.
        N_BITS_VECTOR : integer:= 32;
        -- Describes the amount of bits to represent the angle.
        -- 2**(N_BITS_ANGLE-3) --> 45 degrees
        -- 2**(N_BITS_ANGLE-2) --> 90 degrees
        -- 2**(N_BITS_ANGLE-1) --> 180 degrees
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

end;

architecture iterative_arch of cordic_kernel is

    function ARC_TG(iter : unsigned(N_BITS_ANGLE-1 downto 0))
    return signed is
        variable aux : signed(N_BITS_ANGLE-1 downto 0);
        variable iter_int : integer := to_integer(iter);
    begin
        aux :=  to_signed(32767, N_BITS_ANGLE) when iter_int =  1 else
                to_signed(19344, N_BITS_ANGLE)  when iter_int =  2 else
                to_signed(10221, N_BITS_ANGLE)  when iter_int =  3 else
                to_signed(5188, N_BITS_ANGLE)  when iter_int =  4 else
                to_signed(2604, N_BITS_ANGLE)  when iter_int =  5 else
                to_signed(1303, N_BITS_ANGLE)  when iter_int =  6 else
                to_signed(652, N_BITS_ANGLE)  when iter_int =  7 else
                to_signed(326, N_BITS_ANGLE)  when iter_int =  8 else
                to_signed(163, N_BITS_ANGLE)  when iter_int =  9 else
                to_signed(81, N_BITS_ANGLE)  when iter_int =  10 else
                to_signed(41, N_BITS_ANGLE)  when iter_int =  11 else
                to_signed(20, N_BITS_ANGLE)  when iter_int =  12 else
                to_signed(10, N_BITS_ANGLE)  when iter_int =  13 else
                to_signed(5, N_BITS_ANGLE)  when iter_int =  14 else
                to_signed(3, N_BITS_ANGLE)  when iter_int =  15 else
                to_signed(1, N_BITS_ANGLE);
        return aux;
    end ARC_TG;

    function TG_MUL(x : signed(N_BITS_VECTOR downto 0); i : unsigned(N_BITS_ANGLE-1 downto 0))
    return signed is
        variable iter_int : integer := to_integer(i);
        variable sign     : std_logic := x(N_BITS_VECTOR);
        variable retval   : signed(N_BITS_VECTOR downto 0);
        variable x_2c     : unsigned(N_BITS_VECTOR downto 0);
        variable x_2c_shifted : std_logic_vector(N_BITS_VECTOR downto 0);
    begin
        x_2c := unsigned(not(std_logic_vector(x))) + to_unsigned(1, N_BITS_VECTOR+1);
        x_2c_shifted := std_logic_vector(shift_right(x_2c, iter_int));
        retval := signed(shift_right(unsigned(x), iter_int)) when sign = '0' else
                  signed(unsigned(not(x_2c_shifted)) + to_unsigned(1, N_BITS_VECTOR+1));
        return retval;
    end TG_MUL;

    -- Flag indicating to which side to converge.
    signal d : std_logic;
begin
    process(mode, x_i, y_i, z_i)
    begin
        if mode = '0' then
            if z_i >= to_signed(0, N_BITS_ANGLE) then
                d <= '0';
            else
                d <= '1';
            end if;
        else
            if y_i >= to_signed(0, N_BITS_ANGLE) then
                d <= '1';
            else
                d <= '0';
            end if;
        end if;
    end process;

    x_o <= x_i - TG_MUL(y_i, iteration-1) when d = '0' else
           x_i + TG_MUL(y_i, iteration-1);
    y_o <= y_i + TG_MUL(x_i, iteration-1) when d = '0' else
           y_i - TG_MUL(x_i, iteration-1);
    z_o <= z_i - ARC_TG(iteration) when d = '0' else
           z_i + ARC_TG(iteration);
end;