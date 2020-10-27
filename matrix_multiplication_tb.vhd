library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.env.finish;

entity matrix_multiplication_tb is
end;

architecture behave of matrix_multiplication_tb is

    signal r_readaddress:  std_logic_vector(7 downto 0) := (others => '0');
    signal r_writeaddress: std_logic_vector(7 downto 0) := (others => '0');
    signal r_writeData:    std_logic_vector(7 downto 0) := (others => '0');
    signal r_buffersel:    std_logic := '0';
    signal r_clk:          std_logic := '0';
    signal r_readEn:       std_logic := '0';
    signal r_writeEn:      std_logic := '0';
    signal r_reset:        std_logic := '0';

    signal w_readData:      std_logic_vector(15 downto 0) := (others => '0');
    signal w_debug : std_logic_vector(7 downto 0) := (others => '0');

begin

    UUT: entity work.matrix_multiplication
        port map (
            readaddress => r_readaddress,
            writeaddress => r_writeaddress,
            writeData => r_writeData,
            buffersel => r_buffersel,
            clk => r_clk,
            readEn => r_readEn,
            writeEn => r_writeEn,
            reset => r_reset,

            readData => w_readData,
            debug => w_debug
        );

    process is
    begin
        r_clk <= not r_clk;
        r_writeaddress <= X"00";
        r_readaddress <= X"00";
        r_readEn <= '1';
        r_writeEn <= '1';
        r_buffersel <= '0';
        r_writeData <= X"01";
        wait for 25ns;

        r_clk <= not r_clk;
        wait for 25ns;

        r_clk <= not r_clk;
        wait for 25ns;
        
        r_clk <= not r_clk;
        r_buffersel <= '1';
        r_writeData <= X"01";
        wait for 25ns;

        r_clk <= not r_clk;
        wait for 25ns;
        
        r_clk <= not r_clk;
        wait for 25ns;
        r_clk <= not r_clk;
        wait for 25ns;
        
        r_clk <= not r_clk;
        wait for 25ns;

        finish;
    end process;

end behave ; -- behave