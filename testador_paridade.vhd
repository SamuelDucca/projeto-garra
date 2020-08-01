-- testador_paridade.vhd
--
--     saidas par_ok e impar_ok calculados 
-- para uso em comunicacao serial RS232C
--
-- par_ok=1 tx com paridade par sem erro 
-- par_ok=0 erro na tx para paridade par

library IEEE;
use IEEE.std_logic_1164.all;

entity testador_paridade is
    port (
        dado:      in std_logic_vector (6 downto 0);
        paridade:  in std_logic;
        par_ok:    out std_logic;
        impar_ok:  out std_logic
    );
end testador_paridade;

architecture rtl of testador_paridade is
begin
process (dado,paridade)
  variable p : STD_LOGIC;
  begin
    p := dado(0);
    for j in 1 to 6 loop
      p := p xor dado(j);
    end loop;
    p := p xor paridade;
    -- saidas
    par_ok   <= not p;
    impar_ok <= p;  
  end process;
end rtl;
