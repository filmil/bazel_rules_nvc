package main

import (
	"encoding/xml"
	"fmt"
	"io"
	"log"
	"os"
	"regexp"
	"strings"
)

type VerilatorXML struct {
	XMLName xml.Name `xml:"verilator_xml"`
	Netlist Netlist  `xml:"netlist"`
}

type Netlist struct {
	Modules []Module `xml:"module"`
}

type Module struct {
	Name  string `xml:"name,attr"`
	Ports []Port `xml:"port"`
}

type Port struct {
	Name      string `xml:"name,attr"`
	Direction string `xml:"direction,attr"`
	Type      string `xml:"type,attr"`
}

var boundsRegex = regexp.MustCompile(`\[(\d+):(\d+)\]`)

func main() {
	if len(os.Args) != 4 {
		log.Fatalf("Usage: %s <input.xml> <out_proxy.vhdl> <out_bindings.hpp>", os.Args[0])
	}

	xmlPath := os.Args[1]
	vhdlPath := os.Args[2]
	hppPath := os.Args[3]

	xmlFile, err := os.Open(xmlPath)
	if err != nil {
		log.Fatalf("Error opening XML: %v", err)
	}
	defer xmlFile.Close()

	xmlData, err := io.ReadAll(xmlFile)
	if err != nil {
		log.Fatalf("Error reading XML: %v", err)
	}

	var vXML VerilatorXML
	if err := xml.Unmarshal(xmlData, &vXML); err != nil {
		log.Fatalf("Error unmarshalling XML: %v", err)
	}

	if len(vXML.Netlist.Modules) == 0 {
		log.Fatal("No modules found in XML")
	}

	vhdlOut, err := os.Create(vhdlPath)
	if err != nil {
		log.Fatalf("Error creating VHDL: %v", err)
	}
	defer vhdlOut.Close()
	generateVHDL(vXML.Netlist.Modules, vhdlOut)

	hppOut, err := os.Create(hppPath)
	if err != nil {
		log.Fatalf("Error creating HPP: %v", err)
	}
	defer hppOut.Close()
	generateHPP(vXML.Netlist.Modules, hppOut)
}

func mapVerilogToVHDLType(direction, vType string) string {
	dir := "in"
	if direction == "out" {
		dir = "out"
	}

	// Parse vector bounds from the type string, e.g., "logic [7:0]" -> std_logic_vector(7 downto 0)
	matches := boundsRegex.FindStringSubmatch(vType)
	if len(matches) == 3 {
		return fmt.Sprintf("%s std_logic_vector(%s downto %s)", dir, matches[1], matches[2])
	}

	return fmt.Sprintf("%s std_logic", dir)
}

func generateVHDL(modules []Module, out io.Writer) {
	for _, mod := range modules {
		fmt.Fprintf(out, "library ieee;\nuse ieee.std_logic_1164.all;\nuse ieee.numeric_std.all;\n\n")
		fmt.Fprintf(out, "entity %s is\n", mod.Name)
		fmt.Fprintf(out, "  generic (\n    INSTANCE_ID : integer\n  );\n")
		fmt.Fprintf(out, "  port (\n")

		for i, port := range mod.Ports {
			comma := ";"
			if i == len(mod.Ports)-1 {
				comma = ""
			}

			vhdlType := mapVerilogToVHDLType(port.Direction, port.Type)
			fmt.Fprintf(out, "    %s : %s%s\n", port.Name, vhdlType, comma)
		}
		fmt.Fprintf(out, "  );\nend entity;\n\n")

		fmt.Fprintf(out, "architecture proxy of %s is\n", mod.Name)
		fmt.Fprintf(out, "  procedure step_verilator(id: integer) is\n")
		fmt.Fprintf(out, "    attribute foreign of step_verilator : procedure is \"VPI verilator_step_call\";\n")
		fmt.Fprintf(out, "  begin\n  end procedure;\n")
		fmt.Fprintf(out, "begin\n")
		fmt.Fprintf(out, "  process\n  begin\n")
		// Find a clock port, if none exists, use wait for 1 ns
		clkPort := ""
		for _, p := range mod.Ports {
			if strings.Contains(strings.ToLower(p.Name), "clk") || strings.Contains(strings.ToLower(p.Name), "clock") {
				clkPort = p.Name
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
	fmt.Fprintf(out, "#include <unordered_map>\n\n")

	// In a real implementation this would generate specific structures per module
	// and a unified lookup map, but for the demo we'll assume a single generic approach
	// or specific overloads. We'll generate a simplistic proxy state struct that
	// holds a generic pointer to be mocked by the VPI wrapper.
	
	fmt.Fprintf(out, "struct InstanceState {\n")
	fmt.Fprintf(out, "    void* dut; // Pointer to verilated model\n")
	fmt.Fprintf(out, "};\n\n")

    fmt.Fprintf(out, "// Declare standard sync functions to be implemented by wrapper\n")
	fmt.Fprintf(out, "extern void init_bindings(int id, InstanceState& state, const std::string& path_prefix);\n")
	fmt.Fprintf(out, "extern void sync_inputs(InstanceState& state);\n")
	fmt.Fprintf(out, "extern void sync_outputs(InstanceState& state);\n")
	fmt.Fprintf(out, "inline void eval_model(InstanceState& state) { /* Mock eval */ }\n")
}
