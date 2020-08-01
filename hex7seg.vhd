-- hex7seg.vhd
--     decodificador hexadecimal para display de 7 segmentos
--     com entrada de enable

library ieee;
use ieee.std_logic_1164.all;

entity hex7seg is
    port (
        binario : in std_logic_vector(3 downto 0);
        enable  : in std_logic;
        display : out std_logic_vector(6 downto 0)
    );
end hex7seg;

architecture comportamental of hex7seg is
begin
    process (enable, binario)
    begin
        if enable = '0' then
            display <= "1111111";  --  7F
        else
            case binario is
                when "0000" => display <= "1000000"; -- 0 40 
                when "0001" => display <= "1111001"; -- 1 79
                when "0010" => display <= "0100100"; -- 2 24
                when "0011" => display <= "0110000"; -- 3 30
                when "0100" => display <= "0011001"; -- 4 19
                when "0101" => display <= "0010010"; -- 5 12
                when "0110" => display <= "0000010"; -- 6 02
                when "0111" => display <= "1011000"; -- 7 58
                when "1000" => display <= "0000000"; -- 8 00
                when "1001" => display <= "0010000"; -- 9 10
                when "1010" => display <= "0001000"; -- A 08
                when "1011" => display <= "0000011"; -- B 03
                when "1100" => display <= "1000110"; -- C 46
                when "1101" => display <= "0100001"; -- D 21
                when "1110" => display <= "0000110"; -- E 06
                when others => display <= "0001110"; -- F 0E
            end case;
        end if;
    end process;
end comportamental;
