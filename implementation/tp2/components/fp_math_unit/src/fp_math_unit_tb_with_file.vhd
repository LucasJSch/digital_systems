library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity fp_math_unit_tb_with_file is
end entity;

architecture arch of fp_math_unit_tb_with_file is
	--para seleccionar un archivo modificar N, E y el nombre del archivo
	constant N_BITS: integer := 22;	--numero de bits
	constant EXPONENT_BITS: integer := 6;	--numero de bits del exponente 
	
	file data_file : text open read_mode is "/home/ljsch/FIUBA/SisDig/repo/digital_systems/implementation/tp2/components/fp_math_unit/src/testfiles/fmul_15_6.txt";

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
	signal a_file: unsigned(N_BITS-1 downto 0):= (others => '0');
	signal b_file: unsigned(N_BITS-1 downto 0):= (others => '0');
	signal z_file: unsigned(N_BITS-1 downto 0):= (others => '0');
	signal a_tb: std_logic_vector(N_BITS-1 downto 0);
	signal b_tb: std_logic_vector(N_BITS-1 downto 0);
	signal z_tb: std_logic_vector(N_BITS-1 downto 0):= (others => '0');
	signal errors_counter : unsigned(N_BITS downto 0) := (others => '0');
	signal line_counter : unsigned(N_BITS downto 0) := (others => '0');
	
		
begin
	clk_tb <= not clk_tb after 10 ns;
		
	test_sequence: process
		variable l: line;
		variable ch: character:= ' ';
		variable aux: integer;
	begin
		while not(endfile(data_file)) loop 		-- si se quiere leer de stdin se pone "input"
			wait until rising_edge(clk_tb);
			readline(data_file, l); 			-- se lee una linea del archivo de valores de prueba
			read(l, aux); 				    	-- se extrae un entero de la linea
			
			a_file <= to_unsigned(aux, N_BITS); -- se carga el valor del operando A
			read(l, ch); 					    -- se lee un caracter (es el espacio)
			read(l, aux); 					    -- se lee otro entero de la linea
			
			b_file <= to_unsigned(aux, N_BITS); -- se carga el valor del operando B
			read(l, ch); 					    -- se lee otro caracter (es el espacio)
			read(l, aux); 					    -- se lee otro entero
			
			z_file <= to_unsigned(aux, N_BITS);	-- se carga el valor de salida (resultado)
		end loop;
	
		file_close(data_file); -- cierra el archivo
	end process test_sequence;
	
	a_tb <= std_logic_vector(a_file);
	b_tb <= std_logic_vector(b_file);
	
	
	DUT: fp_math_unit --Device under test
	generic map(N_BITS, EXPONENT_BITS)
	port map(
		clk => clk_tb,
		a => a_tb,
		b => b_tb,
		ctrl => "10", -- Multiplication flag
		z => z_tb		
	);
	
	-- Verificacion de la condicion
	
	verificacion: process
	begin
		wait until rising_edge(clk_tb);
		wait for 2 ns;
		line_counter <= line_counter + 1;
		if (unsigned(z_tb) /= z_file) and (unsigned(z_tb) /= z_file + 1) and (unsigned(z_tb) /= z_file - 1) then
			errors_counter <= errors_counter +1;
		end if;			
	end process;
	
end architecture arch;