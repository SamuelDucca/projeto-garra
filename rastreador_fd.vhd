-- rastreador_fd.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity rastreador_fd is
    port (
			  clock, medir, reset_medir, conta_pos, conta_tick, zera, zera_pos, sentido, echo_e, echo_d, sel_hex: in std_logic;
			  trigger_e, trigger_d, pronto_e, pronto_d, tick: out std_logic;
			  direcao: out std_logic_vector(1 downto 0);
			  medida_hex0, medida_hex1, medida_hex2, medida_hex3: out std_logic_vector (6 downto 0);
			  saida_pwm: out std_logic;
			  fechar: out std_logic;
			  db_angulo0, db_angulo1, db_angulo2: out std_logic_vector(3 downto 0) --digitos do angulo em bcd
    );
end rastreador_fd;
	
architecture rastreador_fd_arch of rastreador_fd is

	signal s_largura: std_logic_vector (5 downto 0);
	signal s_angulo0, s_angulo1, s_angulo2: std_logic_vector (6 downto 0);
	signal s_hexd0, s_hexd1, s_hexd2, s_hexd3,s_hexe0, s_hexe1, s_hexe2, s_hexe3: std_logic_vector (6 downto 0);
	signal s_fim_bin, s_zera_bcd, s_pronto_e, s_pronto_d: std_logic;
	signal s_dist_d0, s_dist_d1, s_dist_d2, s_dist_d3, s_dist_e0, s_dist_e1, s_dist_e2, s_dist_e3: std_logic_vector (3 downto 0);
	signal s_anguloascii: std_logic_vector (20 downto 0);
	
	-- Sensor
	component sensor_distancia is
	port (
     clock, reset, medir, nova_medida, echo: in std_logic;
	  trigger, pronto: out std_logic;
	  medida_hex0, medida_hex1, medida_hex2, medida_hex3: out std_logic_vector (6 downto 0);
	  medida0, medida1, medida2, medida3: out std_logic_vector (3 downto 0)
	);
	end component;
	
	--Motor
	component circuito_pwm is
		port (
				clock    : in  std_logic;
				reset    : in  std_logic;
				largura  : in  std_logic_vector(5 downto 0);  --  00=0,  01=1ms  10=1.5ms  11=2ms
				pwm      : out std_logic );
	end component;
	
	--Contador bin
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
	 
	 --Contador BCD
	 component contador_bcd is 
		 port ( clock, zera, conta:      in std_logic;
				  dig3, dig2, dig1, dig0: out std_logic_vector(3 downto 0);
				  fim:                    out std_logic
		 );
	end component;
	
	-- Contador Updown
	component contador_updown is
    generic (
        constant M: integer := 31 -- modulo do contador
    );
   port (
        clock, zera, conta, sentido: in std_logic;
        Q: out std_logic_vector (5 downto 0); -- era std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
        fim, meio: out std_logic 
   );
	end component;
	
	--Conversor de bin para angulo
	component rom_generic is
		 generic ( posicoes: integer := 31;  
					  palavra: integer := 21;  
					  arq_mif: string := "rom_angulos.mif" 
		 );
		 port (endereco : in  std_logic_vector(natural(ceil(log2(real(posicoes))))-1 downto 0);
				 saida    : out std_logic_vector(palavra-1 downto 0) ); 
	end component;
	
	-- Comparador dist
	component comparador_dist is
	  port (
			dist_d0, dist_d1, dist_d2, dist_d3 : in std_logic_vector(3 downto 0); -- distancias direita, dist3 digito mais significativo
			dist_e0, dist_e1, dist_e2, dist_e3 : in std_logic_vector(3 downto 0); -- distancias esquerda, dist3 digito mais significativo
			dig3, dig2, dig1, dig0:      in std_logic_vector(3 downto 0); -- distancia para determinar alcance
			direcao : out std_logic_vector (1 downto 0); -- 00 igual, 01 esq, 10 dir
			fechar: out std_logic
		);
	end component;
	
    
begin

	SENSOR_E: sensor_distancia port map (clock, reset_medir, medir, '0', echo_e,
												trigger_e, s_pronto_e,
												s_hexe0, s_hexe1, s_hexe2, s_hexe3,
												s_dist_e0, s_dist_e1, s_dist_e2, s_dist_e3
												);
												
	SENSOR_D: sensor_distancia port map (clock, reset_medir, medir, '0', echo_d,
												trigger_d, s_pronto_d,
												s_hexd0, s_hexd1, s_hexd2, s_hexd3,
												s_dist_d0, s_dist_d1, s_dist_d2, s_dist_d3
												);
												
	MOTOR: circuito_pwm port map (clock, '0', s_largura, saida_pwm);
	
	COMP: comparador_dist port map (s_dist_d0, s_dist_d1, s_dist_d2, s_dist_d3,
											s_dist_e0, s_dist_e1, s_dist_e2, s_dist_e3,
											"0000", "0011", "0000", "0000", --- 0 3 0 0 mm
											direcao, fechar);
	
	
	--Tick a cada 1s -> 50.000.000
	CONT_TICK: contador_m generic map (M => 5000000, N => 1) port map (clock, zera, conta_tick, open, tick, open);
	
	CONT_POS: contador_updown generic map (M => 31) port map (clock, zera_pos, conta_pos, sentido, s_largura, s_fim_bin, open);
	
	CONVERT: rom_generic generic map (posicoes => 64, palavra => 21, arq_mif => "rom_angulos.mif") port map (s_largura, s_anguloascii);
	
	
	s_angulo0 <= s_anguloascii(6 downto 0);
	s_angulo1 <= s_anguloascii(13 downto 7);
	s_angulo2 <= s_anguloascii(20 downto 14);
	 
	s_zera_bcd <= s_fim_bin or zera_pos;
	db_angulo0 <= s_angulo0(3 downto 0);
	db_angulo1 <= s_angulo1(3 downto 0);
	db_angulo2 <= s_angulo2(3 downto 0);
	
	-- Por padrao mostra o do sensor da direita, mas vc pode colocar em um mux pra chavear com sel_hex se quiser ver o outro
	medida_hex0 <= s_hexd0;
	medida_hex1 <= s_hexd1;
	medida_hex2 <= s_hexd2;
	medida_hex3 <= s_hexd3;

	
	pronto_e <= s_pronto_e;
	pronto_d <= s_pronto_d; --ATENÇÃO: Aqui parte do pressuposto que o sensor que terminar a medida
																 -- primeiro não vai começar a medir de novo e vai manter o "pronto" até o outro
																-- sensor terminar. Se esse não for o caso, você vai ter que modificar a maquina de
																-- estados e setar o sinal nova_medida do sensor_distancia só na hora certa
	
end rastreador_fd_arch;
