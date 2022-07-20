library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity cordic_processor_tb_with_file is
end entity;

architecture arch of cordic_processor_tb_with_file is
	constant N_BITS_VECTOR : integer := 15;
	constant N_BITS_ANGLE  : integer := 18; 
	constant N_ITER        : integer := 15; 

    -- Bits tolerance to verify correctness of result.
    constant TOLERANCE     : signed := to_signed(10, N_BITS_VECTOR+1);
	
    -- Remember to remove header line from file, if present.
	file data_file : text open read_mode is "/home/ljsch/FIUBA/SisDig/repo/digital_systems/tp3/testing/testdata.txt";

	component cordic_processor is
	generic(
        -- Describes the amount of bits per vector element.
        N_BITS_VECTOR : integer:= 32;
        -- Describes the amount of bits to represent the angle.
        N_BITS_ANGLE : integer := 17;
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
    end component;
	
	signal clk_tb: std_logic := '0';
    -- Clock for DUT since it needs a few clk cycles to finish its work.
	signal clk_tb_internal: std_logic := '0';
	signal xi_file: signed(N_BITS_VECTOR-1 downto 0):= (others => '0');
	signal yi_file: signed(N_BITS_VECTOR-1 downto 0):= (others => '0');
	signal beta_file: signed(N_BITS_ANGLE-1 downto 0):= (others => '0');
	signal xo_file: signed(N_BITS_VECTOR downto 0):= (others => '0');
	signal yo_file: signed(N_BITS_VECTOR downto 0):= (others => '0');

	signal xi_tb: std_logic_vector(N_BITS_VECTOR-1 downto 0);
	signal yi_tb: std_logic_vector(N_BITS_VECTOR-1 downto 0);
	signal beta_tb: signed(N_BITS_ANGLE-1 downto 0):= (others => '0');
    signal start_tb : std_logic := '0';
	signal xo_tb: std_logic_vector(N_BITS_VECTOR downto 0);
	signal yo_tb: std_logic_vector(N_BITS_VECTOR downto 0);
	signal zo_tb: std_logic_vector(N_BITS_ANGLE-1 downto 0);
	signal done_tb: std_logic := '0';

	signal errors_counter : unsigned(N_BITS_VECTOR downto 0) := (others => '0');
	signal line_counter : unsigned(N_BITS_VECTOR downto 0) := (others => '0');
	
		
begin
	clk_tb      <= not clk_tb after 10 ns;
	clk_tb_internal      <= not clk_tb_internal after 500 ps;
    start_tb <= not start_tb after 10000001 fs;

	test_sequence: process
		variable l: line;
		variable ch: character:= ' ';
		variable aux: integer;
	begin
		while not(endfile(data_file)) loop 		-- si se quiere leer de stdin se pone "input"
			wait until rising_edge(clk_tb);
			readline(data_file, l); 			-- se lee una linea del archivo de valores de prueba
			read(l, aux); 				    	-- se extrae un entero de la linea
			
			xi_file <= to_signed(aux, N_BITS_VECTOR); -- se carga el valor del operando A
			read(l, ch); 					    -- se lee un caracter (es el espacio)
			read(l, aux); 					    -- se lee otro entero de la linea
			
			yi_file <= to_signed(aux, N_BITS_VECTOR); -- se carga el valor del operando B
			read(l, ch); 					    -- se lee otro caracter (es el espacio)
			read(l, aux); 					    -- se lee otro entero

            beta_file <= to_signed(aux, N_BITS_ANGLE); -- se carga el valor del operando B
			read(l, ch); 					    -- se lee otro caracter (es el espacio)
			read(l, aux); 					    -- se lee otro entero
			
            xo_file <= to_signed(aux, N_BITS_VECTOR+1); -- se carga el valor del operando B
            read(l, ch); 					    -- se lee otro caracter (es el espacio)
			read(l, aux); 					    -- se lee otro entero

            yo_file <= to_signed(aux, N_BITS_VECTOR+1); -- se carga el valor del operando B
		end loop;
	
		file_close(data_file); -- cierra el archivo
	end process test_sequence;
	
	xi_tb <= std_logic_vector(xi_file);
	yi_tb <= std_logic_vector(yi_file);
	beta_tb <= signed(beta_file);

	DUT: cordic_processor --Device under test
	generic map(N_BITS_VECTOR, N_BITS_ANGLE, N_ITER)
	port map(
		clk => clk_tb_internal,
		x1 => xi_tb,
		y1 => yi_tb,
        beta => beta_file,
        mode => '0', -- rotation mode
        start => start_tb,
        x2 => xo_tb,
        y2 => yo_tb,
        z2 => zo_tb,
        done => done_tb);

	-- Verificacion de la condicion
	verificacion: process
	begin
		wait until rising_edge(done_tb);
		wait for 2 ns;
		line_counter <= line_counter + 1;
        if ((xo_file + TOLERANCE) < signed(xo_tb)) or
           ((xo_file - TOLERANCE) > signed(xo_tb)) or
           ((yo_file + TOLERANCE) < signed(yo_tb)) or
           ((yo_file - TOLERANCE) > signed(yo_tb)) then
		    errors_counter <= errors_counter +1;
		end if;			
	end process;
	
end architecture arch;