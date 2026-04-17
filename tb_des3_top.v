`timescale 1ns / 1ps

module tb_des3_top;

    reg          clock;
    reg          rst;
    reg          start;
    reg  [63:0]  key0, key1, key2;
    reg  [63:0]  plaintext_in;

    wire [63:0]  ciphertext_out;
    wire [63:0]  recovered_out;
    wire         done_all;

    des3_top uut (
        .clock          (clock),
        .rst            (rst),
        .start          (start),
        .key0           (key0),
        .key1           (key1),
        .key2           (key2),
        .plaintext_in   (plaintext_in),
        .ciphertext_out (ciphertext_out),
        .recovered_out  (recovered_out),
        .done_all       (done_all)
    );

    initial clock = 1'b0;
    always #5 clock = ~clock;

    integer pass_count;
    integer fail_count;
    integer test_num;

    task run_test;
        input [63:0] t_key0;
        input [63:0] t_key1;
        input [63:0] t_key2;
        input [63:0] t_plain;
        input [63:0] exp_cipher;   
        input [255:0] test_name;   

        reg loopback_ok;
        reg cipher_ok;
        begin
            test_num = test_num + 1;

            key0         = t_key0;
            key1         = t_key1;
            key2         = t_key2;
            plaintext_in = t_plain;

            @(posedge clock);
            @(posedge clock);

            start = 1'b1;
            @(posedge clock);
            start = 1'b0;

            @(posedge done_all);
            @(posedge clock);   

            loopback_ok = (recovered_out === t_plain);
            cipher_ok   = (exp_cipher == 64'h0) ? 1'b1 : (ciphertext_out === exp_cipher);

            $display("=============================================================");
            $display("  Test #%0d : %0s", test_num, test_name);
            $display("-------------------------------------------------------------");
            $display("  Key 0       = %016H", t_key0);
            $display("  Key 1       = %016H", t_key1);
            $display("  Key 2       = %016H", t_key2);
            $display("  Plaintext   = %016H", t_plain);
            $display("  Ciphertext  = %016H", ciphertext_out);
            $display("  Recovered   = %016H", recovered_out);
            $display("-------------------------------------------------------------");

            if (loopback_ok)
                $display("  Loopback    : PASS  (recovered == plaintext)");
            else begin
                $display("  Loopback    : FAIL  (expected %016H)", t_plain);
            end

            if (exp_cipher != 64'h0) begin
                if (cipher_ok)
                    $display("  Cipher Check: PASS  (matches expected %016H)", exp_cipher);
                else
                    $display("  Cipher Check: FAIL  (expected %016H)", exp_cipher);
            end else begin
                $display("  Cipher Check: SKIPPED");
            end

            if (loopback_ok && cipher_ok) begin
                $display("  >> PASS <<");
                pass_count = pass_count + 1;
            end else begin
                $display("  >> FAIL <<");
                fail_count = fail_count + 1;
            end
            $display("=============================================================\n");

            repeat (5) @(posedge clock);
        end
    endtask

    initial begin
        rst          = 1'b1;
        start        = 1'b0;
        key0         = 64'd0;
        key1         = 64'd0;
        key2         = 64'd0;
        plaintext_in = 64'd0;
        pass_count   = 0;
        fail_count   = 0;
        test_num     = 0;

        repeat (5) @(posedge clock);
        rst = 1'b0;
        repeat (3) @(posedge clock);

        $display("\n");
        $display("*************************************************************");
        $display("*        Triple DES (3DES) — Comprehensive Testbench        *");
        $display("*              Encrypt -> Decrypt Verification              *");
        $display("*************************************************************\n");

        run_test(
            64'h0000000000000000,    
            64'h0000000000000000,    
            64'h0000000000000000,    
            64'h0000000000000000,    
            64'h8CA64DE9C1B123A7,    
            "All-Zero Known-Answer"
        );

        run_test(
            64'h0123456789ABCDEF,    
            64'h23456789ABCDEF01,    
            64'h456789ABCDEF0123,   
            64'h4E6F772069732074,   
            64'h0,                   
            "NIST SP800-67 Keys #1"
        );

        run_test(
            64'h0123456789ABCDEF,
            64'h23456789ABCDEF01,
            64'h456789ABCDEF0123,
            64'h6B2062726F776E20,   
            64'h0,
            "NIST SP800-67 Keys #2"
        );

        run_test(
            64'h0123456789ABCDEF,
            64'h23456789ABCDEF01,
            64'h456789ABCDEF0123,
            64'h666F78206A756D70,   
            64'h0,
            "NIST SP800-67 Keys #3"
        );

        run_test(
            64'hFFFFFFFFFFFFFFFF,
            64'hFFFFFFFFFFFFFFFF,
            64'hFFFFFFFFFFFFFFFF,
            64'hFFFFFFFFFFFFFFFF,
            64'h7359B2163E4EDC58,   
            "All-Ones Known-Answer"
        );

        run_test(
            64'hAAAAAAAAAAAAAAAA,
            64'h5555555555555555,
            64'hAAAAAAAAAAAAAAAA,
            64'h0123456789ABCDEF,
            64'h0,
            "Alternating Bit Keys"
        );

        run_test(
            64'h0123456789ABCDEF,
            64'hFEDCBA9876543210,
            64'h0123456789ABCDEF,
            64'h1122334455667788,
            64'h0,
            "2-Key 3DES (K0==K2)"
        );

        run_test(
            64'hFEDCBA9876543210,
            64'h1234567890ABCDEF,
            64'hABCDEF0123456789,
            64'hCAFEBABEDEADBEEF,
            64'h0,
            "Random Pattern #1"
        );

        run_test(
            64'h1111111111111111,
            64'h2222222222222222,
            64'h3333333333333333,
            64'h8000000000000000,
            64'h0,
            "Walking Ones"
        );

        run_test(
            64'hA5A5A5A5A5A5A5A5,
            64'h5A5A5A5A5A5A5A5A,
            64'hF0F0F0F00F0F0F0F,
            64'h0F1E2D3C4B5A6978,
            64'h0,
            "Stress Pattern"
        );

        $display("\n");
        $display("*************************************************************");
        $display("*  Total Tests  : %0d", pass_count + fail_count);
        $display("*  Passed       : %0d", pass_count);
        $display("*  Failed       : %0d", fail_count);
        $display("*************************************************************");

        if (fail_count == 0)
            $display("*            >>> ALL TESTS PASSED <<<                       *");
        else
            $display("*            >>> SOME TESTS FAILED <<<                      *");

        $display("*************************************************************\n");
        $finish;
    end

    initial begin
        #200000;
        $display("\n");
        $display("  !! ERROR : Simulation timed out after 200 us !!");
        $display("  !! Check FSM handshaking or clock connectivity. !!\n");
        $finish;
    end

endmodule
