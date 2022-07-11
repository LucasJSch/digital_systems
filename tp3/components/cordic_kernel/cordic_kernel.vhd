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

    component atan_rom is
        generic(
            ADDR_W  : natural := 4;
            DATA_W : natural := 17);
        port(
            addr_i : in std_logic_vector(ADDR_W-1 downto 0);
            data_o : out std_logic_vector(DATA_W-1 downto 0));
    end component;

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

    signal atan : std_logic_vector(N_BITS_ANGLE-1 downto 0);
begin

    atan_computation : atan_rom
    generic map(N_BITS_ANGLE, N_BITS_ANGLE)
    port map(
        addr_i => std_logic_vector(iteration-1),
        data_o => atan
    );

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
    z_o <= z_i - signed(atan) when d = '0' else
           z_i + signed(atan);
end;