module demo_top (
    // Adder ports
    input wire [7:0] adder_a,
    input wire [7:0] adder_b,
    output wire [8:0] adder_sum,

    // Counter ports
    input wire clk,
    input wire rst,
    input wire enable,
    output wire [7:0] count
);

    adder adder_inst (
        .a(adder_a),
        .b(adder_b),
        .sum(adder_sum)
    );

    counter counter_inst (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .count(count)
    );

endmodule
