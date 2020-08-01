-- registrador_n.vhd
--    registrador com numero de bits como generic

library IEEE;
use IEEE.std_logic_1164.all;

entity registrador_n is
  generic (
       constant N: integer := 8 );
  port (clock, clear, enable: in std_logic;
        D: in std_logic_vector(N-1 downto 0);
        Q: out std_logic_vector (N-1 downto 0) );
end registrador_n;

architecture registrador_n of registrador_n is
  signal IQ: std_logic_vector(N-1 downto 0);
begin

process(clock, clear, enable, IQ)
  begin
    if (clear = '1') then IQ <= (others => '0');
    elsif (clock'event and clock='1') then
      if (enable='1') then IQ <= D; end if;
    end if;
    Q <= IQ;
  end process;
  
end registrador_n;


