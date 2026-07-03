-- Exercises the `analysis_opts` attribute of vhdl_library: a shared variable
-- of a non-protected type is an error under strict VHDL-2000-and-later rules,
-- but is accepted (with a warning) when analyzed with `nvc -a --relaxed`.
-- Code bases written for the permissive defaults of commercial simulators
-- (e.g. GRLIB) rely on this.

entity relaxed_top is
end entity relaxed_top;

architecture test of relaxed_top is
  shared variable counter : integer := 0;  -- requires --relaxed in VHDL >= 2000
begin
  process
  begin
    counter := counter + 1;
    report "counter is " & integer'image(counter);
    wait;
  end process;
end architecture test;
