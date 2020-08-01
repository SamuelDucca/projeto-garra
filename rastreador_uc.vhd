-- rastreador_uc.vhdl
--
library ieee;
use ieee.std_logic_1164.all;

entity rastreador_uc is 
  port ( clock, reset, liga, pronto_e, pronto_d, tick: in std_logic;
			direcao: in std_logic_vector (1 downto 0); -- 00 igual, 01 esq, 10 dir
			medir, reset_medir, conta_pos, conta_tick, zera, zera_pos, sentido: out std_logic;
			db_estado: out std_logic_vector(3 downto 0)
			);
end rastreador_uc;

architecture rastreador_uc of rastreador_uc is

    type tipo_estado is (inicial, prepara, checaliga, mede, espera_d, espera_e, compara, move_e, move_d, espera);
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
  process (liga, pronto_e, pronto_d, tick, Eatual) 
  begin

    case Eatual is

      when inicial =>      if liga='1' then 					Eprox <= prepara;
                           else                				Eprox <= inicial;
                           end if;
									
		when prepara => 		Eprox <= checaliga;
		
      when checaliga =>    if liga='1' then 					Eprox <= mede;
                           else                				Eprox <= checaliga;
                           end if;
									
		when mede => 			if pronto_e ='1' then				Eprox <= espera_d;
										else if pronto_d ='1' then		Eprox <= espera_e;
												else 							Eprox <= mede;
										end if;
									end if;
									
		when espera_d =>		if pronto_d ='1' then				Eprox <= compara;
		                     else                					Eprox <= espera_d;
									end if;
		
		when espera_e =>		if pronto_e ='1' then				Eprox <= compara;
		                     else                					Eprox <= espera_e;
									end if;
									
		when compara =>      if 	direcao = "01" then			Eprox <= move_e;
									elsif direcao = "10" then			Eprox <= move_d;
									else 										Eprox <= espera;
									end if;


      when move_e =>  		Eprox <= espera;
		
		when move_d =>  		Eprox <= espera;

									
		when espera =>			if tick='1' then					Eprox <= checaliga;
									else									Eprox <= espera;
									end if;
											
      when others =>       Eprox <= inicial;

    end case;
  end process;

  -- logica de saida (Moore)
  
   with Eatual select 
		zera_pos <= '1' when prepara, '0' when others;
		
	with Eatual select 
		zera <= '1' when prepara, '0' when others;
		
	with Eatual select 
		reset_medir <= '1' when prepara, '0' when others;
		
  	with Eatual select 
      medir <= '1' when mede, '0' when others;
		
	with Eatual select 
      conta_tick <= '1' when espera, '0' when others;
		
	with Eatual select 
      conta_pos <= '1' when move_e | move_d, '0' when others;
		
	with Eatual select 
      sentido <= '1' when move_d, '0' when others;
		
	with Eatual select
		db_estado <= "0000" when inicial,
						 "0001" when prepara,
						 "0010" when checaliga,
						 "0011" when mede,
						 "0100" when espera_d,
						 "0101" when espera_e,
						 "0110" when compara,
						 "0111" when move_e,
						 "1000" when move_d,
						 "1001" when espera,
						 "1111" when others;

end rastreador_uc;
