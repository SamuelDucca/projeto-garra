-- rom_generic.vhd
-- 
-- usa parametros generic
--   posicoes: numero de posicoes/palavras de memoria
--   palavra: largura da palavra em bits
--   arq_mif: arquivo mif com conteudo da rom
--
-- LabDig - 20/09/2019 - v.1.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity rom_generic is
    generic ( posicoes: integer := 8;  
              palavra: integer := 21;  
              arq_mif: string := "rom_angulos.mif" 
    );
    port (endereco : in  std_logic_vector(natural(ceil(log2(real(posicoes))))-1 downto 0);
          saida    : out std_logic_vector(palavra-1 downto 0) ); 
end rom_generic;

architecture rom_arch of rom_generic is
  type arranjo_memoria is array (0 to palavra-1) of std_logic_vector(palavra-1 downto 0);
  signal dados : arranjo_memoria;
  attribute ram_init_file : string;
  attribute ram_init_file of dados : signal is arq_mif;  -- sintetizavel no Quartus Prime

begin

  saida <= dados(to_integer(unsigned(endereco)));

end rom_arch;
