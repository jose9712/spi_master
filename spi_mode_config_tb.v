module tb_spi_mode_config;

    reg clk;
    reg reset;
    reg sclk_raw;
    reg cpol;
    reg cpha;
    wire sclk;
    wire capture_edge;
    wire shift_edge;

    // Instanciar el módulo
    spi_mode_config uut (
        .clk(clk),
        .reset(reset),
        .sclk_raw(sclk_raw),
        .cpol(cpol),
        .cpha(cpha),
        .sclk(sclk),
        .capture_edge(capture_edge),
        .shift_edge(shift_edge)
    );

    // Generar reloj del sistema
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Periodo de 10 ns
    end

    // Generar señal de reloj sin ajustar
    initial begin
        sclk_raw = 0;
        forever #20 sclk_raw = ~sclk_raw; // Periodo de 40 ns
    end

    // Probar diferentes configuraciones de CPOL y CPHA
    initial begin
        reset = 1;
        cpol = 0;
        cpha = 0;
        $dumpfile("spi_mode_config.vcd");      // Archivo de volcado de señales
        $dumpvars;      // Guardar variables del testbench
        $monitor($time, " clk=%b, reset=%b, sclk_raw=%b, cpol=%b, cpha=%b, sclk=%b, capture_edge=%b, shift_edge%b", 
                 clk, reset, sclk_raw, cpol, cpha, sclk, capture_edge, shift_edge);

        #15 reset = 0;

        // CPOL = 0, CPHA = 0
        #40 cpol = 0; cpha = 0;

        // CPOL = 0, CPHA = 1
        #40 cpol = 0; cpha = 1;

        // CPOL = 1, CPHA = 0
        #40 cpol = 1; cpha = 0;

        // CPOL = 1, CPHA = 1
        #40 cpol = 1; cpha = 1;

        #100 
        $finish; // Finalizar simulación
    end

endmodule
