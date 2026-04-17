module des3_encrypt
(
    input         clock,
    input         rst,
    input         select,     
    input  [63:0] key0,
    input  [63:0] key1,
    input  [63:0] key2,
    input  [63:0] input_data,
    output reg [63:0] output_data,
    output reg        done
);

    reg [63:0] k0;
    reg [63:0] k1;
    reg [63:0] k2;

    always @(posedge clock or posedge rst) begin
        if (rst) begin
            k0 <= 64'd0;
            k1 <= 64'd0;
            k2 <= 64'd0;
        end else begin
            k0 <= key0;
            k1 <= key1;
            k2 <= key2;
        end
    end

    wire [63:0] BLOCK0_1;  
    wire [63:0] BLOCK1_2;  
    wire [63:0] BLOCK2_O;  

    wire [2:0] block_done;

    localparam S_IDLE  = 3'd0;
    localparam S_RUN0  = 3'd1;
    localparam S_WAIT0 = 3'd2;
    localparam S_RUN1  = 3'd3;
    localparam S_WAIT1 = 3'd4;
    localparam S_RUN2  = 3'd5;
    localparam S_WAIT2 = 3'd6;

    reg [2:0] state, nstate;

    reg start0, start1, start2;

    always @* begin
        nstate = state;
        start0 = 1'b0;
        start1 = 1'b0;
        start2 = 1'b0;

        case (state)
            S_IDLE: begin
                if (select) begin
                    nstate = S_RUN0;
                    start0 = 1'b1;   
                end
            end

            S_RUN0: begin
                
                if (block_done[0])
                    nstate = S_WAIT0;
            end

            S_WAIT0: begin
                start1 = 1'b1;      
                nstate = S_RUN1;
            end

            S_RUN1: begin
                if (block_done[1])
                    nstate = S_WAIT1;
            end

            S_WAIT1: begin
                start2 = 1'b1;     
                nstate = S_RUN2;
            end

            S_RUN2: begin
                if (block_done[2])
                    nstate = S_WAIT2;
            end

            S_WAIT2: begin
                if (select) begin
                    nstate = S_RUN0;
                    start0 = 1'b1;
                end else begin
                    nstate = S_IDLE;
                end
            end

            default: begin
                nstate = S_IDLE;
            end
        endcase
    end

    always @(posedge clock or posedge rst) begin
        if (rst) begin
            state       <= S_IDLE;
            output_data <= 64'd0;
            done        <= 1'b0;
        end else begin
            state <= nstate;

            done <= (state == S_WAIT2);

            if (state == S_WAIT2)
                output_data <= BLOCK2_O;
        end
    end

    des_encrypt des0 (
        .clock       (clock),
        .rst       (rst),
        .select    (start0),
        .plaintext (input_data),
        .key       (k0),
        .dectext   (BLOCK0_1),
        .done      (block_done[0])
    );

    des_decrypt des1 (
        .clock          (clock),
        .rst          (rst),
        .select       (start1),
        .ciphertext   (BLOCK0_1),
        .key          (k1),
        .plaintext_out(BLOCK1_2),
        .done         (block_done[1])
    );

    des_encrypt des2 (
        .clock       (clock),
        .rst       (rst),
        .select    (start2),
        .plaintext (BLOCK1_2),
        .key       (k2),
        .dectext   (BLOCK2_O),
        .done      (block_done[2])
    );

endmodule
