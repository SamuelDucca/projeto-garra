-- contagem_mm.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity contagem_mm is
    port (
        clock, conta, zera: in std_logic;
		  dig0, dig1, dig2, dig3: out std_logic_vector(3 downto 0);
		  fim: out std_logic
    );
end contagem_mm;

architecture arch_contagem_mm of contagem_mm is

    signal s_tick: std_logic;
	 
	 component contador_m
    generic (
        constant M: integer;
        constant N: integer
    );
    port (
        clock, zera, conta: in STD_LOGIC;
        Q: out STD_LOGIC_VECTOR (N-1 downto 0);
        fim, meio: out STD_LOGIC);
    end component;
	 
	 component contador_bcd is 
    port ( 
			  clock, zera, conta:      in std_logic;
           dig3, dig2, dig1, dig0: out std_logic_vector(3 downto 0);
           fim:                    out std_logic
    );
	end component;

      
begin

    BCD: contador_bcd port map (clock, zera, s_tick,
										  dig3, dig2, dig1, dig0,
                                fim);
										 
	 -- Um tick a cada 294 clocks para dividir por 58,82
	 -- Para as simulacoes foi utilizado um tick a cada 10 clocks, portanto o contador deve ir ate 10
    TICK: contador_m generic map (M => 294, N => 1) port map (clock, zera, conta, open, s_tick, open);
	
end arch_contagem_mm;

