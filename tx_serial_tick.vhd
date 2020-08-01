-- tx_serial_tick.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tx_serial_tick is
    port (
        clock, reset, partida, paridade: in std_logic;
        dados_ascii: in std_logic_vector (6 downto 0);
        saida_serial, pronto, tx_andamento : out std_logic
    );
end tx_serial_tick;

architecture arch_tx_serial_tick of tx_serial_tick is
    signal s_reset, s_partida: std_logic;
    signal s_zera, s_conta, s_carrega, s_desloca, s_fim, s_tick: std_logic;
     
    component tx_serial_uc port ( 
            clock, reset, partida, fim, tick: in std_logic;
            zera, conta, carrega, desloca, pronto, tx_andamento: out std_logic );
    end component;

    component tx_serial_fd port (
        clock, reset: in std_logic;
        zera, conta, carrega, desloca, paridade: in std_logic;
        dados_ascii: in std_logic_vector (6 downto 0);
        saida_serial, fim : out std_logic);
    end component;
	 
	 component contador_m
    generic (
        constant M: integer;
        constant N: integer
    );
    port (
        clock, zera, conta: in STD_LOGIC;
        Q: out STD_LOGIC_VECTOR (N-1 downto 0);
        fim: out STD_LOGIC);
    end component;
      
begin


    -- sinais reset e partida mapeados em botoes (ativos em baixo)
    --s_reset <= not reset;
    --s_partida <= not partida;
    -- sinais reset e partida mapeados na GPIO (ativos em alto)
		s_reset <= reset;
		s_partida <= partida;

    U1: tx_serial_uc port map (clock, s_reset, s_partida, s_fim, s_tick,
                               s_zera, s_conta, s_carrega, s_desloca, pronto, tx_andamento);

    U2: tx_serial_fd port map (clock, s_reset, s_zera, s_conta, s_carrega, s_desloca, 
                               paridade, dados_ascii, saida_serial, s_fim);
										 
	 -- Um tick a cada 434 clocks -> 115200 bauds com 50MHz de clock
    U3: contador_m generic map (M => 434, N => 1) port map (clock, s_zera, '1', open, s_tick);


end arch_tx_serial_tick;

