-- garra_rastreada_fd.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity garra_rastreada_fd is
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
end garra_rastreada_fd;
	
architecture garra_rastreada_fd_arch of garra_rastreada_fd is

	signal s_largura: std_logic_vector (5 downto 0);
	signal s_angulo0, s_angulo1, s_angulo2: std_logic_vector (6 downto 0);
	signal s_hexd0, s_hexd1, s_hexd2, s_hexd3,s_hexe0, s_hexe1, s_hexe2, s_hexe3: std_logic_vector (6 downto 0);
	signal s_db_bits_recebidos: std_logic_vector (10 downto 0);
	signal s_dados_recebidos: std_logic_vector (6 downto 0);
	
	--Garra
	component garra_pwm is
		port (
			clock    : in  std_logic;
			reset    : in  std_logic;
			largura  : in  std_logic_vector(1 downto 0);  --  00=0,  01=1ms  10=1.5ms  11=2ms
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
	
	--Rastreador
	component rastreador is
    port (
        clock, reset, liga, sel_hex, echo_e, echo_d: in std_logic; --sel_hex não está sendo usado, mas vc pode ligar em um mux no fd pra depurar a saida dos sensores
		  trigger_e, trigger_d, pronto: out std_logic;
		  medida_hex0, medida_hex1, medida_hex2, medida_hex3, estado_hex5: out std_logic_vector (6 downto 0); -- por default mostram o angulo do motor
		  hex_4: out std_logic_vector (6 downto 0);
		  saida_pwm: out std_logic;
		  fechar: out std_logic
    );
	end component;
	
	--RX
	component rx_serial is
		 port (
			  clock, reset, dado_serial, limpa_async: in std_logic;
			  dado_hex0, dado_hex1, db_estado: out std_logic_vector (6 downto 0);
			  db_bits_recebidos: out std_logic_vector (10 downto 0);
			  paridade_ok, pronto, db_tick: out std_logic;
			  dados_recebidos: out std_logic_vector (6 downto 0);
			  db_estado_bin: out std_logic_vector (3 downto 0);
			  db_desloca: out std_logic
		 );
	end component;
	
	--TX
	component tx_serial_tick is
    port (
        clock, reset, partida, paridade: in std_logic;
        dados_ascii: in std_logic_vector (6 downto 0);
        saida_serial, pronto, tx_andamento : out std_logic
    );
	end component;
   
	-- Comparador ascii
	component comparador_ascii is
    port (
        A:		in std_logic_vector (6 downto 0);
        result: 	out std_logic_vector (1 downto 0) --00 continua, 01 pausa
    );
	end component;
	
begin
												
	GARRA: 		garra_pwm port map (clock, '0', comando_garra, pwm_garra);
	
	--Tick a cada 1s -> 50.000.000 // espera 3s
	CONT_TICK: 	contador_m generic map (M => 150000000, N => 1) port map (clock, zera, conta_tick, open, tick_abre, open);
	
	RASTR:		rastreador port map (clock, zera, rastreia, sel_hex, echo_e, echo_d,
												trigger_e, trigger_d, open,
												medida_hex0, medida_hex1, medida_hex2, medida_hex3, open,
												hex_comparador,
												pwm_base,
												fechar);
	
	RX: rx_serial port map (clock, reset, entrada_serial, limpa_async,
									open, open, open,
									s_db_bits_recebidos,
									open, open, open,
									s_dados_recebidos,
									open, open);
									
	TX: tx_serial_tick port map (clock, '0', partida, '1', 
											tx_ascii, 
											saida_serial, pronto_tx);
	
	CMP: comparador_ascii port map (s_dados_recebidos, cmd_rx);
	
end garra_rastreada_fd_arch;
