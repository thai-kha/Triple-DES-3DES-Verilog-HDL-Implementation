module des3_decrypt (
    input         clock,
    input         rst,
    input         select,        
    input  [63:0] key0,
    input  [63:0] key1,
    input  [63:0] key2,
    input  [63:0] data_in,       
    output reg [63:0] data_out,  
    output reg        done
);

    reg [63:0] k0, k1, k2;

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

    wire [63:0] block0_out;   
    wire [63:0] block1_out;   
    wire [63:0] block2_out;   

    wire [2:0]  sub_done;     

    localparam S_IDLE  = 3'd0,
               S_RUN0  = 3'd1,
               S_WAIT0 = 3'd2,
               S_RUN1  = 3'd3,
               S_WAIT1 = 3'd4,
               S_RUN2  = 3'd5,
               S_WAIT2 = 3'd6;

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
                if (sub_done[0])            
                    nstate = S_WAIT0;
            end

            S_WAIT0: begin
                start1 = 1'b1;              
                nstate = S_RUN1;
            end

            S_RUN1: begin
                if (sub_done[1])            
                    nstate = S_WAIT1;
            end

            S_WAIT1: begin
                start2 = 1'b1;              
                nstate = S_RUN2;
            end

            S_RUN2: begin
                if (sub_done[2])            
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
            state    <= S_IDLE;
            data_out <= 64'd0;
            done     <= 1'b0;
        end else begin
            state <= nstate;

            done <= (state == S_WAIT2);

            if (state == S_WAIT2)
                data_out <= block2_out;
        end
    end

    des_decrypt stage1 (
        .clock        (clock),
        .rst          (rst),
        .select       (start0),
        .ciphertext   (data_in),
        .key          (k2),
        .plaintext_out(block0_out),
        .done         (sub_done[0])
    );

    des_encrypt stage2 (
        .clock     (clock),
        .rst       (rst),
        .select    (start1),
        .plaintext (block0_out),
        .key       (k1),
        .dectext   (block1_out),
        .done      (sub_done[1])
    );

    des_decrypt stage3 (
        .clock        (clock),
        .rst          (rst),
        .select       (start2),
        .ciphertext   (block1_out),
        .key          (k0),
        .plaintext_out(block2_out),
        .done         (sub_done[2])
    );

endmodule
