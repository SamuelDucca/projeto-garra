-- rx_serial.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity sensor_distancia is
    port (
        clock, reset, medir, nova_medida, echo: in std_logic;
		  trigger, pronto: out std_logic;
		  medida_hex0, medida_hex1, medida_hex2, medida_hex3: out std_logic_vector (6 downto 0);
		  medida0, medida1, medida2, medida3: out std_logic_vector (3 downto 0)
		  
    );
end sensor_distancia;

architecture arch_sensor_distancia of sensor_distancia is
     
	  signal s_echo_subida, s_echo_descida, s_gera, s_zera, s_conta, s_registra: std_logic;
	  signal s_distancia: std_logic_vector (15 downto 0);

	  
    component sensor_distancia_uc port ( 
			clock, reset, medir, echo_subida, echo_descida, nova_medida: in std_logic;
			gera, zera, conta, registra, pronto: out std_logic 
			);
    end component;

    component sensor_distancia_fd port (
		clock, conta, zera, registra, gera: in std_logic;
		trigger: out std_logic;
		distancia: out std_logic_vector (15 downto 0)
    );
    end component;
	 
	 component hex7seg is
    port (
        binario : in std_logic_vector(3 downto 0);
        enable  : in std_logic;
        display : out std_logic_vector(6 downto 0)
    );
	end component;
	
	component detector_borda is
	port (
		 clock, reset  : in  std_logic;
		 entrada       : in  std_logic;
		 pulso_subida  : out std_logic;
		 pulso_descida : out std_logic );
	end component;
	 
      
begin

    UC: sensor_distancia_uc port map (clock, reset, medir, s_echo_subida, s_echo_descida, nova_medida,
													s_gera, s_zera, s_conta, s_registra, pronto);
	 

    FD: sensor_distancia_fd port map (clock, s_conta, s_zera, s_registra, s_gera,
													trigger, s_distancia);
										 
	 BORDA: detector_borda port map (clock, s_zera, echo,
												s_echo_subida, s_echo_descida);
	 
	 HEX0: hex7seg port map (s_distancia(15 downto 12), '1', medida_hex0);
	 
	 HEX1: hex7seg port map (s_distancia(11 downto 8), '1', medida_hex1);
	 
	 HEX2: hex7seg port map (s_distancia(7 downto 4), '1', medida_hex2);
	 
	 HEX3: hex7seg port map (s_distancia(3 downto 0), '1', medida_hex3);
	 
	 medida0 <= s_distancia(15 downto 12);
	 medida1 <= s_distancia(11 downto 8);
	 medida2 <= s_distancia(7 downto 4);
	 medida3 <= s_distancia(3 downto 0);
	 
	
end arch_sensor_distancia;

