`timescale 1ns / 1ps

module piso_sipo_dual_tb;

    parameter N = 8; // Tamaño del registro

    // Señales de prueba
    reg clk;
    reg rst;
    reg load;
    reg [N-1:0] pdata_in;
    reg sin;
    wire sout;
    wire [N-1:0] pdata_out;

    // Instancia del módulo bajo prueba (UUT)
    piso_sipo_dual #(.N(N)) uut (
        .clk(clk),
        .rst(rst),
        .load(load),
        .pdata_in(pdata_in),
        .sin(sin),
        .sout(sout),
        .pdata_out(pdata_out)
    );

    always
    	begin
        	#5 clk=!clk;
    	end

    // Bloque de prueba
    initial begin
        // Inicialización
        clk = 0;
        rst = 0;
        load = 0;
        pdata_in = 0;
        sin = 0;

        // Monitor para observar el comportamiento
        $dumpfile("piso_sipo.vcd");
        $dumpvars;
        
        $monitor($time, "clk=%b, rst=%b, load=%b, pdata_in=%b, sin=%b, sout=%b, pdata_out=%b", clk, rst, load, pdata_in, sin, sout, pdata_out);

        // Reset del módulo
        #10 rst = 1;
        #10 rst = 0;

        // Cargar datos paralelos
        #10 load = 1; pdata_in = 8'b11010101; // Carga 0xD5
        #10 load = 0;

        // Probar modo PISO (salida serial)
        #10 sin = 1; 	//1b
        #10 sin = 0;	//2b
        #10 sin = 1;	//3b
        #10 sin = 1;	//4b
        #10 sin = 1;	//5b
        #10 sin = 1;	//6b
        #10 sin = 0;	//7b
        #10 sin = 0;	//8b
        #10 sin = 0;
        #10 sin = 0;
        

        $finish;
    end

endmodule
