-- rastreador.vhd
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rastreador is
    port (
        clock, reset, liga, sel_hex, echo_e, echo_d: in std_logic; --sel_hex não está sendo usado, mas vc pode ligar em um mux no fd pra depurar a saida dos sensores
		  trigger_e, trigger_d, pronto: out std_logic;
		  medida_hex0, medida_hex1, medida_hex2, medida_hex3, estado_hex5: out std_logic_vector (6 downto 0); -- por default mostram o angulo do motor
		  hex_4: out std_logic_vector (6 downto 0);
		  saida_pwm: out std_logic;
		  fechar: out std_logic
    );
end rastreador;

architecture arch_rastreador of rastreador is
     
	signal s_pronto_e, s_pronto_d, s_tick, s_medir, s_reset_medir, s_conta_pos, s_conta_tick, s_zera, s_zera_pos, s_sentido: std_logic;
	signal s_direcao: std_logic_vector (1 downto 0);
	signal s_db_angulo0, s_db_angulo1, s_db_angulo2, s_db_estado: std_logic_vector(3 downto 0);
	signal s_medida_hex0, s_medida_hex1, s_medida_hex2, s_medida_hex3: std_logic_vector(6 downto 0); -- medidas do sensor
	

	component rastreador_fd is
		 port (
				  clock, medir, reset_medir, conta_pos, conta_tick, zera, zera_pos, sentido, echo_e, echo_d, sel_hex: in std_logic;
				  trigger_e, trigger_d, pronto_e, pronto_d, tick: out std_logic;
				  direcao: out std_logic_vector(1 downto 0);
				  medida_hex0, medida_hex1, medida_hex2, medida_hex3: out std_logic_vector (6 downto 0);
				  saida_pwm: out std_logic;
				  fechar: out std_logic;
				  db_angulo0, db_angulo1, db_angulo2: out std_logic_vector(3 downto 0) --digitos do angulo em bcd
		 );
	end component;
	
	component rastreador_uc is 
	  port ( clock, reset, liga, pronto_e, pronto_d, tick: in std_logic;
				direcao: in std_logic_vector (1 downto 0); -- 00 igual, 01 esq, 10 dir
				medir, reset_medir, conta_pos, conta_tick, zera, zera_pos, sentido: out std_logic;
				db_estado: out std_logic_vector(3 downto 0)
				);
	end component;
	
	component hex7seg is
    port (
        binario : in std_logic_vector(3 downto 0);
        enable  : in std_logic;
        display : out std_logic_vector(6 downto 0)
    );
	end component;
	
      
begin


    UC: rastreador_uc port map (clock, reset, liga, s_pronto_e, s_pronto_d, s_tick,
											s_direcao,
											s_medir, s_reset_medir, s_conta_pos, s_conta_tick, s_zera, s_zera_pos, s_sentido,
											s_db_estado);
	 

    FD: rastreador_fd port map (clock, s_medir, s_reset_medir, s_conta_pos, s_conta_tick, s_zera, s_zera_pos, s_sentido, echo_e, echo_d, sel_hex,
									trigger_e, trigger_d, s_pronto_e, s_pronto_d, s_tick,
									s_direcao,
									s_medida_hex0, s_medida_hex1, s_medida_hex2, s_medida_hex3,
									saida_pwm,
									fechar,
									s_db_angulo0, s_db_angulo1, s_db_angulo2
									);
	
	 HEX5: hex7seg port map (s_db_estado, '1', estado_hex5);
	 
	 HEX4: hex7seg port map ("00" & s_direcao , '1', hex_4);

	 --HEXA0: hex7seg port map (s_db_angulo0, '1', medida_hex0);

	 --HEXA1: hex7seg port map (s_db_angulo1, '1', medida_hex1);

	 --HEXA2: hex7seg port map (s_db_angulo2, '1', medida_hex2);
	 
	 medida_hex0 <= s_medida_hex1;
	 medida_hex1 <= s_medida_hex2;
	 medida_hex2 <= s_medida_hex3;
	
end arch_rastreador;

