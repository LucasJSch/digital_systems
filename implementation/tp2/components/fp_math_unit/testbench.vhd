--##############################################
--Multiplicador de Punto Flotante

--Facultad de ingeniería
--Universidad de Buenos Aires
--Autor: Sanchez Marcelo.
--Fecha: Noviembre de 2016.
--############################################

-- declaracion de librerias y paquetes
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

-- declaracion de entidad

entity testbench is
end entity;

architecture simulacion of testbench is
	--para seleccionar un archivo modificar N, E y el nombre del archivo
	constant N: integer :=30;	--numero de bits
	constant E: integer :=8;	--numero de bits del exponente 
	
	file datos: text open read_mode is "test_mul_float_30_8.txt";

	component multiplicador_ptof is
	generic(
		N: integer :=23;	--numero de bits
		E: integer :=6 	--numero de bits del exponente 
		-- F: integer := (N - E - 1); --numero de bits de la mantisa.
		);
	port(
		clk: in std_logic;
		opA: in std_logic_vector(N-1 downto 0);
		opB: in std_logic_vector(N-1 downto 0);
		load: in std_logic;
		flag: out std_logic;
		resultado: out std_logic_vector(N-1 downto 0)		
		);
    end component;
	
	signal clk_tb: std_logic := '0';
	signal OpA_file: unsigned(N-1 downto 0):= (others => '0');
	signal OpB_file: unsigned(N-1 downto 0):= (others => '0');
	signal result_file: unsigned(N-1 downto 0):= (others => '0');
	signal opA_tb: std_logic_vector(N-1 downto 0);
	signal opB_tb: std_logic_vector(N-1 downto 0);
	signal resultado_dut: std_logic_vector(N-1 downto 0):= (others => '0');
	signal load_tb: std_logic := '0';
	signal flag_tb: std_logic := '0';
	
		
 begin
	
	clk_tb <= not clk_tb after 10 ns; -- ES EL CLOCK DE LA FPGA
		
	--Generación de la señal de carga (load_tb)
	
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
	
	Test_Sequence: process
		variable l: line;
		variable ch: character:= ' ';
		variable aux: integer;
	begin
		while not(endfile(datos)) loop 		-- si se quiere leer de stdin se pone "input"
			wait until rising_edge(load_tb);				
			readline(datos, l); 			-- se lee una linea del archivo de valores de prueba
			read(l, aux); 					-- se extrae un entero de la linea
			
			OpA_file <= to_unsigned(aux, N); 	-- se carga el valor del operando A
			read(l, ch); 					-- se lee un caracter (es el espacio)
			read(l, aux); 					-- se lee otro entero de la linea
			
			OpB_file <= to_unsigned(aux, N); 	-- se carga el valor del operando B
			read(l, ch); 					-- se lee otro caracter (es el espacio)
			read(l, aux); 					-- se lee otro entero
			
			result_file <= to_unsigned(aux, N); 		-- se carga el valor de salida (resultado)
		end loop;
	
		file_close(datos); -- cierra el archivo
		--wait for TCK*(DELAY+1); -- se pone el +1 para poder ver los datos
		assert false report -- este assert se pone para abortar la simulacion
			"Fin de la simulacion" severity failure;
	end process Test_Sequence;
	
	opA_tb <= std_logic_vector(OpA_file);
	opB_tb <= std_logic_vector(OpB_file);
	
	
	DUT: multiplicador_ptof --Device under test
	generic map(N => N, E => E)
	port map(
		clk => clk_tb,
		opA => opA_tb,
		opB => opB_tb,
		load => load_tb,
		flag => flag_tb,
		resultado => resultado_dut		
	);
	
	-- Verificacion de la condicion
	
	verificacion: process(flag_tb)
		variable count: integer := 1; 
	begin
		if rising_edge(flag_tb) then
			count := count+1;
			assert to_integer(result_file) = to_integer(unsigned(resultado_dut)) report
			"Salida del DUT no coincide con referencia (salida del dut = " & 
			integer'image(to_integer(unsigned(resultado_dut))) &
			", salida del archivo = " &
			integer'image(to_integer(result_file)) & "), linea " & integer'image(count)
			severity error;
			
		end if;
	end process;
	
end architecture simulacion;