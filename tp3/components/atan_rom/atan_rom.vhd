library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity atan_rom is
	generic(
		ADDR_W  : natural := 4;
		DATA_W : natural := 17);
	port(
		addr_i : in std_logic_vector(ADDR_W-1 downto 0);
		data_o : out std_logic_vector(DATA_W-1 downto 0));
end entity atan_rom;


architecture atan_rom_arch of atan_rom is

	type rom_type is array (natural range <>) of std_logic_vector(DATA_W-1 downto 0);

	function atan (constant index : natural) return std_logic_vector is
    begin
		return
        std_logic_vector(to_unsigned(integer(round( (arctan(real(2)**real(-1*index)) / arctan(real(1))) * real(2**(DATA_W-3)) )), DATA_W));
	end;

	signal rom : rom_type(0 to DATA_W-1);


begin
	Load_ROM : for i in 0 to DATA_W-1 generate
		rom(i) <= atan(i);
	end generate Load_ROM;
    
	process(addr_i)
	begin
		if (signed(addr_i) < to_signed(0, ADDR_W) or signed(addr_i) > to_signed(DATA_W-1, ADDR_W)) then
			data_o <= (others => '0');
		else
			data_o <= rom(to_integer(unsigned(addr_i)));
		end if;
	end process;
end atan_rom_arch;