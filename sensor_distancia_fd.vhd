-- sensor_distancia_fd.vhd
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sensor_distancia_fd is
    port (
		clock, conta, zera, registra, gera: in std_logic;
		trigger: out std_logic;
		distancia: out std_logic_vector (15 downto 0)
    );
end sensor_distancia_fd;

architecture sensor_distancia_fd_arch of sensor_distancia_fd is

	 signal s_dig0, s_dig1, s_dig2, s_dig3: std_logic_vector(3 downto 0);
	 signal s_fim: std_logic;
	 signal s_entrada_reg: std_logic_vector(15 downto 0);

	component contagem_mm is
    port (
        clock, conta, zera: in std_logic;
		  dig0, dig1, dig2, dig3: out std_logic_vector(3 downto 0);
		  fim: out std_logic
    );
	end component;


	component gerador_pulso is
   generic (
      largura: integer:= 500 -- Para gerar pulso de 10us com clock de 50MHz
   );
   port(
      clock, reset:   in std_logic;
      gera, para:     in std_logic;
      pulso, pronto: out std_logic
   );
	end component;
	 
  component registrador_n is
  generic (
       constant N: integer := 16 );
  port (clock, clear, enable: in std_logic;
        D: in std_logic_vector(N-1 downto 0);
        Q: out std_logic_vector (N-1 downto 0) );
  end component;
    
begin

					  
	 s_entrada_reg <= s_dig0 & s_dig1 & s_dig2 & s_dig3;
	
    U1: gerador_pulso port map (clock, zera, gera, '0', trigger, open);
		
	 U2: contagem_mm port map (clock, conta, zera,
										s_dig0, s_dig1, s_dig2, s_dig3, s_fim);
										
	 U3: registrador_n port map (clock, zera, registra, s_entrada_reg, distancia);
    
end sensor_distancia_fd_arch;
