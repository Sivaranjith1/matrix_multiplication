library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity matrix_multiplication is
    generic(
        n_rows: integer := 4;
        n_columns: integer := 4
    );
    port(
        readaddress:    in std_logic_vector(7 downto 0) := (others => '0');
        writeaddress:   in std_logic_vector(7 downto 0) := (others => '0');
        writeData:      in std_logic_vector(7 downto 0) := (others => '0');
        buffersel:      in std_logic := '0';
        clk:            in std_logic;
        readEn:         in std_logic;
        writeEn:        in std_logic;
        reset:          in std_logic := '0';

        readData:       out std_logic_vector(15 downto 0) := (others => '0');
        debug: out std_logic_vector(7 downto 0) := (others => '0')
    );
end;

architecture matmul_arch of matrix_multiplication is
    type input_matrix is array (0 to n_rows*n_columns - 1) of std_logic_vector(7 downto 0);
    type output_matrix is array (0 to n_rows*n_columns - 1) of std_logic_vector(15 downto 0);
    signal matrix_A: input_matrix := (others => (others => '0')); --input matrix 1
    signal matrix_B: input_matrix := (others => (others => '0')); --input matrix 2

    signal matrix_C: output_matrix := (others => (others => '0')); --output matrix

    --state
    type state_type is (state_idle, state_changeA, state_changeB, state_finished);
    signal state: state_type;
    signal last_write_address: std_logic_vector(7 downto 0) := (others => '0');

begin

    -- Reset
    process(clk, reset) is
    begin
        if(rising_edge(clk) and reset='1') then
            matrix_A <= (others => (others => '0'));
            matrix_B <= (others => (others => '0'));
            matrix_C <= (others => (others => '0'));
        end if;
    end process;

    process(clk) is
        begin
        if(rising_edge(clk) and writeEn='1') then
            if(buffersel='0') then
                --write to matrix_A
                report("Writing to matrix A");
                matrix_A(to_integer(unsigned(writeaddress))) <= writeData;
                last_write_address <= writeaddress;
                state <= state_changeA;
            else
                --write to matrix_B
                report("Writing to matrix B");
                matrix_B(to_integer(unsigned(writeaddress))) <= writeData;
                last_write_address <= writeaddress;
                state <= state_changeB;
            end if;
        end if;
    end process;

    --read matrix_C
    process(clk) is
    begin
        if(rising_edge(clk) and readEn='1') then
            readData <= matrix_C(to_integer(unsigned(readaddress)));
        end if;
    end process;

    process(clk, state) is
    begin
        if(rising_edge(clk)) then
            debug <= matrix_A(to_integer(unsigned(last_write_address)));
            case state is
                when state_changeA =>
                    report("State change A");
                    matrix_C(to_integer(unsigned(last_write_address))) <= std_logic_vector(
                        signed(
                            matrix_A(to_integer(unsigned(last_write_address)))
                            ) * signed (
                                matrix_B(to_integer(unsigned(last_write_address)))
                            )
                        );
                when state_changeB =>
                    report("State change B");
                    matrix_C(to_integer(unsigned(last_write_address))) <= std_logic_vector(
                        signed(
                            matrix_A(to_integer(unsigned(last_write_address)))
                            ) * signed (
                            matrix_B(to_integer(unsigned(last_write_address)))
                            )
                        );
                when others => null;
            end case;
        end if;
    end process;
end matmul_arch ; -- matmul_arch