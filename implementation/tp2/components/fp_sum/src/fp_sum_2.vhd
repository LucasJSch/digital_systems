library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp_sum is
    generic(
        N_BITS : integer := 32;
        EXPONENT_BITS : integer := 8);
	port(
        clk           : in std_logic;
		a             : in std_logic_vector(N_BITS-1 downto 0);
		b             : in std_logic_vector(N_BITS-1 downto 0);
		z             : out std_logic_vector(N_BITS-1 downto 0)
	);
end entity;

architecture fp_sum_arch of fp_sum is

    component mux is
        generic(N : integer:= 32);
        port (
            X0  : in std_logic_vector(N-1 downto 0);
            X1  : in std_logic_vector(N-1 downto 0);
            X2  : in std_logic_vector(N-1 downto 0);
            X3  : in std_logic_vector(N-1 downto 0);
            sel : in std_logic_vector(1 downto 0);
            Y   : out std_logic_vector(N-1 downto 0) 
        );
    end component;

    component normalizer is
        generic(N: integer:= 4; M: integer := 4);
        port(
            X            : in std_logic_vector(N-1 downto 0);
            g_bit        : std_logic;
            shifted_bits : out unsigned(M-1 downto 0);
            Y            : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component adder is
        generic(N: integer:= 4);
        port(
            X0        : in std_logic_vector(N-1 downto 0);
            X1        : in std_logic_vector(N-1 downto 0);
			substract : in std_logic;
			swap_ops  : in std_logic;
			Y         : out std_logic_vector(N-1 downto 0);
            carry_out : out std_logic);
    end component;

    component fp_deconstructor is
        generic(N_BITS : integer := 32; EXPONENT_BITS : integer := 8);
        port (
            -- Input lines
            A          : in std_logic_vector(N_BITS-1 downto 0);
            B          : in std_logic_vector(N_BITS-1 downto 0);
     
            A_sign     : out std_logic;
            B_sign     : out std_logic;
            --One bit is added for signed subtraction
            A_exp      : out std_logic_vector(EXPONENT_BITS downto 0);
            B_exp      : out std_logic_vector(EXPONENT_BITS downto 0);
            -- Two bits are added to mantissas.
            -- One for leading 1 and other one for storing carry.
            A_mantissa : out std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
            B_mantissa : out std_logic_vector(N_BITS-EXPONENT_BITS downto 0));
    end component;

    component aligner is
        generic(N_BITS : integer := 32; EXPONENT_BITS : integer := 8);
        port (
            A_sign     : in std_logic;
            B_sign     : in std_logic;
            A_exp      : in std_logic_vector(EXPONENT_BITS downto 0);
            B_exp      : in std_logic_vector(EXPONENT_BITS downto 0);
            A_mantissa : in std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
            B_mantissa : in std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
            
            result_sign : out std_logic;
            result_exp  : out std_logic_vector(EXPONENT_BITS downto 0);
            result_mantissa : out std_logic_vector(N_BITS-EXPONENT_BITS downto 0);

            A_mantissa_out : out std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
            B_mantissa_out : out std_logic_vector(N_BITS-EXPONENT_BITS downto 0));
    end component;

    component mantissa_adder is
        generic(N_BITS : integer := 32; EXPONENT_BITS : integer := 8);
        port (
            A_sign     : in std_logic;
            B_sign     : in std_logic;
            A_mantissa : in std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
            B_mantissa : in std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
            
            result_sign     : out std_logic;
            result_mantissa : out std_logic_vector(N_BITS-EXPONENT_BITS downto 0));
    end component;

    -- Order of bits:
    -- | SIGN_BIT | EXPONENT_BITS | MANTISSA_BITS | --
    constant MANTISSA_BITS       : integer := N_BITS - EXPONENT_BITS - 1;

    -- FP representation of zero
    constant ZERO_FP_REP         : std_logic_vector(N_BITS-1 downto 0) := (others => '0');
    -- Maximum representable FP number
    constant MAX_FP_REP          : std_logic_vector(N_BITS-1 downto 0) := 
    '0' & (N_BITS-2 downto N_BITS-EXPONENT_BITS => '1') & (N_BITS-EXPONENT_BITS-1 => '0') & (N_BITS-EXPONENT_BITS-2 downto 0 => '1');

    constant EXPONENT_BIAS       : signed(EXPONENT_BITS downto 0) := to_signed((2**EXPONENT_BITS)/2-1, EXPONENT_BITS+1);
    constant MAX_BIASED_EXPONENT : unsigned(EXPONENT_BITS downto 0) := to_unsigned((2**EXPONENT_BITS)-2, EXPONENT_BITS+1);
    constant MIN_BIASED_EXPONENT : unsigned(EXPONENT_BITS downto 0) := to_unsigned(1, EXPONENT_BITS+1);

    -- Floating point deconstruction variables.
    signal A_mantissa_1, B_mantissa_1 : std_logic_vector (MANTISSA_BITS+1 downto 0);
    signal A_exp_1, B_exp_1               : std_logic_vector (EXPONENT_BITS downto 0);
    signal A_sign_1, B_sign_1             : std_logic;

    -- Alignment variables.
    signal A_mantissa_2, B_mantissa_2 : std_logic_vector (MANTISSA_BITS+1 downto 0);
    signal result_exp_2             : std_logic_vector (EXPONENT_BITS downto 0);
    signal result_mantissa_2        : std_logic_vector (MANTISSA_BITS+1 downto 0);
    signal result_sign_2            : std_logic;

    -- Mantissa adder variables.
    signal result_sign_3            : std_logic;
    signal result_mantissa_3        : std_logic_vector (MANTISSA_BITS+1 downto 0);

begin

    -- Deconstruct inputs into smaller parts.
    fp_deconstruct : fp_deconstructor
    generic map(N_BITS, EXPONENT_BITS)
    port map(
        A => A,
        B => B,
        A_sign => A_sign_1,
        B_sign => B_sign_1,
        A_exp => A_exp_1,
        B_exp => B_exp_1,
        B_mantissa => B_mantissa_1,
        A_mantissa => A_mantissa_1);

    -- Align B's mantissa.
    aligner_module : aligner
    generic map(N_BITS, EXPONENT_BITS)
    port map(
        A_sign => A_sign_1,
        B_sign => B_sign_1,
        A_exp => A_exp_1,
        B_exp => B_exp_1,
        A_mantissa => A_mantissa_1,
        B_mantissa => B_mantissa_1,
        
        result_sign => result_sign_2,
        result_exp  => result_exp_2,
        result_mantissa => result_mantissa_2,
        A_mantissa_out => A_mantissa_2,
        B_mantissa_out => B_mantissa_2);
    
    -- Add mantissas.
    mantissa_adder_module : mantissa_adder
    generic map(N_BITS, EXPONENT_BITS)
    port map(
        A_sign => A_sign_1,
        B_sign => B_sign_1,
        B_mantissa => B_mantissa_2,
        A_mantissa => A_mantissa_2,
        
        result_sign => result_sign_3,
        result_mantissa => result_mantissa_3);

    -- if unsigned(sum_mantissa) = TO_UNSIGNED(0, MANTISSA_BITS+2) then
    --     --The sum is 0
    --     sum_mantissa <= (others => '0');  
    --     sum_exp        <= (others => '0');
    -- elsif(sum_mantissa(MANTISSA_BITS+1) = '1') then  --If sum overflowed we downshift and are done.
    --     sum_mantissa <= '0' & sum_mantissa(MANTISSA_BITS+1 downto 1);  --shift the 1 down
    --     sum_exp        <= std_logic_vector((unsigned(sum_exp)+ 1));
    -- elsif(sum_mantissa(MANTISSA_BITS) = '0') then  --in this case we need to upshift
    --         --This iterates the normalization shifts, thus can take many clocks.
    --         sum_mantissa <= sum_mantissa(MANTISSA_BITS downto 0) & '0';	
    --         sum_exp <= std_logic_vector((unsigned(sum_exp)-1));
    -- end if;
end;
