`default_nettype none

module tang_nano (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

//Frecuency for tang nano
//localparam FRECUENCY = (27000000 + 253);
//Frecuency for tinyTapeout
localparam FRECUENCY = (27000000 + 253);
localparam MULTIPLEX_TIME = FRECUENCY/1000;
localparam DEBOUNCE_TIME = MULTIPLEX_TIME*8;
wire reset = !rst_n;
assign uio_oe = 8'b11111111;

wire btn1;
//Pull up in button
wire btn2;
//Pull up in button
assign btn1 = ui_in[0];
assign btn2 = ui_in[1];

wire negateSegments;
wire negateSelector;
assign negateSelector = ui_in[2];
assign negateSegments = ui_in[3];

assign uio_out[0] = (negateSelector) ? ~selector_output[0] : selector_output[0];
assign uio_out[1] = (negateSelector) ? ~selector_output[1] : selector_output[1];
assign uio_out[2] = (negateSelector) ? ~selector_output[2] : selector_output[2];
assign uio_out[3] = (negateSelector) ? ~selector_output[3] : selector_output[3];
assign uio_out[4] = pulseSeconds;
assign uio_out[5] = pulseMinutes;
assign uio_out[6] = 0;
assign uio_out[7] = 0;

assign uo_out[0] = (negateSegments) ? ~segments[0] : segments[0];
assign uo_out[1] = (negateSegments) ? ~segments[1] : segments[1];
assign uo_out[2] = (negateSegments) ? ~segments[2] : segments[2];
assign uo_out[3] = (negateSegments) ? ~segments[3] : segments[3];
assign uo_out[4] = (negateSegments) ? ~segments[4] : segments[4];
assign uo_out[5] = (negateSegments) ? ~segments[5] : segments[5];
assign uo_out[6] = (negateSegments) ? ~segments[6] : segments[6];
assign uo_out[7] = (negateSegments) ? ~point_led : point_led;

wire adj_min_pulse, adj_hrs_pulse;

reg point_led;
reg [6 : 0] segments;

reg [3 : 0] bufferCounter;
reg pulseSeconds;
reg pulseMinutes;

reg [3 : 0] min_u;
reg [3 : 0] min_d;
reg [3 : 0] hrs_u;
reg [3 : 0] hrs_d;
reg [3 : 0] time_leds;
reg pressed_min;
reg pressed_hrs;
reg [25 : 0] clock_counter;
reg [25 : 0] millis_counter;
reg [6 : 0] sec_counter;
reg [3 : 0] selector_output;
always @(posedge clk) begin
if (reset) begin
	min_u <= 0;
	min_d <= 0;
	hrs_u <= 0;
	hrs_d <= 0;
	time_leds <= 0;
	pressed_min <= 0;
	pressed_hrs <= 0;
	clock_counter <= 0;
	millis_counter <= 0;
	sec_counter <= 0;
	selector_output <= 1;
end
else begin

if (sec_counter == 15) begin
	time_leds <= 4'b1000;
end

if (sec_counter == 30) begin
	time_leds <= 4'b1100;
end

if (sec_counter == 45) begin
	time_leds <= 4'b1110;
end

if (sec_counter == 60) begin
	sec_counter <= 0;
	time_leds <= 0;
	min_u <= min_u + 1;
	pulseMinutes <= ~pulseMinutes;
end

if (min_u == 10) begin
	min_u <= 0;
	min_d <= min_d + 1;
end

if (min_d == 6) begin
	min_d <= 0;
	hrs_u <= hrs_u + 1;
end

if (hrs_u == 10) begin
	hrs_u <= 0;
	hrs_d <= hrs_d + 1;
end

if (hrs_d == 2 && hrs_u == 4) begin
	hrs_u <= 0;
	hrs_d <= 0;
end

clock_counter <= clock_counter + 1;
if (clock_counter == FRECUENCY) begin
	clock_counter <= 0;
	sec_counter <= sec_counter + 1;
	pulseSeconds <= ~pulseSeconds;
end

millis_counter <= millis_counter + 1;
if (millis_counter == MULTIPLEX_TIME) begin
	millis_counter <= 0;
	selector_output <= (selector_output << 1) | (selector_output >> (4 - 1));
end

if (adj_min_pulse && pressed_min == 0) begin
	min_u <= min_u + 1;
	pressed_min <= 1;
	time_leds <= 0;
	sec_counter <= 0;
end
else if (adj_min_pulse == 0 && pressed_min == 1) begin
pressed_min <= 0;
end

if (adj_hrs_pulse && pressed_hrs == 0) begin
	hrs_u <= hrs_u + 1;
	pressed_hrs <= 1;
	time_leds <= 0;
	sec_counter <= 0;
end
else if (adj_hrs_pulse == 0 && pressed_hrs == 1) begin
pressed_hrs <= 0;
end
end
end

always @( *) begin
case(selector_output)
	1 : bufferCounter = min_u;
	2 : bufferCounter = min_d;
	4 : bufferCounter = hrs_u;
	8 : bufferCounter = hrs_d;
	default :
	bufferCounter = 0;
	endcase
end

always @( *) begin
case(selector_output)
	1 : point_led = time_leds[3];
	2 : point_led = time_leds[2];
	4 : point_led = time_leds[1];
	8 : point_led = time_leds[0];
	default :
	point_led = 0;
	endcase
end

seg7 seg7(
.number(bufferCounter),
.segments(segments)
);

debouncer #(DEBOUNCE_TIME) minutes_increase(
.clk(clk),
.reset(reset),
.in(!btn1),
.out(adj_min_pulse)
);

debouncer #(DEBOUNCE_TIME) hours_increase(
.clk(clk),
.reset(reset),
.in(!btn2),
.out(adj_hrs_pulse)
);

endmodule

module seg7 (
input wire [3 : 0] number,
output reg [6 : 0] segments
);

always @( *) begin
case(number)
	0 : segments = 7'b0111111;
	1 : segments = 7'b0000110;
	2 : segments = 7'b1011011;
	3 : segments = 7'b1001111;
	4 : segments = 7'b1100110;
	5 : segments = 7'b1101101;
	6 : segments = 7'b1111100;
	7 : segments = 7'b0000111;
	8 : segments = 7'b1111111;
	9 : segments = 7'b1100111;
	default :
	segments = 7'b0000000;
	endcase
end

endmodule
module debouncer #(
parameter MAX_COUNT = 512
)(
input clk,
input reset,
input in,
output out
);

reg [32 : 0] counter;

always @(posedge clk) begin
if (reset || !in) begin
	counter <= 0;
end else begin
if (counter < MAX_COUNT) begin
	counter <= counter + 1;
end
end
end

assign out = (counter == MAX_COUNT);

endmodule
