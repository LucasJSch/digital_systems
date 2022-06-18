library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp_mul is
    generic(
            N_BITS : integer := 32;
            EXPONENT_BITS : integer := 8);
	port(
        clk : in  std_logic;
		a   : in  std_logic_vector(N_BITS-1 downto 0);
		b   : in std_logic_vector(N_BITS-1 downto 0);
		z   : out std_logic_vector(N_BITS-1 downto 0)
	);
end entity;

architecture fp_mul_arch of fp_mul is

    component mux is
        generic(N : integer:= N_BITS);
        port (
            X0  : in std_logic_vector(N-1 downto 0);
            X1  : in std_logic_vector(N-1 downto 0);
            X2  : in std_logic_vector(N-1 downto 0);
            X3  : in std_logic_vector(N-1 downto 0);
            sel : in std_logic_vector(1 downto 0);
            Y   : out std_logic_vector(N-1 downto 0) 
        );
    end component;

    -- Order of bits:
    -- | SIGN_BIT | EXPONENT_BITS | MANTISSA_BITS | --
	constant SIGN_BITS           : integer := 1;
    constant MANTISSA_BITS       : integer := N_BITS - EXPONENT_BITS - SIGN_BITS;

    -- FP representation of zero
    constant ZERO_FP_REP         : std_logic_vector(N_BITS-1 downto 0) := (others => '0');
    -- Maximum representable FP number
    constant MAX_FP_REP          : std_logic_vector(N_BITS-1 downto 0) := 
        '0' & (N_BITS-2 downto N_BITS-EXPONENT_BITS-1 => '1') & (N_BITS-EXPONENT_BITS-2 => '0') & (N_BITS-EXPONENT_BITS-3 downto 0 => '1');

    constant EXPONENT_BIAS       : signed(EXPONENT_BITS downto 0) := to_signed((2**EXPONENT_BITS)/2-1, EXPONENT_BITS+1);
    constant MAX_BIASED_EXPONENT : unsigned(EXPONENT_BITS downto 0) := to_unsigned((2**EXPONENT_BITS)-2, EXPONENT_BITS+1);
    constant MIN_BIASED_EXPONENT : unsigned(EXPONENT_BITS downto 0) := to_unsigned(1, EXPONENT_BITS+1);

    constant SIGN_START_BIT      : integer := N_BITS - SIGN_BITS;
    constant SIGN_END_BIT        : integer := SIGN_START_BIT - SIGN_BITS + 1;

    constant EXPONENT_START_BIT  : integer := SIGN_END_BIT - 1;
    constant EXPONENT_END_BIT    : integer := EXPONENT_START_BIT - EXPONENT_BITS + 1;

    constant MANTISSA_START_BIT  : integer := EXPONENT_END_BIT - 1;
    constant MANTISSA_END_BIT    : integer := 0;


    signal result_sign           : std_logic := '0';
	signal result_exponent       : unsigned(EXPONENT_BITS+1 downto 0) := (others => '0');
	signal result_mantissa       : unsigned(MANTISSA_BITS-1 downto 0) := (others => '0');

    -- Exponent registers need one more bit to be able to compute the unsigned operations.
    signal a_exp                 : signed(EXPONENT_BITS downto 0) := (others => '0');
    signal b_exp                 : signed(EXPONENT_BITS downto 0) := (others => '0');
    signal aux_exp               : signed(EXPONENT_BITS downto 0) := (others => '0');

    -- Significand registers need two more bit to be able to detect overflow and add the '1' bit on top.
    signal a_mantissa            : unsigned(MANTISSA_BITS downto 0);
    signal b_mantissa            : unsigned(MANTISSA_BITS downto 0);
    signal aux_mantissa          : unsigned(MANTISSA_BITS*2+1 downto 0);

    signal output_sel            : std_logic_vector(1 downto 0) := "00";

begin
    
    -- Compute sign
    result_sign <= a(SIGN_START_BIT) xor b(SIGN_START_BIT);
    
    -- Compute exponent
    a_exp <= signed("0" & a(EXPONENT_START_BIT downto EXPONENT_END_BIT));
    b_exp <= signed("0" & b(EXPONENT_START_BIT downto EXPONENT_END_BIT));
    aux_exp <= a_exp + b_exp - EXPONENT_BIAS;

    -- Compute mantissa
    a_mantissa <= unsigned("1" & a(MANTISSA_START_BIT downto MANTISSA_END_BIT));
    b_mantissa <= unsigned("1" & b(MANTISSA_START_BIT downto MANTISSA_END_BIT));
    aux_mantissa <= a_mantissa * b_mantissa;

    -- Shifting mantissa if necessary
    mantissa_shift: process(aux_mantissa, aux_exp)
	begin
		if aux_mantissa(MANTISSA_BITS*2+1) = '1' then
			result_mantissa <= aux_mantissa(MANTISSA_BITS*2 downto MANTISSA_BITS+1);
			result_exponent <= unsigned(aux_exp + to_signed(1, result_exponent'length));
		else
            result_mantissa <= unsigned(signed(aux_mantissa(2*MANTISSA_BITS-1 downto MANTISSA_BITS)));
			result_exponent <= unsigned(signed("0" & aux_exp));
		end if;		
	end process;

    multiplexer: mux
	generic map(N_BITS)
    port map (
        X0  => ZERO_FP_REP,
		X1  => ZERO_FP_REP,
        X2  => MAX_FP_REP,
		X3  => result_sign & std_logic_vector(result_exponent(EXPONENT_BITS-1 downto 0)) & std_logic_vector(result_mantissa),	
		sel => output_sel,
		Y	=> z);
        
    output_sel <= "00" when (to_integer(unsigned(a(N_BITS-2 downto 0)))= 0 or to_integer(unsigned(b(N_BITS-2 downto 0)))= 0) else
                  "01" when (to_integer(signed(result_exponent)) < to_integer(MIN_BIASED_EXPONENT)) else
                  "10" when (to_integer(signed(result_exponent)) > to_integer(MAX_BIASED_EXPONENT)) else
                  "11";
end;
