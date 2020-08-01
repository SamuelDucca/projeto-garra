-- rx_serial.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rx_serial is
    port (
        clock, reset, dado_serial, limpa_async: in std_logic;
		  dado_hex0, dado_hex1, db_estado: out std_logic_vector (6 downto 0);
		  db_bits_recebidos: out std_logic_vector (10 downto 0);
        paridade_ok, pronto, db_tick: out std_logic;
		  dados_recebidos: out std_logic_vector (6 downto 0);
		  db_estado_bin: out std_logic_vector (3 downto 0);
		  db_desloca: out std_logic
    );
end rx_serial;

architecture arch_rx_serial of rx_serial is
    signal s_reset, s_partida: std_logic;
    signal s_zera, s_conta, s_carrega, s_desloca, s_limpa, s_registra, s_fim, s_tick: std_logic;
	 signal s_dados_recebidos: std_logic_vector(6 downto 0);
	 signal s_estado: std_logic_vector(3 downto 0);
     
    component rx_serial_uc port ( 
			clock, reset, dado_serial, fim, tick: in std_logic;
         zera, conta, carrega, desloca, limpa, registra, pronto: out std_logic;
			estado: out std_logic_vector(3 downto 0) );
    end component;

    component rx_serial_fd port (
        clock, zera, conta, carrega, desloca, limpa, registra, limpa_async: in std_logic;
        dado_serial: in std_logic;
        paridade_ok, fim : out std_logic;
		  dado_recebido: out std_logic_vector (6 downto 0);
		  db_bits_recebidos: out std_logic_vector (10 downto 0)
		  );
    end component;
	 
	 component hex7seg is
    port (
        binario : in std_logic_vector(3 downto 0);
        enable  : in std_logic;
        display : out std_logic_vector(6 downto 0)
    );
	end component;
	 
	 --mOdificar!
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
      
begin


    -- sinais reset e partida mapeados em botoes (ativos em baixo)
    --s_reset <= not reset;
    --s_partida <= not partida;
    -- sinais reset e partida mapeados na GPIO (ativos em alto)
		s_reset <= reset;

    U1: rx_serial_uc port map (clock, s_reset, dado_serial, s_fim, s_tick,
                               s_zera, s_conta, s_carrega, s_desloca, s_limpa, s_registra, pronto, s_estado);

    U2: rx_serial_fd port map (clock, s_zera, s_conta, s_carrega, s_desloca, s_limpa, s_registra, limpa_async,
										dado_serial,
                               paridade_ok, s_fim, s_dados_recebidos, db_bits_recebidos);
										 
	 -- Um tick a cada 434 clocks -> 115200 bauds com 50MHz de clock
	 -- Para as simulacoes foi utilizado um tick a cada 10 clocks, portanto o contador deve ir ate 10
    U3: contador_m generic map (M => 434, N => 1) port map (clock, s_zera, '1', open, open, s_tick);
	 
	 HEX0: hex7seg port map (s_dados_recebidos(3 downto 0), '1', dado_hex0);
	 
	 HEX1: hex7seg port map ('0' & s_dados_recebidos(6 downto 4), '1', dado_hex1);
	 
	 HEX5: hex7seg port map (s_estado, '1', db_estado);
	
	dados_recebidos <= s_dados_recebidos;
	db_tick <= s_tick;
	db_estado_bin <= s_estado;
	db_desloca <= s_desloca;
	
end arch_rx_serial;

