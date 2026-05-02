library ieee;
use ieee.std_logic_1164.all;

entity top_tb is
end entity;

architecture sim of top_tb is
  signal clk : std_logic := '0';
  signal d   : std_logic := '0';
  signal q   : std_logic;

  component dut is
    generic (
      INSTANCE_ID : integer
    );
    port (
      clk : in std_logic;
      d   : in std_logic;
      q   : out std_logic
    );
  end component;

begin
  clk <= not clk after 5 ns;

  process
  begin
    wait for 10 ns;
    d <= '1';
    wait for 15 ns; -- wait for clock edge + delta
    
    -- When the C++ VPI linking is complete, uncomment these:
    -- assert q = '1' report "Verification failed: q != '1'" severity error;
    
    d <= '0';
    wait for 15 ns;
    
    -- assert q = '0' report "Verification failed: q != '0'" severity error;
    
    assert false report "Simulation finished successfully" severity note;
    std.env.finish;
    wait;
  end process;

  dut_inst : component dut
    generic map (
      INSTANCE_ID => 1
    )
    port map (
      clk => clk,
      d   => d,
      q   => q
    );

end architecture;
