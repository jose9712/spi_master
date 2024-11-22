`timescale 1ns / 1ps

module divider_tb;

    reg clk;                 // Señal de reloj
    reg reset;               // Señal de reset
    reg [31:0] SPI_BITRATE;  // Velocidad de SPI en bits
    wire spi_clk;            // Reloj SPI generado por el módulo

    // Instancia del módulo bajo prueba (UUT)
    divider uut (
        .clk(clk),
        .rstn(reset),         // Cambié rstn porque parece ser activo bajo (reset no activo)
        .SPI_BITRATE(SPI_BITRATE),
        .spi_clk(spi_clk)
    );

    // Generador de reloj
    always begin
        #1 clk = ~clk; // Reloj con periodo de 2 ns
    end

    // Bloque de prueba
    initial begin
        // Inicialización
        clk = 0;
        reset = 0;
        SPI_BITRATE = 32'b1010;

        // Monitor para observar el comportamiento
        $dumpfile("divider.vcd");      // Archivo para almacenar las señales
        $dumpvars;                     // Volcado de variables
        $monitor($time, " clk=%b, reset=%b, SPI_BITRATE=%b, spi_clk=%b", 
                 clk, reset, SPI_BITRATE, spi_clk);

        // Secuencia de pruebas
        #2 reset = 1;  // Activar reset
        #2 reset = 0;  // Desactivar reset
        #200;           // Esperar por comportamiento

        // Finalizar simulación
        $finish;
    end

endmodule

