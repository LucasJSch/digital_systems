library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cordic_rotator is
    -- Describes the amount of bits per vector element.
	generic(
        N_BITS : integer:= 32;
        N_ITER : integer := 10);
    port(
        clk  : in std_logic;
        x1   : in std_logic_vector(N_BITS-1 downto 0);
        y1   : in std_logic_vector(N_BITS-1 downto 0);
        beta : in signed(N_BITS-1 downto 0);
        x2   : out std_logic_vector(N_BITS-1 downto 0);
        y2   : out std_logic_vector(N_BITS-1 downto 0));

end;

architecture iterative_arch of cordic_rotator is

    function ARCTG(i : integer)
    return std_logic_vector is
    begin
    end ARCTG;

begin
    process (x1, y1, beta)
    begin
        type d_type                is array (0 to N_ITER-1) of std_logic;
        type x_type                is array (0 to N_ITER-1) of std_logic_vector(N_BITS-1 downto 0);
        type y_type                is array (0 to N_ITER-1) of std_logic_vector(N_BITS-1 downto 0);
        -- Distance to desired angle.
        type z_type                is array (0 to N_ITER-1) of signed(N_BITS-1 downto 0);
        variable d : d_type;
        variable x : x_type;
        variable y : y_type;
        variable z : r_type;
        if rising_edge(clk) = '1' then
                for i in 0 to N_ITER-1 loop
                    if (i = 0) then
                        d(i) := '0';
                        x(i) := x1;
                        y(i) := y1;
                        z(i) := beta;
                    else
                        if (d(i-1) = '0') then
                            x(i) := x(i-1) - y(i-1) * TG(i);
                            y(i) := y(i-1) + x(i-1) * TG(i);
                            z(i) := z(i-1) - ARCTG(i);
                        else
                            x(i) := x(i-1) + y(i-1) * TG(i);
                            y(i) := y(i-1) - x(i-1) * TG(i);
                            z(i) := z(i-1) + ARCTG(i);
                        end if;
                        if (z(i) > 0) then
                            d(i) := '0';
                        else
                            d(i) := '1';
                        end if;
                    end if;
                end loop;
                Y <= out_aux(N-1);				
                shifted_bits <= shifted_bits_aux(N-1);				
        end if;
    end process;
end;