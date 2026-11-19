library IEEE;
use IEEE.std_logic_1164.all;

entity PWM is
  port (
    clk, reset : in  std_logic;
    pwm        : out std_logic
  );
end entity PWM;

architecture rtl of PWM is
  component gen is
    port (
      clk_clk                         : in  std_logic := 'X';
      reset_reset_n                   : in  std_logic := 'X';
      avalon_pwm_0_conduit_end_export : out std_logic
    );
  end component gen;
begin

  u0 : component gen
    port map (
      clk_clk                         => clk,
      reset_reset_n                   => reset,
      avalon_pwm_0_conduit_end_export => pwm
    );

end architecture rtl;