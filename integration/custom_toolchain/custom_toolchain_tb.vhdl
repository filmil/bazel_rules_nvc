-- SPDX-License-Identifier: Apache-2.0
--
-- A test that passes under any NVC: it is here to be run by the toolchain
-- defined beside it.
entity custom_toolchain_tb is
end entity;

architecture sim of custom_toolchain_tb is
begin
    process
    begin
        report "ran under the custom toolchain";
        wait;
    end process;
end architecture;
