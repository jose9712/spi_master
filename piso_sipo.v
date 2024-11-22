module piso_sipo_dual #(
    parameter N = 32 // Tamaño del registro
) (
    input wire clk,         // Señal de reloj
    input wire rst,         // Reset síncrono
    input wire load,        // Cargar datos paralelos
    input wire [N-1:0] pdata_in, // Datos paralelos de entrada para carga
    input wire sin,         // Entrada serial
    output reg sout,        // Salida serial
    output reg [N-1:0] pdata_out // Datos paralelos actuales
);

    reg [N-1:0] shift_reg; // Registro de desplazamiento

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Resetear el registro
            shift_reg <= 0;
            sout <= 0;
            pdata_out <= 0;
        end else begin
            if (load) begin
                // Cargar datos paralelos en el registro
                shift_reg <= pdata_in;
            end else begin
                // Modo combinado PISO y SIPO
                sout <= shift_reg[N-1];             // Enviar el bit más significativo como salida serial
                shift_reg <= {shift_reg[N-2:0], sin}; // Desplazar el registro e ingresar el nuevo bit serial
            end
            pdata_out <= shift_reg; // Actualizar la salida paralela
        end
    end

endmodule
