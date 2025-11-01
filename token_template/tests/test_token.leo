// The 'test_token' test program.
import private_token_workshop.aleo;

program test_token.aleo {
    // Test mint_private functionality (transition test - no async)
    @test
    transition test_mint_private() {
        const RECIPIENT: address = aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px;
        const AMOUNT: u64 = 50u64;
        
        // Execute mint_private
        let result: (private_token_workshop.aleo/Token, Future) = 
            private_token_workshop.aleo/mint_private(RECIPIENT, AMOUNT);
        
        // Verify the token record was created correctly
        assert_eq(result.0.owner, RECIPIENT);
        assert_eq(result.0.amount, AMOUNT);
    }

    // Test transfer_private functionality (transition test)
    @test
    transition test_transfer_private() {
        const SENDER_ADDR: address = aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px;
        const RECIPIENT: address = aleo1s3ws5tra87fjycnjrwsjcrnw2qxr8jfqqdugnf0xzqqw29q9m5pqem2u4t;
        const INITIAL_AMOUNT: u64 = 150u64;
        const TRANSFER_AMOUNT: u64 = 60u64;
        
        // First mint a token for the sender
        let mint_result: (private_token_workshop.aleo/Token, Future) = 
            private_token_workshop.aleo/mint_private(SENDER_ADDR, INITIAL_AMOUNT);
        let sender_token: private_token_workshop.aleo/Token = mint_result.0;
        
        // Execute transfer_private
        let result: (private_token_workshop.aleo/Token, private_token_workshop.aleo/Token, Future) = 
            private_token_workshop.aleo/transfer_private(sender_token, RECIPIENT, TRANSFER_AMOUNT);
        
        // Verify recipient token
        assert_eq(result.0.owner, RECIPIENT);
        assert_eq(result.0.amount, TRANSFER_AMOUNT);
        
        // Verify sender's remaining token
        assert_eq(result.1.owner, SENDER_ADDR);
        assert_eq(result.1.amount, INITIAL_AMOUNT - TRANSFER_AMOUNT);
    }

    // Test multiple transfer_private operations
    @test
    transition test_chain_transfer_private() {
        const ADDR1: address = aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px;
        const ADDR2: address = aleo1s3ws5tra87fjycnjrwsjcrnw2qxr8jfqqdugnf0xzqqw29q9m5pqem2u4t;
        const ADDR3: address = aleo1fxs9s0w97lmkwlcmgn0z3nuxufdee5yck9wqrs0umevp7qs0sg9q5xxxzh;
        const INITIAL: u64 = 300u64;
        const FIRST_TRANSFER: u64 = 100u64;
        const SECOND_TRANSFER: u64 = 50u64;
        
        // Mint initial tokens
        let mint_result: (private_token_workshop.aleo/Token, Future) = 
            private_token_workshop.aleo/mint_private(ADDR1, INITIAL);
        
        // First transfer: ADDR1 -> ADDR2
        let transfer1: (private_token_workshop.aleo/Token, private_token_workshop.aleo/Token, Future) = 
            private_token_workshop.aleo/transfer_private(mint_result.0, ADDR2, FIRST_TRANSFER);
        
        // Verify first transfer
        assert_eq(transfer1.0.owner, ADDR2);
        assert_eq(transfer1.0.amount, FIRST_TRANSFER);
        assert_eq(transfer1.1.amount, INITIAL - FIRST_TRANSFER);
        
        // Second transfer: ADDR2 -> ADDR3 (using the token received from ADDR1)
        let transfer2: (private_token_workshop.aleo/Token, private_token_workshop.aleo/Token, Future) = 
            private_token_workshop.aleo/transfer_private(transfer1.0, ADDR3, SECOND_TRANSFER);
        
        // Verify second transfer
        assert_eq(transfer2.0.owner, ADDR3);
        assert_eq(transfer2.0.amount, SECOND_TRANSFER);
        assert_eq(transfer2.1.owner, ADDR2);
        assert_eq(transfer2.1.amount, FIRST_TRANSFER - SECOND_TRANSFER);
    }

    // Test edge case: transfer all tokens
    @test
    transition test_transfer_all_private() {
        const SENDER: address = aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px;
        const RECIPIENT: address = aleo1s3ws5tra87fjycnjrwsjcrnw2qxr8jfqqdugnf0xzqqw29q9m5pqem2u4t;
        const AMOUNT: u64 = 100u64;
        
        // Mint tokens
        let mint_result: (private_token_workshop.aleo/Token, Future) = 
            private_token_workshop.aleo/mint_private(SENDER, AMOUNT);
        
        // Transfer all tokens
        let result: (private_token_workshop.aleo/Token, private_token_workshop.aleo/Token, Future) = 
            private_token_workshop.aleo/transfer_private(mint_result.0, RECIPIENT, AMOUNT);
        
        // Verify recipient gets all tokens
        assert_eq(result.0.owner, RECIPIENT);
        assert_eq(result.0.amount, AMOUNT);
        
        // Verify sender has zero remaining
        assert_eq(result.1.owner, SENDER);
        assert_eq(result.1.amount, 0u64);
    }
    
    @noupgrade
    async constructor() {}
}


