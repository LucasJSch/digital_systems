library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- TODO: Make this generic.
entity cordic_rotator is
	generic(
        -- Describes the amount of bits per vector element.
        N_BITS_VECTOR : integer:= 32;
        -- Describes the amount of bits to represent the angle.
        N_BITS_ANGLE : integer:= 32;
        -- Describes the amount of iterations to compute the result.
        N_ITER : integer := 10);
    port(
        clk  : in std_logic;
        x1   : in std_logic_vector(N_BITS_VECTOR-1 downto 0);
        y1   : in std_logic_vector(N_BITS_VECTOR-1 downto 0);
        beta : in signed(N_BITS_VECTOR-1 downto 0);
        x2   : out std_logic_vector(N_BITS_VECTOR-1 downto 0);
        y2   : out std_logic_vector(N_BITS_VECTOR-1 downto 0));

end;

architecture iterative_arch of cordic_rotator is

    -- component arc_tg is
    --     generic(N : integer := 32);
    --     port(
    --         i : in integer;
    --         z : out std_logic_vector(N-1 downto 0));
    
    -- end component;

    function ARC_TG(i : unsigned(3 downto 0))
    return signed is
        variable aux : signed(N_BITS_VECTOR-1 downto 0);
    begin
        aux :=  to_signed(1024,N_BITS_VECTOR) when i = "0000" else
                to_signed(604,N_BITS_VECTOR)  when i = "0001" else
                to_signed(188,N_BITS_VECTOR)  when i = "0010" else
                to_signed(30,N_BITS_VECTOR)  when i = "0011" else
                to_signed(2,N_BITS_VECTOR)  when i = "0100" else
                to_signed(0,N_BITS_VECTOR)  when i = "0101" else
                to_signed(0,N_BITS_VECTOR)  when i = "0110" else
                to_signed(0,N_BITS_VECTOR)  when i = "0111" else
                to_signed(0,N_BITS_VECTOR)  when i = "1000" else
                to_signed(0,N_BITS_VECTOR)  when i = "1001" else
                to_signed(0,N_BITS_VECTOR)  when i = "1010" else
                to_signed(0,N_BITS_VECTOR);
        return aux;
    end ARC_TG;

    function TG_MUL(x : signed(N_BITS_VECTOR-1 downto 0); i : integer)
    return signed is
    begin
        return signed(shift_right(unsigned(x), i));
    end TG_MUL;

begin
    process (x1, y1, beta, clk)
    type d_type is array (0 to N_ITER-1) of std_logic;
    type x_type is array (0 to N_ITER-1) of signed(N_BITS_VECTOR-1 downto 0);
    type y_type is array (0 to N_ITER-1) of signed(N_BITS_VECTOR-1 downto 0);
    type z_type is array (0 to N_ITER-1) of signed(N_BITS_VECTOR-1 downto 0);
    variable d : d_type;
    variable x : x_type;
    variable y : y_type;
    variable z : z_type;
    begin
        -- Distance to desired angle.
        if rising_edge(clk) then
                for i in 0 to N_ITER-1 loop
                    if (i = 0) then
                        d(i) := '0';
                        x(i) := signed(x1);
                        y(i) := signed(y1);
                        z(i) := signed(beta);
                    else
                        if (d(i-1) = '0') then
                            x(i) := x(i-1) - TG_MUL(y(i-1), i);
                            y(i) := y(i-1) + TG_MUL(x(i-1), i);
                            z(i) := z(i-1) - ARC_TG(to_unsigned(i, 4));
                        else
                            x(i) := x(i-1) + TG_MUL(y(i-1), i);
                            y(i) := y(i-1) - TG_MUL(x(i-1), i);
                            z(i) := z(i-1) + ARC_TG(to_unsigned(i, 4));
                        end if;
                        if (z(i) > 0) then
                            d(i) := '0';
                        else
                            d(i) := '1';
                        end if;
                    end if;
                end loop;
                x2 <= std_logic_vector(x(N_ITER-1));
                y2 <= std_logic_vector(y(N_ITER-1));
        end if;
    end process;
end;