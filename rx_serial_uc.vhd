-- rx_serial_uc.vhd
--

library ieee;
use ieee.std_logic_1164.all;

entity rx_serial_uc is 
  port ( clock, reset, dado_serial, fim, tick: in std_logic;
         zera, conta, carrega, desloca, limpa, registra, pronto: out std_logic;
			estado: out std_logic_vector (3 downto 0) );
end;

architecture rx_serial_uc of rx_serial_uc is

    type tipo_estado is (inicial, preparacao, espera, recepcao, armazena, final);
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
  process (dado_serial, tick, fim, Eatual) 
  begin

    case Eatual is

      when inicial =>      if dado_serial='0' then Eprox <= preparacao;
                           else                		Eprox <= inicial;
                           end if;
									estado <="0000";

      when preparacao =>   Eprox <= espera;
									estado <="0001";

      when espera =>  		if 		fim='0' and tick='0'  then Eprox <= espera;
                           elsif 	fim='0' and tick='1'  then Eprox <= recepcao;
									elsif		fim='1'				    then Eprox <= armazena;
									else											Eprox <= espera;			  
                           end if;
									estado <="0010";
									
		when recepcao =>		Eprox <= espera;
									estado <="0011";
		
		when armazena =>		Eprox <= final;
									estado <="0100";

      when final =>        Eprox <= inicial;
									estado <="0101";
									
      when others =>       Eprox <= inicial;
									estado <="0111";

    end case;
  end process;

  -- logica de saida (Moore)
  with Eatual select 
      carrega <= '1' when preparacao, '0' when others;
		
  with Eatual select 
		limpa <= '1' when preparacao, '0' when others;
		
  with Eatual select 
		zera <= '1' when preparacao, '0' when others;

  with Eatual select
      desloca <= '1' when recepcao, '0' when others;
		
  with Eatual select
      conta <= '1' when recepcao, '0' when others;

  with Eatual select
      registra <= '1' when armazena, '0' when others;

  with Eatual select
      pronto <= '1' when final, '0' when others;

end rx_serial_uc;
