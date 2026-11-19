library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity avalon_pwm is
  port (
    clk, chipselect, write_n, address, reset_n : in  std_logic;
    writedata : in  std_logic_vector(31 downto 0);
    readdata  : out std_logic_vector(31 downto 0);
    out_pwm   : out std_logic
  );
end entity;

architecture rtl of avalon_pwm is
  signal freq    : std_logic_vector(15 downto 0);
  signal duty    : std_logic_vector(15 downto 0);
  signal counter : std_logic_vector(15 downto 0);
  signal pwm_on  : std_logic;
begin

  -- Frequency division: free-running counter, reset to 0 when it reaches FREQ
  divide : process(clk, reset_n)
  begin
    if reset_n = '0' then
      counter <= (others => '0');
    elsif rising_edge(clk) then
      if counter >= freq then
        counter <= (others => '0');
      else
        counter <= counter + 1;
      end if;
    end if;
  end process divide;

  -- PWM generation: output high at counter 0, low once counter reaches DUTY
  compare : process(clk, reset_n)
  begin
    if reset_n = '0' then
      pwm_on <= '1';
    elsif rising_edge(clk) then
      if counter >= duty then
        pwm_on <= '0';
      elsif counter = 0 then
        pwm_on <= '1';
      end if;
    end if;
  end process compare;

  out_pwm <= pwm_on;

  -- Avalon-MM write: address 0 -> FREQ, address 1 -> DUTY
  registers : process(clk, reset_n)
  begin
    if reset_n = '0' then
      freq <= (others => '0');
      duty <= (others => '0');
    elsif rising_edge(clk) then
      if chipselect = '1' and write_n = '0' then
        if address = '0' then
          freq <= writedata(15 downto 0);
        else
          duty <= writedata(15 downto 0);
        end if;
      end if;
    end if;
  end process registers;

  -- Avalon-MM read: returns FREQ or DUTY, zero-extended to 32 bits
  readdata <= X"0000" & freq when address = '0' else X"0000" & duty;

end architecture rtl;