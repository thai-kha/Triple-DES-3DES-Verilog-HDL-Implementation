module des3_top (
    input         clock,
    input         rst,
    input         start,          
    input  [63:0] key0,
    input  [63:0] key1,
    input  [63:0] key2,
    input  [63:0] plaintext_in,   
    
    output [63:0] ciphertext_out, 
    output [63:0] recovered_out,  
    output        done_all        
);

    wire [63:0] internal_cipher;  
    wire        encrypt_done;     

    des3_encrypt u_encrypt (
        .clock    (clock),
        .rst      (rst),
        .select   (start),          
        .key0     (key0),
        .key1     (key1),
        .key2     (key2),
        .input_data  (plaintext_in),   
        .output_data (internal_cipher),
        .done     (encrypt_done)    
    );

    des3_decrypt u_decrypt (
        .clock    (clock),
        .rst      (rst),
        .select   (encrypt_done),   
        .key0     (key0),
        .key1     (key1),
        .key2     (key2),
        .data_in  (internal_cipher), 
        .data_out (recovered_out),  
        .done     (done_all)        
    );

    assign ciphertext_out = internal_cipher;

endmodule