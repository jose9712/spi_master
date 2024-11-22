# SPI Master Module in Verilog

Este proyecto implementa un **SPI Master** en Verilog, compatible con la interfaz Serial Peripheral Interface (SPI). El módulo permite la transmisión y recepción de datos con configuraciones de **CPOL** y **CPHA** configurables. Además, incluye un divisor de reloj y registros de desplazamiento para manejar la transmisión y recepción de datos de 8 bits.

## Descripción

El módulo `spi_master` está diseñado para controlar un bus SPI desde el lado maestro. Utiliza una máquina de estados para gestionar las operaciones de configuración, transmisión y recepción de datos. Los siguientes componentes están implementados:

- **Divisor de reloj** (`divider`): Genera un reloj SPI a partir del reloj del sistema ajustado a la tasa de bits deseada.
- **Configuración de modo SPI** (`spi_mode_config`): Ajusta las señales SPI basadas en las configuraciones de CPOL y CPHA.
- **Registro de desplazamiento para recepción** (`shift_register_rx`): Almacena los datos recibidos en un registro de 8 bits.
- **Registro de desplazamiento para transmisión** (`shift_register_tx`): Transmite los datos desde un registro de 8 bits.
- **Máquina de estados**: Coordina las diferentes etapas del proceso SPI (configuración, transmisión, recepción y finalización).

## Estructura del Proyecto

- `divider`: Módulo para generar el reloj SPI ajustado a la tasa de bits.
- `spi_mode_config`: Módulo para configurar las señales `SCLK`, `CPOL`, `CPHA`, y los flancos de captura y cambio de datos.
- `shift_register_rx`: Módulo de registro de desplazamiento para recibir datos SPI.
- `shift_register_tx`: Módulo de registro de desplazamiento para transmitir datos SPI.
- `spi_shift_registers`: Instancia de los módulos `shift_register_tx` y `shift_register_rx`.
- `spi_master`: Módulo principal que integra todos los componentes y gestiona la comunicación SPI.

## Funcionalidades

1. **División de reloj**: Ajusta la frecuencia del reloj del sistema para que coincida con la tasa de bits del SPI.
2. **Configuración de CPOL y CPHA**: Permite configurar el modo de reloj SPI (polaridad y fase del reloj).
3. **Transmisión y recepción de datos**: Utiliza registros de desplazamiento para transmitir y recibir datos de 8 bits.
4. **Control de flujo**: Señales de control como `start`, `busy`, y `done` para gestionar el estado del proceso de transmisión.

## Requisitos

- **Verilog**: El código está escrito en Verilog y es compatible con cualquier simulador que soporte esta sintaxis.
- **Simulador/Entorno de Desarrollo**: Puedes usar herramientas como **ModelSim**, **Vivado**, **Quartus**, o **EDA Playground** para simular y sintetizar el diseño.

## Uso

1. **Conexiones**:
   - **control_bus[7:0]**: Controla las señales de configuración SPI.
     - Bit 1: Señal `start` para iniciar la transmisión.
     - Bit 6: Señal `cpol` para configurar la polaridad del reloj.
     - Bit 7: Señal `cpha` para configurar la fase del reloj.
   - **SPI_BITRATE**: Define la tasa de bits del SPI.
   - **clk**: Reloj del sistema.
   - **reset**: Señal de reinicio.
   - **tx_data**: Datos de 8 bits para transmitir.
   - **miso**: Entrada de datos SPI (Master In, Slave Out).
   - **mosi**: Salida de datos SPI (Master Out, Slave In).
   - **rx_data**: Datos recibidos por el SPI.

2. **Proceso**:
   - Configura el bus de control para definir los parámetros de SPI.
   - Envía los datos a través del bus SPI.
   - Recibe los datos SPI cuando estén disponibles.
   - Verifica las señales `done` y `busy` para saber cuándo se completa la transmisión.


