-- comparador_dist.vhd
--
-- https://www.nandland.com/vhdl/examples/example-signed-unsigned.html

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

 
entity comparador_dist is
  port (
      dist_d0, dist_d1, dist_d2, dist_d3 : 		in std_logic_vector(3 downto 0); -- distancias direita, dist3 digito mais significativo
		dist_e0, dist_e1, dist_e2, dist_e3 : 		in std_logic_vector(3 downto 0); -- distancias esquerda, dist3 digito mais significativo
		dig3, dig2, dig1, dig0:      					in std_logic_vector(3 downto 0); -- distancia para determinar alcance
      direcao : out std_logic_vector (1 downto 0); -- 00 igual, 01 esq, 10 dir
		fechar: out std_logic
   );
end comparador_dist;

architecture comportamental of comparador_dist is

signal s_dist_e, s_dist_d, s_alcance, s_dist_fecha, s_zero: std_logic_vector(15 downto 0);
signal s_tolerancia : unsigned(15 downto 0) := (others => '0');
signal s_dist_unsig: unsigned(15 downto 0) := (others => '0'); -- para subtrair as distâncias

begin

	s_dist_d <= dist_d3 & dist_d2 & dist_d1 & dist_d0;
	s_dist_e <= dist_e3 & dist_e2 & dist_e1 & dist_e0;
	s_alcance <= dig3 & dig2 & dig1 & dig0;
	s_tolerancia <= "0000000000100000"; -- 0 0 2 0, equivale a 2cm, talvez utilizar 10cm
	
	s_dist_fecha <= "0000000010000000"; -- 0 0 7 0, equivale a 7cm
	s_zero <= "0000000000000101"; -- 0 0 0 5, medida pequena, desconsiderar
	process(s_dist_d, s_dist_e, s_alcance, s_tolerancia) 
		begin 
			-- Sinal de fechar a garra
			if ((s_dist_e <= s_dist_fecha or s_dist_d <= s_dist_fecha) and (s_dist_e > s_zero and s_dist_d > s_zero)) then
				fechar <= '1';
			else fechar <='0';
			end if;
			
			-- distâncias dentro do alcance, dist esq > dist dir e maior que tolerância
			if ((s_dist_e <= s_alcance or s_dist_d <= s_alcance) and (s_dist_e > s_zero and s_dist_d > s_zero)) then
				if (s_dist_d < s_dist_e) then
					s_dist_unsig <= unsigned(s_dist_e) - unsigned(s_dist_d);
					if (s_dist_unsig > s_tolerancia) then
						direcao <= "10";
					else 
						direcao <= "00";
					end if;
			-- distâncias dentro do alcance, dist esq < dist dir e maior que tolerância
				elsif (s_dist_e < s_dist_d) then
					s_dist_unsig <= unsigned(s_dist_d) - unsigned(s_dist_e);
					if (s_dist_unsig > s_tolerancia) then
						direcao <= "01";
					else 
						direcao <= "00";
					end if;
				end if;
			else direcao <= "00";
		  end if;
		end process;									
	
end comportamental;