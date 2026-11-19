library IEEE;
use IEEE.std_logic_1164.all;

entity VGA is
  port (
    clk, reset          : in  std_logic;
    vga_hs, vga_vs      : out std_logic;
    vga_r, vga_g, vga_b : out std_logic_vector(3 downto 0)
  );
end entity VGA;

architecture rtl of VGA is

  -- Déclaration du composant généré par Qsys (copié-collé depuis system_vga.vhd)
  component system_vga is
    port (
      clk_clk       : in  std_logic                    := '0'; --   clk.clk
      vga_r         : out std_logic_vector(3 downto 0);        --   vga.r
      vga_g         : out std_logic_vector(3 downto 0);        --      .g
      vga_b         : out std_logic_vector(3 downto 0);        --      .b
      vga_hs        : out std_logic;                           --      .hs
      vga_vs        : out std_logic;                           --      .vs
      reset_reset_n : in  std_logic                    := '0'  -- reset.reset_n
    );
  end component;

begin

  -- Instanciation du système Qsys
  u0 : component system_vga
    port map (
      clk_clk       => clk,
      reset_reset_n => reset,
      vga_r         => vga_r,
      vga_g         => vga_g,
      vga_b         => vga_b,
      vga_hs        => vga_hs,
      vga_vs        => vga_vs
    );

end architecture rtl;