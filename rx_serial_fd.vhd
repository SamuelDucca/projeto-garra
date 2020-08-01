-- rx_serial_fd.vhd
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_serial_fd is
    port (
        clock, zera, conta, carrega, desloca, limpa, registra, limpa_async: in std_logic;
        dado_serial: in std_logic;
        paridade_ok, fim : out std_logic;
		  dado_recebido: out std_logic_vector (6 downto 0);
		  db_bits_recebidos: out std_logic_vector (10 downto 0)
    );
end rx_serial_fd;

architecture rx_serial_fd_arch of rx_serial_fd is
    signal s_dado: std_logic_vector (10 downto 0);
	 signal s_entrada_reg, s_saida: std_logic_vector (7 downto 0);
	 signal s_par_ok: std_logic;	 
     
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
	 
	 component testador_paridade is
    port (
        dado:      in std_logic_vector (6 downto 0);
        paridade:  in std_logic;
        par_ok:    out std_logic;
        impar_ok:  out std_logic
    );
	end component;

    component contador_m
    generic (
        constant M: integer;
        constant N: integer
    );
    port (
        clock, zera, conta: in STD_LOGIC;
        Q: out std_logic_vector (N-1 downto 0);
        fim, meio: out STD_LOGIC);
    end component;
	 
  component registrador_n is
  generic (
       constant N: integer := 8 );
  port (clock, clear, enable: in std_logic;
        D: in std_logic_vector(N-1 downto 0);
        Q: out std_logic_vector (N-1 downto 0) );
  end component;
    
begin

    --s_dado(0) <= '1';  -- repouso
    --s_dado(1) <= '0';  -- start bit
    --s_dado(8 downto 2) <= dados_ascii;
    -- paridade: 0=par, 1=impar
    --s_dado(9) <= paridade xor dados_ascii(0) xor dados_ascii(1) xor dados_ascii(2) xor dados_ascii(3) 
                 --xor dados_ascii(4) xor dados_ascii(5) xor dados_ascii(6);
					  
	 s_entrada_reg <= s_par_ok & s_dado(7 downto 1);
	
    U1: deslocador_n generic map (N => 11)  port map (clock, '0', carrega, desloca, dado_serial, (others => '1'), s_dado);
		
	 U2: registrador_n port map (clock, (limpa or limpa_async), registra, s_entrada_reg, s_saida);
	 
	 U3: testador_paridade port map ( s_dado(7 downto 1), s_dado(8),  s_par_ok, open);
	 
    U4: contador_m generic map (M => 12, N => 4) port map (clock, zera, conta, open, fim, open);
	
	dado_recebido <= s_saida(6 downto 0);
	paridade_ok <= s_saida(7);
	db_bits_recebidos <= s_dado;
    
end rx_serial_fd_arch;
