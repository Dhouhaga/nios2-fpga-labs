library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity avalon_vga is
  port (
    -- Avalon-MM slave (horloge système 50 MHz)
    clk, reset_n, chipselect, write_n : in  std_logic;
    address   : in  std_logic_vector(2 downto 0);   -- 8 registres
    writedata : in  std_logic_vector(31 downto 0);
    readdata  : out std_logic_vector(31 downto 0);
    -- Conduit VGA (vers les broches DE1)
    vga_hs, vga_vs : out std_logic;
    vga_r, vga_g, vga_b : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of avalon_vga is

  -- Constantes VGA 640x480 @ 60 Hz (identiques à syncrox)
  constant NPA : integer := 639;
  constant DSH : integer := 656;
  constant FSH : integer := 751;
  constant NPT : integer := 799;
  constant NLA : integer := 479;
  constant DSV : integer := 490;
  constant FSV : integer := 491;
  constant NLT : integer := 524;

  -- 8 bandes de couleur, 12 bits RGB(4-4-4)
  type color_array_t is array (0 to 7) of std_logic_vector(11 downto 0);
  signal colors      : color_array_t;
  signal colors_sync : color_array_t;

  -- Horloge pixel = clk / 2 (~25 MHz)
  signal div_q   : std_logic := '0';
  signal clk_pix : std_logic;

  -- Compteurs VGA
  signal h_comp, v_comp : std_logic_vector(9 downto 0);
  signal hor_sync_int, vert_sync_int : std_logic;
  signal video_on_h, video_on_v, video_on : std_logic;
  signal color_sel : std_logic_vector(11 downto 0);

begin

  -- Divide-by-2 : 50 MHz -> 25 MHz
  process(clk, reset_n)
  begin
    if reset_n = '0' then
      div_q <= '0';
    elsif rising_edge(clk) then
      div_q <= not div_q;
    end if;
  end process;
  clk_pix <= div_q;

  -- Écriture Avalon-MM des couleurs
  process(clk, reset_n)
  begin
    if reset_n = '0' then
      colors <= (x"000", x"00F", x"0F0", x"0FF",
                 x"F00", x"F0F", x"FF0", x"000");
    elsif rising_edge(clk) then
      if chipselect = '1' and write_n = '0' then
        colors(conv_integer(address)) <= writedata(11 downto 0);
      end if;
    end if;
  end process;

  -- Lecture Avalon-MM
  readdata <= X"00000" & colors(conv_integer(address));

  -- Synchronisation vers l'horloge pixel (clk/2 synchrone, 1 FF suffit)
  process(clk_pix, reset_n)
  begin
    if reset_n = '0' then
      for i in 0 to 7 loop
        colors_sync(i) <= (others => '0');
      end loop;
    elsif rising_edge(clk_pix) then
      colors_sync <= colors;
    end if;
  end process;

  -- Compteurs horizontaux / verticaux
  process(clk_pix, reset_n)
  begin
    if reset_n = '0' then
      h_comp <= (others => '0');
      v_comp <= (others => '0');
    elsif rising_edge(clk_pix) then
      if h_comp = NPT then
        h_comp <= (others => '0');
        if v_comp = NLT then
          v_comp <= (others => '0');
        else
          v_comp <= v_comp + 1;
        end if;
      else
        h_comp <= h_comp + 1;
      end if;
    end if;
  end process;

  -- Synchros actives à l'état bas
  hor_sync_int  <= '0' when (h_comp >= DSH and h_comp <= FSH) else '1';
  vert_sync_int <= '0' when (v_comp >= DSV and v_comp <= FSV) else '1';

  video_on_h <= '1' when h_comp <= NPA else '0';
  video_on_v <= '1' when v_comp <= NLA else '0';
  video_on   <= video_on_h and video_on_v;

  -- Sélection de la bande (8 x 80 pixels) — remplace mire0
  color_sel <= colors_sync(0) when h_comp <  80 else
               colors_sync(1) when h_comp < 160 else
               colors_sync(2) when h_comp < 240 else
               colors_sync(3) when h_comp < 320 else
               colors_sync(4) when h_comp < 400 else
               colors_sync(5) when h_comp < 480 else
               colors_sync(6) when h_comp < 560 else
               colors_sync(7);

  -- Sorties VGA (gatées par la zone visible)
  vga_hs <= hor_sync_int;
  vga_vs <= vert_sync_int;
  vga_r  <= color_sel(11 downto  8) when video_on = '1' else (others => '0');
  vga_g  <= color_sel( 7 downto  4) when video_on = '1' else (others => '0');
  vga_b  <= color_sel( 3 downto  0) when video_on = '1' else (others => '0');

end architecture;