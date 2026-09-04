module airport_baggage_controller #(
    parameter CLK_FREQ_HZ = 50_000_000,
    parameter JAM_TIMEOUT_SEC = 3
)(
    input  logic        clk,
    input  logic        reset,

    // Baggage sensors
    input  logic        baggage_entry,
    input  logic        baggage_exit,

    // Destination selection
    // 00 = Terminal A
    // 01 = Terminal B
    // 10 = Terminal C
    // 11 = Invalid
    input  logic [1:0]  destination,

    // Emergency stop
    input  logic        emergency_stop,

    // Outputs
    output logic        conveyor_motor,
    output logic        diverter_A,
    output logic        diverter_B,
    output logic        diverter_C,

    output logic        jam_alarm,
    output logic        emergency_alarm,

    // Number of baggage currently processed
    output logic [7:0]  baggage_count,

    // System status
    output logic [2:0]  state
);

    // ---------------------------------------------------------
    // State definitions
    // ---------------------------------------------------------

    typedef enum logic [2:0] {
        IDLE       = 3'b000,
        CONVEYOR   = 3'b001,
        ROUTING    = 3'b010,
        WAIT_EXIT  = 3'b011,
        JAM        = 3'b100,
        EMERGENCY  = 3'b101
    } state_t;

    state_t current_state, next_state;

    // ---------------------------------------------------------
    // Timer
    // ---------------------------------------------------------

    localparam integer JAM_TIMEOUT_COUNT =
                    CLK_FREQ_HZ * JAM_TIMEOUT_SEC;

    logic [31:0] jam_timer;

    // ---------------------------------------------------------
    // State register
    // ---------------------------------------------------------

    always_ff @(posedge clk or posedge reset) begin

        if (reset)
            current_state <= IDLE;

        else
            current_state <= next_state;

    end

    // ---------------------------------------------------------
    // Jam timer
    // ---------------------------------------------------------

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin
            jam_timer <= 32'd0;
        end

        else begin

            if (current_state == WAIT_EXIT) begin

                if (jam_timer < JAM_TIMEOUT_COUNT)
                    jam_timer <= jam_timer + 1'b1;

            end

            else begin
                jam_timer <= 32'd0;
            end

        end

    end

    // ---------------------------------------------------------
    // Baggage counter
    // ---------------------------------------------------------

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin
            baggage_count <= 8'd0;
        end

        else begin

            // New baggage detected
            if (baggage_entry && baggage_count < 8'd255)
                baggage_count <= baggage_count + 1'b1;

            // Baggage leaves system
            else if (baggage_exit && baggage_count > 0)
                baggage_count <= baggage_count - 1'b1;

        end

    end

    // ---------------------------------------------------------
    // Next-state logic
    // ---------------------------------------------------------

    always_comb begin

        next_state = current_state;

        case (current_state)

            IDLE: begin

                if (emergency_stop)
                    next_state = EMERGENCY;

                else if (baggage_entry)
                    next_state = CONVEYOR;

            end


            CONVEYOR: begin

                if (emergency_stop)
                    next_state = EMERGENCY;

                else
                    next_state = ROUTING;

            end


            ROUTING: begin

                if (emergency_stop)
                    next_state = EMERGENCY;

                else
                    next_state = WAIT_EXIT;

            end


            WAIT_EXIT: begin

                if (emergency_stop)
                    next_state = EMERGENCY;

                else if (baggage_exit)
                    next_state = IDLE;

                else if (jam_timer >= JAM_TIMEOUT_COUNT)
                    next_state = JAM;

            end


            JAM: begin

                // Stay in JAM until reset
                next_state = JAM;

            end


            EMERGENCY: begin

                // Stay in emergency until reset
                next_state = EMERGENCY;

            end


            default:
                next_state = IDLE;

        endcase

    end

    // ---------------------------------------------------------
    // Output logic
    // ---------------------------------------------------------

    always_comb begin

        // Default outputs
        conveyor_motor = 1'b0;

        diverter_A = 1'b0;
        diverter_B = 1'b0;
        diverter_C = 1'b0;

        jam_alarm = 1'b0;
        emergency_alarm = 1'b0;


        case (current_state)

            IDLE: begin

                conveyor_motor = 1'b0;

            end


            CONVEYOR: begin

                conveyor_motor = 1'b1;

            end


            ROUTING: begin

                conveyor_motor = 1'b1;

                case (destination)

                    2'b00:
                        diverter_A = 1'b1;

                    2'b01:
                        diverter_B = 1'b1;

                    2'b10:
                        diverter_C = 1'b1;

                    default: begin
                        diverter_A = 1'b0;
                        diverter_B = 1'b0;
                        diverter_C = 1'b0;
                    end

                endcase

            end


            WAIT_EXIT: begin

                conveyor_motor = 1'b1;

            end


            JAM: begin

                conveyor_motor = 1'b0;
                jam_alarm = 1'b1;

            end


            EMERGENCY: begin

                conveyor_motor = 1'b0;
                emergency_alarm = 1'b1;

            end


            default: begin

                conveyor_motor = 1'b0;

            end

        endcase

    end

    // ---------------------------------------------------------
    // Output state for debugging
    // ---------------------------------------------------------

    always_comb begin

        state = current_state;

    end

endmodule
