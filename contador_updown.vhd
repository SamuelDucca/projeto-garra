-- contador_updown.vhd
--
-- contador modulo m com controle de sentido (up=0/down=1)
-- com saidas fim (fim de contagem) e
-- meio (metade da contagem)
-- numero de bits em funcao do modulo do contador M
--  N=natural(ceil(log2(real(M))))
--
-- LabDig - 30/09/2019 - v1.1

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity contador_updown is
    generic (
        constant M: integer := 16 -- modulo do contador
    );
   port (
        clock, zera, conta, sentido: in std_logic;
        Q: out std_logic_vector (5 downto 0); -- era std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0)
        fim, meio: out std_logic 
   );
end contador_updown;

architecture contador_updown_arch of contador_updown is
  signal IQ: integer range 0 to M-1;
begin
  
  process (clock,zera,IQ)
  begin
    if zera='1' then IQ <= 0;   
    elsif clock'event and clock='1' then
      if conta='1' then 
        if sentido='0' then  -- up
          if IQ=M-1 then 
            IQ <= M-1; --mantem m-1
          else  
            IQ <= IQ + 1;  
          end if;
        else                 -- down
          if IQ=0 then IQ <= 0; --mantem 0
          else IQ <= IQ - 1;  
          end if;
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
end contador_updown_arch;
