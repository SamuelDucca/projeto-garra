-- circuito detector de borda
--
-- gera pulso com 1 periodo do clock
--
-- baseado em codigo disponivel em 
-- https://surf-vhdl.com/how-to-design-a-good-edge-detector/

library ieee;
use ieee.std_logic_1164.all;

entity detector_borda is
port (
    clock, reset  : in  std_logic;
    entrada       : in  std_logic;
    pulso_subida  : out std_logic;
    pulso_descida : out std_logic );
end detector_borda;

architecture rtl of detector_borda is
    signal reg0, reg1 : std_logic;
begin

  detector_borda_subida : process(clock,reset)
  begin
    if(reset='1') then
        reg0 <= '0';
        reg1 <= '0';
    elsif(rising_edge(clock)) then
        reg0 <= entrada;
        reg1 <= reg0;
    end if;
  end process detector_borda_subida;

  pulso_subida  <= not reg1 and reg0;  -- detecta borda de subida
  pulso_descida <= reg1 and not reg0;  -- detecta borda de descida

end rtl;