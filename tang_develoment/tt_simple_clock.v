`default_nettype none


module tang_nano(input wire clk,
                 input wire reset_n,
                 input wire btn1,
                 input wire btn2,
                 output wire [7:0] segments,
                 output wire [3:0] selector,
                 output wire clockCheck,
                 output wire clockCheck2);
    
    localparam FRECUENCY = (27000000+253);
    wire reset           = !reset_n;
    reg auxTougle        = 0;
    reg auxTougle2       = 0;
    
    reg [3:0] min_u           = 0;
    reg [3:0] min_d           = 0;
    reg [3:0] hrs_u           = 0;
    reg [3:0] hrs_d           = 0;
    reg [4:0] time_leds       = 0;
    reg point_led             = 0;
    reg pressed_min           = 0;
    reg pressed_hrs           = 0;
    reg [25:0] clock_counter  = 0;
    reg [25:0] millis_counter = 0;
    reg [6:0] sec_counter     = 0;
    reg [3:0] bufferCounter   = 0;
    reg [3:0] selector_output = 1;
    
    wire adj_min_pulse, adj_hrs_pulse;
    
    always @(posedge clk) begin
        if (reset) begin
            min_u           <= 0;
            min_d           <= 0;
            hrs_u           <= 0;
            hrs_d           <= 0;
            clock_counter   <= 0;
            time_leds       <= 0;
            pressed_min     <= 0;
            pressed_hrs     <= 0;
            millis_counter  <= 0;
            sec_counter     <= 0;
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
                time_leds   <= 0;
                min_u       <= min_u + 1;
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
            
            // second counter
            clock_counter <= clock_counter + 1;
            if (clock_counter == FRECUENCY) begin
                clock_counter <= 0;
                sec_counter   <= sec_counter + 1;
            end
            
            // millis counter
            millis_counter <= millis_counter + 1;
            if (millis_counter == (FRECUENCY/1000)) begin
                millis_counter  <= 0;
                selector_output <= (selector_output << 1) | (selector_output >> (4-1));
                
            end
            
            if (adj_min_pulse && pressed_min == 0) begin
                min_u       <= min_u + 1;
                pressed_min <= 1;
                time_leds   <= 0;
                sec_counter   <= 0;
            end
            else if(adj_min_pulse == 0 && pressed_min == 1) begin
                pressed_min <= 0;
            end
            
            if (adj_hrs_pulse && pressed_hrs == 0) begin
                hrs_u       <= hrs_u + 1;
                pressed_hrs <= 1;
                time_leds   <= 0;
                sec_counter   <= 0;
            end
            else if(adj_hrs_pulse == 0 && pressed_hrs == 1) begin
                pressed_hrs <= 0;
            end
            
            
        end
    end
    
    always @(*) begin
        case(selector_output)
            1:  bufferCounter = min_u;
            2:  bufferCounter = min_d;
            4:  bufferCounter = hrs_u;
            8:  bufferCounter = hrs_d;
            default:
            bufferCounter = 0;
        endcase
    end
    
    always @(*) begin
        case(selector_output)
            1:  point_led = time_leds[3];
            2:  point_led = time_leds[2];
            4:  point_led = time_leds[1];
            8:  point_led = time_leds[0];
            default:
            point_led = 0;
        endcase
    end
    
    seg7 seg7(
    .number(bufferCounter),
    .segments(segments[6:0])
    );
    
    
    debouncer #((FRECUENCY/1000)*8) minutes_increase(
    .clk(clk),
    .reset(0),
    .in(!btn1),
    .out(adj_min_pulse)
    );
    
    debouncer #((FRECUENCY/1000)*8) hours_increase(
    .clk(clk),
    .reset(0),
    .in(!btn2),
    .out(adj_hrs_pulse)
    );
    
    assign segments[7] = point_led;
    assign selector    = ~selector_output;
    assign clockCheck  = auxTougle;
    assign clockCheck2 = adj_min_pulse;
    
endmodule
    
    module seg7 (
        input wire [3:0] number,
        output reg [6:0] segments
        );
        
        always @(*) begin
            case(number)
                //                7654321
                0:  segments = 7'b0111111;
                1:  segments = 7'b0000110;
                2:  segments = 7'b1011011;
                3:  segments = 7'b1001111;
                4:  segments = 7'b1100110;
                5:  segments = 7'b1101101;
                6:  segments = 7'b1111100;
                7:  segments = 7'b0000111;
                8:  segments = 7'b1111111;
                9:  segments = 7'b1100111;
                default:
                segments = 7'b0000000;
            endcase
        end
        
    endmodule
        
        
        module debouncer #(
            parameter MAX_COUNT = 512
            )(
            input   clk,
            input   reset,
            input   in,
            output  out
            );
            
            reg [25:0] counter;
            
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
