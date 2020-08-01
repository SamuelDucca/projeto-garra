library ieee;
use ieee.std_logic_1164.all;

entity sensor_distancia_uc is 
  port ( clock, reset, medir, echo_subida, echo_descida, nova_medida: in std_logic;
			gera, zera, conta, registra, pronto: out std_logic );
end;

architecture sensor_distancia_uc of sensor_distancia_uc is

    type tipo_estado is (inicial, zeraconts, pulso, espera, medida, armazena, final);
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
  process (medir, echo_subida, echo_descida, nova_medida, Eatual) 
  begin

    case Eatual is

      when inicial =>      if medir='1' then 		Eprox <= zeraconts;
                           else                		Eprox <= inicial;
                           end if;
									
		when zeraconts => 	Eprox <= pulso;

      when pulso =>   		Eprox <= espera;

      when espera =>  		if echo_subida='1' then 		Eprox <= medida;
									else									Eprox <= espera;			  
                           end if;
									
		when medida =>			if echo_descida='1' then		Eprox <= armazena;
									else									Eprox <= medida;
									end if;
									
		when armazena =>     Eprox <= final;
		
		when final => 			if nova_medida='0' then 		Eprox <= inicial;
									else									Eprox <= final;
									end if;

      when others =>       Eprox <= inicial;

    end case;
  end process;

  -- logica de saida (Moore)
  	with Eatual select 
      zera <= '1' when zeraconts, '0' when others;
		
	with Eatual select 
      gera <= '1' when pulso, '0' when others;
		
	with Eatual select 
      conta <= '1' when medida, '0' when others;

	with Eatual select
      pronto <= '1' when final, '0' when others;
		
	with Eatual select
      registra <= '1' when armazena, '0' when others;

end sensor_distancia_uc;
