module divider (
    input clk,
    input rstn,
    input [31:0] SPI_BITRATE,
    output reg spi_clk
);

    reg [31:0] counter;

    always @(posedge clk) begin
        if (rstn) begin
            counter <= 0;
            spi_clk <= 0;
        end else begin
            if (counter >= SPI_BITRATE - 1) begin
                counter <= 0;
                spi_clk <= ~spi_clk;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule

module spi_mode_config (
    input wire clk,
    input wire reset,
    input wire sclk_raw,
    input wire cpol,
    input wire cpha,
    output reg sclk,
    output reg capture_edge,
    output reg shift_edge
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sclk <= 1'b0;
        end else begin
            sclk <= cpol ? ~sclk_raw : sclk_raw;
        end
    end

    always @(*) begin
        if (cpha == 1'b0) begin
            capture_edge = (cpol == 1'b0) ? 1'b0 : 1'b1;
            shift_edge = ~capture_edge;
        end else begin
            capture_edge = (cpol == 1'b0) ? 1'b1 : 1'b0;
            shift_edge = ~capture_edge;
        end
    end

endmodule

module shift_register_rx (
    input wire clk,
    input wire reset,
    input wire sclk,
    input wire miso,
    output reg [7:0] data_out,
    output reg done
);

    reg [7:0] shift_reg;
    reg [2:0] bit_counter;

    always @(posedge sclk or posedge reset) begin
        if (reset) begin
            shift_reg <= 8'b0;
            bit_counter <= 3'b0;
            done <= 1'b0;
        end else begin
            shift_reg <= {shift_reg[6:0], miso};
            if (bit_counter == 3'd7) begin
                data_out <= {shift_reg[6:0], miso};
                done <= 1'b1;
                bit_counter <= 3'b0;
            end else begin
                bit_counter <= bit_counter + 1;
                done <= 1'b0;
            end
        end
    end

endmodule


module shift_register_tx (
    input wire clk,
    input wire reset,
    input wire sclk,
    input wire load,
    input wire [7:0] data_in,
    output reg mosi,
    output reg busy
);

    reg [7:0] shift_reg;
    reg [2:0] bit_counter;

    always @(posedge sclk or posedge reset) begin
        if (reset) begin
            shift_reg <= 8'b0;
            bit_counter <= 3'b0;
            busy <= 1'b0;
            mosi <= 1'b0;
        end else if (load) begin
            shift_reg <= data_in;
            bit_counter <= 3'b0;
            busy <= 1'b1;
        end else if (busy) begin
            mosi <= shift_reg[7];
            shift_reg <= {shift_reg[6:0], 1'b0};
            if (bit_counter == 3'd7) begin
                busy <= 1'b0;
            end else begin
                bit_counter <= bit_counter + 1;
            end
        end
    end

endmodule


module spi_shift_registers (
    input wire clk,
    input wire reset,
    input wire sclk,
    input wire load,
    input wire [7:0] tx_data,
    input wire miso,
    output wire mosi,
    output wire [7:0] rx_data,
    output wire tx_busy,
    output wire rx_done
);

    shift_register_tx tx_reg (
        .clk(clk),
        .reset(reset),
        .sclk(sclk),
        .load(load),
        .data_in(tx_data),
        .mosi(mosi),
        .busy(tx_busy)
    );

    shift_register_rx rx_reg (
        .clk(clk),
        .reset(reset),
        .sclk(sclk),
        .miso(miso),
        .data_out(rx_data),
        .done(rx_done)
    );

endmodule


module spi_master (
    input wire clk,
    input wire reset,
    input wire [31:0] SPI_BITRATE,
    input wire [7:0] control_bus,
    input wire cpol,
    input wire cpha,
    input wire start,
    input wire [7:0] tx_data,
    input wire miso,
    output wire mosi,
    output wire [7:0] rx_data,
    output reg busy,
    output reg done
);

    wire spi_clk_raw;
    wire spi_clk_adj;
    wire capture_edge;
    wire shift_edge;
    wire tx_busy;
    wire rx_done;

    reg [2:0] state;
    reg [2:0] next_state;

    localparam IDLE       = 3'b000,
               CONFIGURE  = 3'b001,
               TRANSMIT   = 3'b010,
               RECEIVE    = 3'b011,
               COMPLETE   = 3'b100;

    divider divider_inst (
        .clk(clk),
        .rstn(~reset),
        .SPI_BITRATE(SPI_BITRATE),
        .spi_clk(spi_clk_raw)
    );

    spi_mode_config mode_config (
        .clk(clk),
        .reset(reset),
        .sclk_raw(spi_clk_raw),
        .cpol(control_bus[6]),
        .cpha(control_bus[7]),
        .sclk(spi_clk_adj),
        .capture_edge(capture_edge),
        .shift_edge(shift_edge)
    );

    spi_shift_registers shift_regs (
        .clk(clk),
        .reset(reset),
        .sclk(spi_clk_adj),
        .load(state == CONFIGURE),
        .tx_data(tx_data),
        .miso(miso),
        .mosi(mosi),
        .rx_data(rx_data),
        .tx_busy(tx_busy),
        .rx_done(rx_done)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            busy <= 1'b0;
            done <= 1'b0;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                done = 1'b0;
                if (control_bus[1]) begin
                    next_state = CONFIGURE;
                    busy = 1'b1;
                end
            end
            CONFIGURE: begin
                if (!tx_busy) begin
                    next_state = TRANSMIT;
                end
            end
            TRANSMIT: begin
                if (tx_busy) begin
                    next_state = RECEIVE;
                end
            end
            RECEIVE: begin
                if (rx_done) begin
                    next_state = COMPLETE;
                end
            end
            COMPLETE: begin
                done = 1'b1;
                busy = 1'b0;
                next_state = IDLE;
            end
        endcase
    end

endmodule
