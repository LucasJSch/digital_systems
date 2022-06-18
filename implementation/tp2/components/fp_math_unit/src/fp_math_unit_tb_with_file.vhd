library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity testbench is
end entity;

architecture simulacion of testbench is
	--para seleccionar un archivo modificar N, E y el nombre del archivo
	constant N_BITS: integer := 32;	--numero de bits
	constant EXPONENT_BITS: integer := 8;	--numero de bits del exponente 
	
	file data_file : text open read_mode is "test_mul_float_32_8.txt";

	component fp_math_unit is
		generic(
			N_BITS : integer := 32;
			EXPONENT_BITS : integer := 8);
		port(
			clk           : in std_logic;
			a             : in std_logic_vector(N_BITS-1 downto 0);
			b             : in std_logic_vector(N_BITS-1 downto 0);
			-- 00: Sum; 01: Substract ; 10: Multiply; 11: Sum.
			ctrl          : in std_logic_vector(1 downto 0);
			z             : out std_logic_vector(N_BITS-1 downto 0));
    end component;
	
	signal clk_tb: std_logic := '0';
	signal a_file: unsigned(N-1 downto 0):= (others => '0');
	signal b_file: unsigned(N-1 downto 0):= (others => '0');
	signal z_file: unsigned(N-1 downto 0):= (others => '0');
	signal a_tb: std_logic_vector(N-1 downto 0);
	signal b_tb: std_logic_vector(N-1 downto 0);
	signal z_tb: std_logic_vector(N-1 downto 0):= (others => '0');
	signal load_tb: std_logic := '0';
	signal flag_tb: std_logic := '0';
	
		
 begin
	
	clk_tb <= not clk_tb after 10 ns;
		
	load: process(clk_tb)
	begin
		if rising_edge(clk_tb) then
			if (flag_tb = '1') then
				load_tb <= '1';
			else
				load_tb <= '0';
			end if;
		end if;
	end process load;
	
	test_Sequence: process
		variable l: line;
		variable ch: character:= ' ';
		variable aux: integer;
	begin
		while not(endfile(datos)) loop 		-- si se quiere leer de stdin se pone "input"
			wait until rising_edge(load_tb);				
			readline(datos, l); 			-- se lee una linea del archivo de valores de prueba
			read(l, aux); 					-- se extrae un entero de la linea
			
			a_file <= to_unsigned(aux, N); 	-- se carga el valor del operando A
			read(l, ch); 					-- se lee un caracter (es el espacio)
			read(l, aux); 					-- se lee otro entero de la linea
			
			b_file <= to_unsigned(aux, N); 	-- se carga el valor del operando B
			read(l, ch); 					-- se lee otro caracter (es el espacio)
			read(l, aux); 					-- se lee otro entero
			
			z_file <= to_unsigned(aux, N); 		-- se carga el valor de salida (resultado)
		end loop;
	
		file_close(datos); -- cierra el archivo
		--wait for TCK*(DELAY+1); -- se pone el +1 para poder ver los datos
		assert false report -- este assert se pone para abortar la simulacion
			"Fin de la simulacion" severity failure;
	end process Test_Sequence;
	
	a_tb <= std_logic_vector(a_file);
	b_tb <= std_logic_vector(b_file);
	
	
	DUT: fp_math_unit --Device under test
	generic map(N => N, E => E)
	port map(
		clk => clk_tb,
		a => a_tb,
		b => b_tb,
		ctrl => "00",
		z => z_tb		
	);
	
	-- Verificacion de la condicion
	
	verificacion: process(flag_tb)
		variable count: integer := 1; 
	begin
		if rising_edge(flag_tb) then
			count := count+1;
			assert to_integer(z_file) = to_integer(unsigned(z_tb)) report
			"Salida del DUT no coincide con referencia (salida del dut = " & 
			integer'image(to_integer(unsigned(z_tb))) &
			", salida del archivo = " &
			integer'image(to_integer(result_file)) & "), linea " & integer'image(count)
			severity error;
			
		end if;
	end process;
	
end architecture simulacion;