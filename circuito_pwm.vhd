-- circuito_pwm.vhd - descrição rtl
--
-- gera saída com modulacao pwm
--
-- parametros: CONTAGEM_MAXIMA e largura_pwm
--             (clock a 50MHz ou 20ns)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity circuito_pwm is
port (
      clock    : in  std_logic;
      reset    : in  std_logic;
      largura  : in  std_logic_vector(5 downto 0); 
      pwm      : out std_logic );
end circuito_pwm;

architecture rtl of circuito_pwm is

  constant CONTAGEM_MAXIMA : integer := 1000000;  -- frequencia da saida 50Hz 
                                               -- ou periodo de 20ms
  signal contagem     : integer range 0 to CONTAGEM_MAXIMA-1;
  signal largura_pwm  : integer range 0 to CONTAGEM_MAXIMA-1;
  signal s_largura    : integer range 0 to CONTAGEM_MAXIMA-1;
  
begin

  process(clock,reset,largura)
  begin
    -- inicia contagem e largura
    if(reset='1') then
      contagem    <= 0;
      pwm         <= '0';
      largura_pwm <= s_largura;
    elsif(rising_edge(clock)) then
        -- saida
        if(contagem < largura_pwm) then
          pwm  <= '1';
        else
          pwm  <= '0';
        end if;
        -- atualiza contagem e largura
        if(contagem=CONTAGEM_MAXIMA-1) then
          contagem   <= 0;
          largura_pwm <= s_largura;
        else
          contagem   <= contagem + 1;
        end if;
    end if;
  end process;

  process(largura)
  begin
    case largura is
    when "000000" =>    s_largura <=    40000;  -- pulso de  1 ms
    when "000001" =>    s_largura <=    41200;
		when "000010" =>    s_largura <=  42400;
		when "000011" =>    s_largura <=  43600;
		when "000100" =>    s_largura <=  44800;
		when "000101" =>    s_largura <=  46000;
		when "000110" =>    s_largura <=  47200;
		when "000111" =>    s_largura <=  48400;
		when "001000" =>    s_largura <=   49600;
		when "001001" =>    s_largura <=    50800;
		when "001010" =>    s_largura <=    52000;
		when "001011" =>    s_largura <=    53200;
		when "001100" =>    s_largura <=    54400;
		when "001101" =>    s_largura <=    55600;
		when "001110" =>    s_largura <=    56800;
		when "001111" =>    s_largura <=    58000; -- pulso de 1.5ms masomenos
		when "010000" =>    s_largura <=    59200;
		when "010001" =>    s_largura <=    60400;  
		when "010010" =>    s_largura <=    61600;  
		when "010011" =>    s_largura <=    62800;
		when "010100" =>    s_largura <=    64000;
		when "010101" =>    s_largura <=    65200;
		when "010110" =>    s_largura <=    66400;
		when "010111" =>    s_largura <=    67600;
		when "011000" =>    s_largura <=    68800;
		when "011001" =>    s_largura <=    70000;
		when "011010" =>    s_largura <=    71200;
		when "011011" =>    s_largura <=    72400;
		when "011100" =>    s_largura <=    73600;
		when "011101" =>    s_largura <=    74800;
		when "011110" =>    s_largura <=    76000;  -- pulso de 2 ms 
    when others	  =>    s_largura <=     0;  -- nulo   saida 0
    end case;
  end process;
  
end rtl;

