-- contador_m.vhd
--
-- contador modulo m
-- 
-- inclui saidas fim (fim de contagem) e
--               meio (metade da contagem)

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_m is
    generic (
        constant M: integer := 50; -- modulo do contador
        constant N: integer := 6   -- numero de bits da saida
    );
   port (
        clock, zera, conta: in STD_LOGIC;
        Q: out std_logic_vector (N-1 downto 0);
        fim, meio: out STD_LOGIC 
   );
end contador_m;

architecture contador_m_arch of contador_m is
  signal IQ: integer range 0 to M-1;
begin
  
  process (clock,zera,conta,IQ)
  begin
    if zera='1' then IQ <= 0;   
    elsif clock'event and clock='1' then
      if conta='1' then 
        if IQ=M-1 then IQ <= 0; 
        else IQ <= IQ + 1; 
        end if;
      end if;
    end if;
    
    if IQ=M-1 then fim <= '1'; 
    else fim <= '0'; 
    end if;

    if IQ=M/2-1 then meio <= '1'; 
    else meio <= '0'; 
    end if;

    Q <= std_logic_vector(to_unsigned(IQ, Q'length));

  end process;
end contador_m_arch;
