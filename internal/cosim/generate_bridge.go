package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"os"
	"regexp"
	"strings"
)

type VerilatorJSON struct {
	Type     string   `json:"type"`
	Name     string   `json:"name"`
	Modulesp []Module `json:"modulesp"`
	Miscsp   []Misc   `json:"miscsp"`
}

type Misc struct {
	Type   string  `json:"type"`
	Typesp []DType `json:"typesp"`
}

type DType struct {
	Type   string `json:"type"`
	Addr   string `json:"addr"`
	Name   string `json:"name"`
	Range  string `json:"range,omitempty"`
	Signed bool   `json:"signed,omitempty"`
}

type Module struct {
	Type     string `json:"type"`
	Name     string `json:"name"`
	OrigName string `json:"origName"`
	Stmtsp   []Stmt `json:"stmtsp"`
}

type Stmt struct {
	Type      string `json:"type"`
	Name      string `json:"name"`
	OrigName  string `json:"origName"`
	Direction string `json:"direction,omitempty"`
	DtypeName string `json:"dtypeName,omitempty"`
	Dtypep    string `json:"dtypep,omitempty"`
}

var boundsRegex = regexp.MustCompile(`\[(\d+):(\d+)\]`)

func main() {
	if len(os.Args) != 4 {
		log.Fatalf("Usage: %s <input.json> <out_proxy.vhdl> <out_bindings.hpp>", os.Args[0])
	}

	jsonPath := os.Args[1]
	vhdlPath := os.Args[2]
	hppPath := os.Args[3]

	jsonFile, err := os.Open(jsonPath)
	if err != nil {
		log.Fatalf("Error opening JSON: %v", err)
	}
	defer jsonFile.Close()

	jsonData, err := io.ReadAll(jsonFile)
	if err != nil {
		log.Fatalf("Error reading JSON: %v", err)
	}

	var vJSON VerilatorJSON
	if err := json.Unmarshal(jsonData, &vJSON); err != nil {
		log.Fatalf("Error unmarshalling JSON: %v", err)
	}

	if len(vJSON.Modulesp) == 0 {
		log.Fatal("No modules found in JSON")
	}

	// Build type map
	typeMap := make(map[string]DType)
	for _, misc := range vJSON.Miscsp {
		if misc.Type == "TYPETABLE" {
			for _, t := range misc.Typesp {
				typeMap[t.Addr] = t
			}
		}
	}

	vhdlOut, err := os.Create(vhdlPath)
	if err != nil {
		log.Fatalf("Error creating VHDL: %v", err)
	}
	defer vhdlOut.Close()
	generateVHDL(vJSON.Modulesp, typeMap, vhdlOut)

	hppOut, err := os.Create(hppPath)
	if err != nil {
		log.Fatalf("Error creating HPP: %v", err)
	}
	defer hppOut.Close()
	generateHPP(vJSON.Modulesp, hppOut)
}

func mapVerilogToVHDLType(direction, vType string, dt *DType) string {
	dir := "in"
	if direction == "OUTPUT" {
		dir = "out"
	} else if direction == "INOUT" {
		dir = "inout"
	}

	// Try DType from typetable first
	if dt != nil && dt.Range != "" {
		parts := strings.Split(dt.Range, ":")
		if len(parts) == 2 {
			return fmt.Sprintf("%s std_logic_vector(%s downto %s)", dir, parts[0], parts[1])
		}
	}

	// Parse vector bounds from the type string (fallback), e.g., "logic [7:0]"
	matches := boundsRegex.FindStringSubmatch(vType)
	if len(matches) == 3 {
		return fmt.Sprintf("%s std_logic_vector(%s downto %s)", dir, matches[1], matches[2])
	}

	return fmt.Sprintf("%s std_logic", dir)
}

func generateVHDL(modules []Module, typeMap map[string]DType, out io.Writer) {
	for _, mod := range modules {
		if mod.Type != "MODULE" {
			continue
		}

		fmt.Fprintf(out, "library ieee;\nuse ieee.std_logic_1164.all;\nuse ieee.numeric_std.all;\n\n")
		fmt.Fprintf(out, "entity %s is\n", mod.Name)
		fmt.Fprintf(out, "  generic (\n    INSTANCE_ID : integer\n  );\n")
		fmt.Fprintf(out, "  port (\n")

		var ports []Stmt
		for _, stmt := range mod.Stmtsp {
			if stmt.Type == "VAR" && (stmt.Direction == "INPUT" || stmt.Direction == "OUTPUT" || stmt.Direction == "INOUT") {
				ports = append(ports, stmt)
			}
		}

		for i, port := range ports {
			comma := ";"
			if i == len(ports)-1 {
				comma = ""
			}

			var dt *DType
			if d, ok := typeMap[port.Dtypep]; ok {
				dt = &d
			}

			vhdlType := mapVerilogToVHDLType(port.Direction, port.DtypeName, dt)
			fmt.Fprintf(out, "    %s : %s%s\n", port.OrigName, vhdlType, comma)
		}
		fmt.Fprintf(out, "  );\nend entity;\n\n")

		fmt.Fprintf(out, "architecture proxy of %s is\n", mod.Name)
		fmt.Fprintf(out, "  procedure step_verilator(id: integer) is\n")
		fmt.Fprintf(out, "    attribute foreign of step_verilator : procedure is \"VPI $verilator_step_call\";\n")
		fmt.Fprintf(out, "  begin\n  end procedure;\n")
		fmt.Fprintf(out, "begin\n")
		fmt.Fprintf(out, "  process\n  begin\n")
		// Find a clock port, if none exists, use wait for 1 ns
		clkPort := ""
		for _, p := range ports {
			if strings.Contains(strings.ToLower(p.OrigName), "clk") || strings.Contains(strings.ToLower(p.OrigName), "clock") {
				clkPort = p.OrigName
				break
			}
		}

		if clkPort != "" {
			fmt.Fprintf(out, "    wait until rising_edge(%s);\n", clkPort)
		} else {
			fmt.Fprintf(out, "    wait for 1 ns;\n")
		}
		fmt.Fprintf(out, "    wait for 1 ps; -- Delta cycle sync\n")
		fmt.Fprintf(out, "    step_verilator(INSTANCE_ID);\n")
		fmt.Fprintf(out, "  end process;\n")
		fmt.Fprintf(out, "end architecture;\n\n")
	}
}

func generateHPP(modules []Module, out io.Writer) {
	fmt.Fprintf(out, "#pragma once\n\n")
	fmt.Fprintf(out, "#include <vpi_user.h>\n")
	fmt.Fprintf(out, "#include <string>\n")
	fmt.Fprintf(out, "#include <unordered_map>\n")
	fmt.Fprintf(out, "#include <memory>\n")
	fmt.Fprintf(out, "#include <iostream>\n")

	// We only expect one top module for now.
	var topModule *Module
	for _, mod := range modules {
		if mod.Type == "MODULE" {
			topModule = &mod
			break
		}
	}

	if topModule == nil {
		return
	}

	fmt.Fprintf(out, "#include \"V%s.h\"\n\n", topModule.Name)

	fmt.Fprintf(out, "struct InstanceState {\n")
	fmt.Fprintf(out, "    std::unique_ptr<V%s> dut;\n", topModule.Name)
	fmt.Fprintf(out, "    std::string path_prefix;\n")
	fmt.Fprintf(out, "};\n\n")

	fmt.Fprintf(out, "inline void init_bindings(int id, InstanceState& state, const std::string& path_prefix) {\n")
	fmt.Fprintf(out, "    state.dut = std::make_unique<V%s>();\n", topModule.Name)
	fmt.Fprintf(out, "    state.path_prefix = path_prefix;\n")
	fmt.Fprintf(out, "}\n\n")

	fmt.Fprintf(out, "inline void sync_inputs(InstanceState& state) {\n")
	for _, stmt := range topModule.Stmtsp {
		if stmt.Type == "VAR" && stmt.Direction == "INPUT" {
			fmt.Fprintf(out, "    {\n")
			fmt.Fprintf(out, "        std::string full_name = state.path_prefix + \".%s\";\n", stmt.OrigName)
			fmt.Fprintf(out, "        vpiHandle net_handle = vpi_handle_by_name((PLI_BYTE8*)full_name.c_str(), nullptr);\n")
			fmt.Fprintf(out, "        if (net_handle) {\n")
			fmt.Fprintf(out, "            s_vpi_value val;\n")
			fmt.Fprintf(out, "            val.format = vpiIntVal;\n") // Simplified: assumes <= 32 bits
			fmt.Fprintf(out, "            vpi_get_value(net_handle, &val);\n")
			fmt.Fprintf(out, "            state.dut->%s = val.value.integer;\n", stmt.OrigName)
			fmt.Fprintf(out, "        }\n")
			fmt.Fprintf(out, "    }\n")
		}
	}
	fmt.Fprintf(out, "}\n\n")

	fmt.Fprintf(out, "inline void sync_outputs(InstanceState& state) {\n")
	for _, stmt := range topModule.Stmtsp {
		if stmt.Type == "VAR" && stmt.Direction == "OUTPUT" {
			fmt.Fprintf(out, "    {\n")
			fmt.Fprintf(out, "        std::string full_name = state.path_prefix + \".%s\";\n", stmt.OrigName)
			fmt.Fprintf(out, "        vpiHandle net_handle = vpi_handle_by_name((PLI_BYTE8*)full_name.c_str(), nullptr);\n")
			fmt.Fprintf(out, "        if (net_handle) {\n")
			fmt.Fprintf(out, "            s_vpi_value val;\n")
			fmt.Fprintf(out, "            val.format = vpiIntVal;\n") // Simplified
			fmt.Fprintf(out, "            val.value.integer = state.dut->%s;\n", stmt.OrigName)
			fmt.Fprintf(out, "            vpi_printf((PLI_BYTE8*)\"[VPI] Output %%s = %%d\\n\", full_name.c_str(), val.value.integer);\n")
			fmt.Fprintf(out, "            vpi_put_value(net_handle, &val, nullptr, vpiNoDelay);\n")
			fmt.Fprintf(out, "        } else {\n")
			fmt.Fprintf(out, "            vpi_printf((PLI_BYTE8*)\"[VPI] Output %%s handle NOT FOUND\\n\", full_name.c_str());\n")
			fmt.Fprintf(out, "        }\n")
			fmt.Fprintf(out, "    }\n")
		}
	}
	fmt.Fprintf(out, "}\n\n")

	fmt.Fprintf(out, "inline void eval_model(InstanceState& state) {\n")
	fmt.Fprintf(out, "    state.dut->eval();\n")
	fmt.Fprintf(out, "}\n")
}
