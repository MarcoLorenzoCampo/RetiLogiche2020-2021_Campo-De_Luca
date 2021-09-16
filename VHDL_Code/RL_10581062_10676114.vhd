----------------------------------------------------------------------------------
--
-- Prova Finale Progetto di Reti Logiche
-- Prof. Federico Terraneo
-- Prof. William Fornaciari
--
-- Marco Lorenzo Campo (Codice Persona 10581062 Matricola 886807)
-- Alessandro De Luca (Codice Persona 10676114 Matricola 908706)
-- 
----------------------------------------------------------------------------------
library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
entity project_reti_logiche is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_en : out std_logic;
        o_we : out std_logic;
        o_data : out std_logic_vector (7 downto 0)
        );
end project_reti_logiche;
architecture Behavioral of project_reti_logiche is 
    type State is (IDLE, START, GET_COL, GET_ROW, GET_DIM, SET_DIM, GET_DELTA, START_EQ, EQ_PIXEL, WRITE_EQ, DONE);
    --registri di stato
    signal cur_state, next_state : State; 
    --segnali di enable per i registri
    signal max_load, min_load : std_logic;
    signal row_load, column_load, count_load, base_address_load : std_logic;
    signal read_load, write_load : std_logic;
    --segnali di scelta per i multiplexer
    signal select_read_write, mux_write, mux_base, mux_count : std_logic;
    signal mux_read : std_logic_vector (1 downto 0);
    --registri per gli indirizzi, valori di massimo e minimo e valori di riga e colonna
    signal max_out, min_out, column_out, row_out, new_pixel_value, count_out, count_in, choice_count : std_logic_vector(7 downto 0);
    signal read_out, write_out,next_read_out, next_write_out, end_write_out, base_address_in, base_address_out, choice_base : std_logic_vector (15 downto 0);
    --segnali per i valori dei pixel equalizzati o necessari al calcolo di essi
    signal delta_value, temp_value, temp_pixel : std_logic_vector (15 downto 0);
    signal shift_level : integer;
    
        
begin
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= IDLE;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;
    
    --funzione di transizione delta 
    process (cur_state, i_start, write_out, read_out, row_out, column_out, end_write_out, count_in)
    begin
        next_state <= cur_state;
        case cur_state is 
            when IDLE =>
                if i_start = '1' then
                    next_state <= START;
                else
                    next_state <= IDLE;
                end if;
            
            when START =>
                next_state <= GET_COL;
            
            when GET_COL =>
                    next_state <= GET_ROW;
            
            when GET_ROW => 
                next_state <= GET_DIM;
            
            when GET_DIM =>
                if (row_out = "00000000") OR (column_out = "00000000") then
                    next_state <= DONE;
                elsif ((row_out = "00000001") OR (column_out = "00000001")) then
                    next_state <= GET_DELTA;
                else
                    next_state <= SET_DIM;    
                end if;
            
            when SET_DIM =>
                 if count_in = "00000001" then
                    next_state <= GET_DELTA;
                 else
                    next_state <= SET_DIM;
                 end if;
                    
                    
            when GET_DELTA =>
                if ( write_out = read_out) then
                    next_state <= START_EQ;
                else
                    next_state <= GET_DELTA;
                end if; 
            
            when START_EQ =>
                next_state <= EQ_PIXEL ;
            
            when EQ_PIXEL => 
                    if write_out = end_write_out then
                    next_state <= DONE;
                else
                    next_state <= WRITE_EQ;
                end if; 
                                
            when WRITE_EQ =>
                    next_state <= EQ_PIXEL; 
            
            when DONE =>
                if (i_start = '0') then
                    next_state <= IDLE;
                else
                    next_state <= DONE;
                end if;
            
            end case;
            end process;

    --funzione di uscita lambda
    process(cur_state, write_out, end_write_out)
    begin
        max_load <= '0';
        min_load <= '0';
        row_load <= '0';
        column_load <= '0';
        mux_read <= "00";
        read_load <= '0';
        mux_base <= '0';
        base_address_load <= '0';
        mux_count <= '0';
        count_load <= '0';
        mux_write <= '0';
        write_load <= '0';
        select_read_write <='0';
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';
        case cur_state is
            
            when IDLE =>
                mux_read<="11";
                read_load <= '1';
            
            when START =>
                mux_read <= "01";
                o_en <= '1';
                read_load <= '1';
            
            when GET_COL =>
                o_en <='1';
                column_load <= '1';
                read_load <= '1';
                mux_read <= "01";
                
            
            when GET_ROW =>
                o_en <='1';
                row_load <= '1';
                write_load <= '1';
                read_load <= '1';
                mux_read <= "00";
            
            when GET_DIM =>
                base_address_load <= '1';
                count_load <= '1';
                write_load <= '1';
            
            when SET_DIM =>
                o_en <= '1';
                mux_base <= '1';
                mux_count <= '1';
                base_address_load <= '1';
                count_load <= '1';
                write_load <= '1';
            
            when GET_DELTA =>
                o_en <= '1';
                max_load <= '1';
                min_load <= '1';
                read_load <= '1';
                mux_read <= "01";
                write_load <= '1';
            
            when START_EQ =>
                o_en <= '1';
                mux_write <= '1';
                read_load <= '1';
                mux_read <= "10";
            
            when WRITE_EQ =>
                o_en <= '1';
                o_we <= '1';
                mux_read <= "01";
                mux_write <= '1';
                write_load <= '1';
                select_read_write <= '1';
            
            when EQ_PIXEL =>
                mux_read <= "01";
                mux_write <= '1';
                read_load <= '1';
                if write_out = end_write_out then 
                    o_en <= '1';
                else
                    o_en<='1';
                end if;
            
            when DONE =>
                o_done <= '1';
                read_load <= '1';
            
            end case;
            end process;
      
    
    with (column_out <= row_out) select 
           choice_base <= ("00000000" & row_out) when true ,
                          ("00000000" & column_out) when others;  
                          
    with (column_out <= row_out) select 
           choice_count <= column_out when true,
                          row_out when others;
    
    with mux_base select
        base_address_in <= choice_base when '0',
                          (base_address_out + choice_base) when others;             
            
    process (i_clk, i_rst)
    begin
        if ( i_rst = '1') then
            base_address_out <= "0000000000000000";
        elsif (i_clk'event and i_clk= '1') then
            if (base_address_load = '1') then
                base_address_out <= base_address_in;
            end if;
        end if;
    end process;          
            
    with mux_count select
        count_in <= choice_count when '0',
                    count_out - "00000001" when others;    
                         
    process (i_clk, i_rst)
    begin            
        if ( i_rst = '1') then
            count_out <= "00000000";
        elsif (i_clk'event and i_clk= '1') then
            if (count_load = '1') then
                count_out <= count_in;
            end if;
        end if;
    end process;    
            
    
    --multiplexer di lettura, definisce quale indirizzo salvare nel registro di lettura
    with mux_read select
        next_read_out <= read_out when "00",
                         (read_out + "0000000000000001") when "01",
                         "0000000000000010" when "10",
                         "0000000000000000" when others;    
    -- processo che gestisce il registro di lettura                     
    process (i_clk, i_rst)
        begin 
            if (i_rst = '1') then 
                read_out <= "0000000000000000";
            elsif i_clk'event and i_clk = '1' then
                if ( read_load = '1') then
                    read_out <= next_read_out;
                end if;
            end if;
    end process;
    
    --multiplexer di scrittura, definisce quale indirizzo salvare nel registro di scrittura
    with mux_write select 
        next_write_out <= ((base_address_out)+"10") when '0',
                          (write_out + "0000000000000001") when others;
    process (i_clk, i_rst)
        begin 
            if (i_rst = '1') then 
                write_out <= "0000000000000000";
            elsif i_clk'event and i_clk = '1' then
                if ( write_load = '1') then
                    write_out <= next_write_out;
                end if;
            end if;
    end process;
    
    --multiplexer di accesso alla memoria, definisce se l'indirizzo da mandare in memoria proviene dal registro di lettura o dal registro di scrittura 
    with select_read_write select
       o_address <= read_out when '0',
                    write_out when others;
    
    --segnale che mantiene il valore dell'indirizzo di fine scrittura 
    end_write_out <= std_logic_vector(shift_left(unsigned(base_address_out), 1))+"0000000000000010";
    
    --processo che gestisce il registro di riga
    process (i_clk, i_rst)
        begin 
            if (i_rst = '1') then 
                row_out <= "00000000";
            elsif i_clk'event and i_clk = '1' then
                if ( row_load = '1') then
                    row_out <= i_data;
                end if;
            end if;
    end process;
    
    --processo che gestisce il registro di colonna
    process (i_clk, i_rst)
        begin 
            if (i_rst = '1') then 
                column_out <= "00000000";
            elsif i_clk'event and i_clk = '1' then
                if ( column_load = '1') then
                    column_out <= i_data;
                end if;
            end if;
    end process;
    
    --processo che gestisce il registro di minimo
    process (i_clk, i_rst)
        begin 
            if (i_rst = '1') then 
                min_out <= "11111111";
            elsif i_clk'event and i_clk = '1' then
                if  ((min_load = '1' )AND (i_data < min_out OR read_out = "0000000000000010" )) then
                    min_out <= i_data;
                end if;
            end if;
    end process;
    
    --processo che gestisce il registro di massimo
    process (i_clk, i_rst)
        begin 
            if (i_rst = '1') then 
                max_out <= "00000000";
            elsif i_clk'event and i_clk = '1' then
                if ((max_load = '1') AND (max_out < i_data OR read_out = "0000000000000010")) then
                    max_out <= i_data;
                end if;
            end if;
    end process;
    
    --computazione del delta_value
    delta_value <= (("00000000" & max_out) - ("00000000"& min_out)+ "00000001");
    
    --encoder modificato che fornisce il valore dello shift_level in base al valore di delta_value (comprensivo del +1)
    shift_level <= 0 when delta_value(8) = '1' else
                   1 when delta_value(7) = '1' else
                   2 when delta_value(6) = '1' else
                   3 when delta_value(5) = '1' else
                   4 when delta_value(4) = '1' else
                   5 when delta_value(3) = '1' else
                   6 when delta_value(2) = '1' else
                   7 when delta_value(1) = '1' else
                   8 ; 
    --calcolo del valore temporaneo del pixel
    temp_value <= ("00000000" & i_data) - ("00000000" & min_out);   
    temp_pixel <= std_logic_vector(shift_left(unsigned(temp_value), shift_level));
    
    --multiplexer che definisce se il valore da assegnare al pixel equallizzato è il valore computato o se assegnare 255
    with (temp_pixel < "0000000011111111") select
         new_pixel_value <= temp_pixel (7 downto 0) when true,
                                                 "11111111" when false;
    
    o_data <= new_pixel_value;        

end Behavioral;
