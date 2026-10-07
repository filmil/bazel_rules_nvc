-- SPDX-License-Identifier: Apache-2.0
--
-- Allocates 24 MiB, more than nvc's default heap of 16 MiB. It passes
-- only when the test raises the heap with global_args = ["-H", "64m"].
entity big_heap_tb is
end entity;

architecture sim of big_heap_tb is
begin
    process
        type int_array is array (natural range <>) of integer;
        type int_array_ptr is access int_array;
        variable p : int_array_ptr;
    begin
        -- 3 Mi integers; nvc stores an integer in 8 bytes.
        p := new int_array(0 to 3 * 1024 * 1024 - 1);
        p(p'high) := 42;
        assert p(p'high) = 42 report "lost the value" severity failure;
        report "allocated " & integer'image(p'length) & " integers";
        deallocate(p);
        wait;
    end process;
end architecture;
