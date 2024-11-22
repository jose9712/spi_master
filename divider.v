module divider (
    input clk,                     // Reloj del sistema (CPU_Clock)
    input rstn,
    input [31:0] SPI_BITRATE,                    // Reset activo en bajo
    output reg spi_clk             // Reloj dividido para SPI
);
    
    
    
    
    reg [31:0] counter;            // Contador para dividir el reloj
    
    // Bloque secuencial activado en el flanco positivo del reloj
    always @(posedge clk) begin
        if (rstn) begin
            counter <= 0;
            spi_clk <= 0;
        end else begin
            if (counter >= SPI_BITRATE - 1) begin
                counter <= 0;
                spi_clk <= ~spi_clk;   // Cambia el estado del reloj SPI
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
