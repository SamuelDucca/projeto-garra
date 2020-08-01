-- comparador_ascii.vhd
--     comparador binario que checa pelos digitos P ou C

library IEEE;
use IEEE.std_logic_1164.all;

entity comparador_ascii is
    port (
        A:		in std_logic_vector (6 downto 0);
        result: 	out std_logic_vector (1 downto 0)
    );
end comparador_ascii;

architecture comportamental of comparador_ascii is
begin

	process(A) 
		begin 
			
			if (A = "1000001") then -- Caractere 'A'
				result <= "01"; -- Abre Garra 
			elsif (A = "1000110") then -- Caractere 'F'
				result <= "00"; -- Fecha Garra
			else result <= "11"; -- Nenhum dos dois
			end if;
			
		end process;
		
end comportamental;
