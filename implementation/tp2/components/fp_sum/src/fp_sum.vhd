library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Entity to sum two floating point numbers.
entity fp_sum is
    generic(
        N_BITS : integer := 32;
        EXPONENT_BITS : integer := 8);
	port(
        clk : in std_logic;
		a   : in std_logic_vector(N_BITS-1 downto 0);
		b   : in std_logic_vector(N_BITS-1 downto 0);
		z   : out std_logic_vector(N_BITS-1 downto 0)
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
            B_mantissa_out : out std_logic_vector(N_BITS-EXPONENT_BITS downto 0);
            
            result_ready   : out std_logic);
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

    -- Step 1: Floating point deconstruction variables.
    signal A_mantissa_1, B_mantissa_1 : std_logic_vector(MANTISSA_BITS+1 downto 0);
    signal A_exp_1, B_exp_1           : std_logic_vector(EXPONENT_BITS downto 0);
    signal A_sign_1, B_sign_1         : std_logic;

    -- Step 2: Mantissa alignment variables.
    signal A_mantissa_2, B_mantissa_2 : std_logic_vector(MANTISSA_BITS+1 downto 0);
    signal result_exp_2               : std_logic_vector(EXPONENT_BITS downto 0);
    signal result_mantissa_2          : std_logic_vector(MANTISSA_BITS+1 downto 0);
    signal result_sign_2              : std_logic;
    signal result_ready               : std_logic;

    -- Step 3: Mantissa addition variables.
    signal result_sign_3            : std_logic;
    signal result_mantissa_3        : std_logic_vector(MANTISSA_BITS+1 downto 0);
    
    -- Step 4: Mantissa normalization variables.
    signal normalized_mantissa      : std_logic_vector(MANTISSA_BITS downto 0);
    signal shifted_mantissa_bits    : unsigned(EXPONENT_BITS downto 0);
    signal result_exp_4             : std_logic_vector(EXPONENT_BITS downto 0);
    signal result_mantissa_4        : std_logic_vector(MANTISSA_BITS+1 downto 0);

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
        B_mantissa_out => B_mantissa_2,
        result_ready => result_ready);

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

    -- Normalize mantissa.
    mantissa_normalizer : normalizer
    generic map(MANTISSA_BITS+1, EXPONENT_BITS+1)
    port map (
        X => std_logic_vector(result_mantissa_3(MANTISSA_BITS downto 0)),
        g_bit => '0',	
        shifted_bits => shifted_mantissa_bits,
        Y => normalized_mantissa);
    
    process(result_mantissa_3, result_exp_2,
            normalized_mantissa, shifted_mantissa_bits)
    begin
        if unsigned(result_mantissa_3) = TO_UNSIGNED(0, MANTISSA_BITS+2) then
            result_mantissa_4 <= (others => '0');  
            result_exp_4 <= (others => '0');
        elsif(result_mantissa_3(MANTISSA_BITS+1) = '1') then
            result_mantissa_4 <= '0' & result_mantissa_3(MANTISSA_BITS+1 downto 1);
            result_exp_4 <= std_logic_vector((unsigned(result_exp_2)+ 1));
        elsif(result_mantissa_3(MANTISSA_BITS) = '0') then
            result_mantissa_4 <= '0' & normalized_mantissa;	
            result_exp_4 <= std_logic_vector((unsigned(result_exp_2)-shifted_mantissa_bits));
        else
            result_mantissa_4 <= result_mantissa_3;	
            result_exp_4 <= result_exp_2;
        end if;
    end process;

    -- Wrapping up final result. 
    process(result_ready,
    result_mantissa_4, result_exp_4, result_sign_3,
    result_mantissa_2, result_exp_2, result_sign_2)
    begin
        if (result_ready = '0') then
            z(MANTISSA_BITS-1 downto 0) <= result_mantissa_4(MANTISSA_BITS-1 downto 0);
            z(N_BITS-2 downto MANTISSA_BITS) <= result_exp_4(EXPONENT_BITS-1 downto 0);
            z(N_BITS-1) <= result_sign_3;
        else
            z(MANTISSA_BITS-1 downto 0) <= result_mantissa_2(MANTISSA_BITS-1 downto 0);
            z(N_BITS-2 downto MANTISSA_BITS) <= result_exp_2(EXPONENT_BITS-1 downto 0);
            z(N_BITS-1) <= result_sign_2;
        end if;
    end process;
end;
