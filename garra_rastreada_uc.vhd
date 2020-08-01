-- rastreador_uc.vhdl
--
library ieee;
use ieee.std_logic_1164.all;

entity garra_rastreada_uc is 
	  port ( clock, reset, liga, fecha, abre, tick_abre, pronto_tx: in std_logic;
				cmd_rx: in std_logic_vector (1 downto 0); -- 00 fecha, 01 abre
				comando_garra: out std_logic_vector (1 downto 0); -- 00 igual, 01 esq, 10 dir
				rastreia, conta_tick, zera, limpa_async, partida: out std_logic;
				tx_ascii: out std_logic_vector(6 downto 0); -- 1100001 = "a"; 1100110 = "f";
				db_estado: out std_logic_vector(3 downto 0)
				);
end garra_rastreada_uc;

architecture garra_rastreada_uc_arch of garra_rastreada_uc is

    type tipo_estado is (inicial, prepara, checaliga, rastreador, fecha_garra, espera_aberto, limpa_rx,
								tx_fecha, tx_abre);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin 

  -- memoria de estado
  process (reset, clock)
  begin
      if reset = '1' then
          Eatual <= inicial;
      elsif clock'event and clock = '1' then
          Eatual <= Eprox; 
      end if;
  end process;

  -- logica de proximo estado
  process (liga, fecha, abre, tick_abre, cmd_rx, Eatual) 
  begin

    case Eatual is

      when inicial =>      if liga='1' then 					Eprox <= prepara;
                           else                				Eprox <= inicial;
                           end if;
		
		when prepara => 		Eprox <= checaliga;
		
		when checaliga =>    if liga='1' then 					Eprox <= rastreador;
                           else                				Eprox <= checaliga;
                           end if;
									
		when rastreador =>   if fecha='1' or cmd_rx="00" then 	Eprox <= tx_fecha;
									else											Eprox <= rastreador;
                           end if;
									
		when tx_fecha	=>		if pronto_tx='1' then 			Eprox <= fecha_garra;
									else									Eprox <= tx_fecha;
									end if;
		
		when fecha_garra =>  if abre='1' or cmd_rx="01" then 		Eprox <= tx_abre;
                           else                						Eprox <= fecha_garra;
                           end if;
									
		when tx_abre	=>		if pronto_tx='1' then 			Eprox <= espera_aberto;
									else									Eprox <= tx_abre;
									end if;
									
      when espera_aberto => 	if tick_abre='1' then 		Eprox <= limpa_rx;
										elsif cmd_rx="00" then		Eprox <= fecha_garra;
											else                		Eprox <= espera_aberto;
										end if;
										
		when limpa_rx =>		Eprox <= checaliga;
											
      when others =>       Eprox <= inicial;

    end case;
  end process;

  -- logica de saida (Moore)

  	with Eatual select 
      zera <= '1' when prepara, '0' when others;
		
	with Eatual select 
      conta_tick <= '1' when espera_aberto, '0' when others;
		
	with Eatual select 
      rastreia <= '1' when rastreador | espera_aberto, '0' when others;
		
	with Eatual select 
      comando_garra <= "01" when fecha_garra, "11" when others;

	with Eatual select 
      limpa_async <= '1' when limpa_rx, '0' when others;
		
	with Eatual select 
      partida <= '1' when tx_abre | tx_fecha, '0' when others;
		
	with Eatual select 
      tx_ascii <= "1100001" when tx_abre, "1100110" when tx_fecha, "1111010" when others;
		
	with Eatual select
		db_estado <= "0000" when inicial,
						 "0001" when prepara,
						 "0010" when checaliga,
						 "0011" when rastreador,
						 "0100" when fecha_garra,
						 "0101" when espera_aberto,
						 "0110" when limpa_rx,
						 "1010" when tx_fecha,
						 "1011" when tx_abre,
						 "1111" when others;

end garra_rastreada_uc_arch;
