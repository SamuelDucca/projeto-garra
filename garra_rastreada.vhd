-- garra_rastreada.vhd
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity garra_rastreada is
    port (
        clock, reset, liga, sel_hex, echo_e, echo_d, abre: in std_logic;
		  entrada_serial: in std_logic;
		  trigger_e, trigger_d: out std_logic;
		  medida_hex0, medida_hex1, medida_hex2, medida_hex3, estado_hex5: out std_logic_vector (6 downto 0); -- por default mostram o angulo do motor
		  hex_4: out std_logic_vector (6 downto 0);
		  pwm_base, pwm_garra, saida_serial: out std_logic;
		  fechar, db_zera: out std_logic
    );
end garra_rastreada;

architecture arch_garra_rastreada of garra_rastreada is
     
	signal s_tick_abre, s_fecha, s_rastreia, s_conta_tick, s_zera, s_limpa_async, s_partida, s_pronto_tx: std_logic;
	signal s_comando_garra, s_cmd_rx: std_logic_vector (1 downto 0);
	signal s_db_estado: std_logic_vector(3 downto 0);
	signal s_medida_hex0, s_medida_hex1, s_medida_hex2, s_medida_hex3, s_tx_ascii: std_logic_vector(6 downto 0); -- medidas do sensor
	

	component garra_rastreada_uc is 
	  port ( clock, reset, liga, fecha, abre, tick_abre, pronto_tx: in std_logic;
				cmd_rx: in std_logic_vector (1 downto 0); -- 00 fecha, 01 abre
				comando_garra: out std_logic_vector (1 downto 0); -- 00 igual, 01 esq, 10 dir
				rastreia, conta_tick, zera, limpa_async, partida: out std_logic;
				tx_ascii: out std_logic_vector(6 downto 0); -- 1100001 = "a"; 1100110 = "f";
				db_estado: out std_logic_vector(3 downto 0)
				);
	end component;
	
	component garra_rastreada_fd is
    port (
			  clock, reset, limpa_async, rastreia, conta_tick, zera, echo_e, echo_d, sel_hex, partida: in std_logic;
			  comando_garra: in std_logic_vector(1 downto 0);
			  entrada_serial: in std_logic;
			  tx_ascii:	in std_logic_vector(6 downto 0); -- 1100001 = "a"; 1100110 = "f";
			  cmd_rx: out std_logic_vector(1 downto 0); -- 00 fecha, 01 abre
			  trigger_e, trigger_d, tick_abre: out std_logic;
			  medida_hex0, medida_hex1, medida_hex2, medida_hex3, hex_comparador: out std_logic_vector (6 downto 0);
			  pwm_base, pwm_garra: out std_logic;
			  saida_serial, pronto_tx: out std_logic;
			  fechar: out std_logic
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

    UC: garra_rastreada_uc port map (clock, reset, liga, s_fecha, abre, s_tick_abre, s_pronto_tx,
												s_cmd_rx,
												s_comando_garra,
												s_rastreia, s_conta_tick, s_zera, s_limpa_async, s_partida,
												s_tx_ascii,
												s_db_estado);
	 

    FD: garra_rastreada_fd port map (clock, reset, s_limpa_async, s_rastreia, s_conta_tick, s_zera, echo_e, echo_d, sel_hex, s_partida,
												s_comando_garra,
												entrada_serial,
												s_tx_ascii,
												s_cmd_rx,
												trigger_e, trigger_d, s_tick_abre,
												medida_hex0, medida_hex1, medida_hex2, medida_hex3, hex_4,
												pwm_base, pwm_garra,
												saida_serial, s_pronto_tx,
												s_fecha);
	
	 HEX5: hex7seg port map (s_db_estado, '1', estado_hex5);
	
	db_zera <= s_zera;
	fechar <= s_fecha;
	
end arch_garra_rastreada;

