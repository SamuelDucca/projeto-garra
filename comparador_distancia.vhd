-- comparador de distância
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
 
entity comparador_distancia is
  port (
      dist0_e, dist1_e, dist2_e, dist3_e : in std_logic_vector(3 downto 0); -- distancias medidas esq, dist3 digito mais significativo 
		dist0_d, dist1_d, dist2_d, dist3_d : in std_logic_vector(3 downto 0); -- distancias medidas dir, dist3 digito mais significativo
		dig3, dig2, dig1, dig0:      in std_logic_vector(3 downto 0); -- distancia para fechar garra, só passar dig1 e dig2, o resto é 0
      menor, esq, dir: out std_logic
   );
end comparador_distancia;

architecture comportamental of comparador_distancia is
signal s_sensor_esq, s_sensor_dir, s_alcance: std_logic_vector(15 downto 0);

	begin
		s_sensor_esq <= dist0_e & dist1_e & dist2_e & dist3_e;
		s_sensor_dir <= dist0_d & dist1_d & dist2_d & dist3_d;

		s_alcance <= dig3 & dig2 & dig1 & dig0;
		menor <= '1' when (s_alcance >= s_sensor_esq) else '0';
		esq <= '1';
	
end comportamental;