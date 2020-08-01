-- tx_serial_fd.vhd
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_serial_fd is
    port (
        clock, reset: in std_logic;
        zera, conta, carrega, desloca, paridade: in std_logic;
        dados_ascii: in std_logic_vector (6 downto 0);
        saida_serial, fim : out std_logic
    );
end tx_serial_fd;

architecture tx_serial_fd_arch of tx_serial_fd is
    signal s_dado, s_saida: std_logic_vector (9 downto 0);
     
    component deslocador_n
    generic (
        constant N: integer 
    );
    port (
        clock, reset: in std_logic;
        carrega, desloca, entrada_serial: in std_logic; 
        dados: in  std_logic_vector (N-1 downto 0);
        saida: out std_logic_vector (N-1 downto 0));
    end component;

    component contador_m
    generic (
        constant M: integer;
        constant N: integer
    );
    port (
        clock, zera, conta: in STD_LOGIC;
        Q: out STD_LOGIC_VECTOR (N-1 downto 0);
        fim: out STD_LOGIC);
    end component;
    
begin

    s_dado(0) <= '1';  -- repouso
    s_dado(1) <= '0';  -- start bit
    s_dado(8 downto 2) <= dados_ascii;
    -- paridade: 0=par, 1=impar
    s_dado(9) <= paridade xor dados_ascii(0) xor dados_ascii(1) xor dados_ascii(2) xor dados_ascii(3) 
                 xor dados_ascii(4) xor dados_ascii(5) xor dados_ascii(6);

    U1: deslocador_n generic map (N => 10)  port map (clock, reset, carrega, desloca, '1', s_dado, s_saida);

    U2: contador_m generic map (M => 12, N => 4) port map (clock, zera, conta, open, fim);

    saida_serial <= s_saida(0);
    
end tx_serial_fd_arch;
