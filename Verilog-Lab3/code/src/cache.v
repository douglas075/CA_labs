module Cache #(
    parameter BIT_W = 32,
    parameter ADDR_W = 32
)(
    input               i_clk,
    input               i_rst_n,

    // Processor Interface
    input               i_proc_cen,
    input               i_proc_wen,
    input  [ADDR_W-1:0] i_proc_addr,
    input  [BIT_W-1:0]  i_proc_wdata,
    output [BIT_W-1:0]  o_proc_rdata,
    output              o_proc_stall,
    input               i_proc_finish,
    output              o_cache_finish,

    // Memory Interface
    output reg              o_mem_cen,
    output reg              o_mem_wen,
    output reg [ADDR_W-1:0] o_mem_addr,
    output reg [BIT_W*4-1:0] o_mem_wdata,
    input      [BIT_W*4-1:0] i_mem_rdata,
    input                    i_mem_stall,

    output                   o_cache_available,
    input      [ADDR_W-1:0]  i_offset
);

    assign o_cache_available = 1;

    // ============================================================
    // Parameters (Area Reduced)
    // ============================================================
    // Reduced from 16 sets to 4 sets to save Flip-Flop Area
    localparam SETS    = 4; 
    localparam INDEX_W = 2; // log2(4) = 2
    localparam TAG_W   = 32 - 2 - 2 - INDEX_W; // 32 - 4 - 2 = 26 bits

    // ============================================================
    // Address Decode (Dynamic / Soft-coded)
    // ============================================================
    wire [1:0]         word_offset = i_proc_addr[3:2];
    
    // Dynamically calculate index and tag ranges based on INDEX_W
    // Index starts at bit 4. Ends at 4 + INDEX_W - 1.
    wire [INDEX_W-1:0] raw_index   = i_proc_addr[INDEX_W+3 : 4];
    // Tag starts after index.
    wire [TAG_W-1:0]   tag         = i_proc_addr[31 : INDEX_W+4];

    // Skewed Indices
    wire [INDEX_W-1:0] idx0 = raw_index;
    // XOR the index with the lowest bits of the tag (width matches INDEX_W)
    wire [INDEX_W-1:0] idx1 = raw_index ^ tag[INDEX_W-1:0];

    // ============================================================
    // Storage
    // ============================================================
    reg [127:0]     data_way0 [0:SETS-1];
    reg [TAG_W-1:0] tag_way0  [0:SETS-1];
    reg             valid_way0[0:SETS-1];
    reg             dirty_way0[0:SETS-1];

    reg [127:0]     data_way1 [0:SETS-1];
    reg [TAG_W-1:0] tag_way1  [0:SETS-1];
    reg             valid_way1[0:SETS-1];
    reg             dirty_way1[0:SETS-1];

    reg             lru_bit   [0:SETS-1];

    integer i;

    // ============================================================
    // Hit Detection
    // ============================================================
    wire hit0 = valid_way0[idx0] && (tag_way0[idx0] == tag);
    wire hit1 = valid_way1[idx1] && (tag_way1[idx1] == tag);
    wire hit  = hit0 | hit1;

    wire [127:0] block_out = hit0 ? data_way0[idx0] : 
                             hit1 ? data_way1[idx1] : 128'b0;

    assign o_proc_rdata = (word_offset == 0) ? block_out[31:0] :
                          (word_offset == 1) ? block_out[63:32] :
                          (word_offset == 2) ? block_out[95:64] :
                                               block_out[127:96];

    assign o_proc_stall = i_proc_cen && !hit;

    // ============================================================
    // FSM States
    // ============================================================
    localparam S_IDLE  = 0,
               S_ALLOC = 1,
               S_WB    = 2,
               S_DRAIN = 3,
               S_DONE  = 4;

    reg [2:0] state, next_state;

    // ============================================================
    // Victim selection & Helpers
    // ============================================================
    reg victim_way;
    always @(*) begin
        if (!valid_way0[idx0])      victim_way = 0;
        else if (!valid_way1[idx1]) victim_way = 1;
        else                        victim_way = lru_bit[idx0];
    end

    wire victim_dirty = (victim_way == 0) ? dirty_way0[idx0] : dirty_way1[idx1];
    
    // Dynamic Skew calculation for victim reconstruction
    wire [INDEX_W-1:0] victim_skew_idx = idx1 ^ tag_way1[idx1][INDEX_W-1:0];

    // Drain Iterator Helpers
    reg draining;
    reg [INDEX_W-1:0] drain_index;
    reg drain_way; // 0->Way0, 1->Way1
    
    // Dynamic Skew calculation for drain reconstruction
    wire [INDEX_W-1:0] drain_skew_idx = drain_index ^ tag_way1[drain_index][INDEX_W-1:0];

    // ----------------------------------------------------------------
    // ALIGNMENT FIX HELPER
    // ----------------------------------------------------------------
    // Reconstruct full address to compare against i_offset
    wire [31:0] full_addr_start = {tag, raw_index, 4'b0000};
    
    // If address is clamped, shift data to align with cache block
    wire [127:0] aligned_data = (full_addr_start < i_offset) ? 
                                ( (i_offset[3:2]==2'b01) ? i_mem_rdata << 32 :
                                  (i_offset[3:2]==2'b10) ? i_mem_rdata << 64 :
                                  (i_offset[3:2]==2'b11) ? i_mem_rdata << 96 : i_mem_rdata ) 
                                : i_mem_rdata;

    // ============================================================
    // Next State Logic
    // ============================================================
    
    wire drain_dirty0 = dirty_way0[drain_index];
    wire drain_dirty1 = dirty_way1[drain_index];

    always @(*) begin
        case (state)
            S_IDLE: begin
                if (i_proc_finish)
                    next_state = S_DRAIN;
                else if (i_proc_cen && !hit)
                    next_state = victim_dirty ? S_WB : S_ALLOC;
                else
                    next_state = S_IDLE;
            end
            
            S_ALLOC: next_state = i_mem_stall ? S_ALLOC : S_IDLE;
            
            S_WB:    next_state = i_mem_stall ? S_WB : (draining ? S_DRAIN : S_ALLOC);
            
            S_DRAIN: begin
                if (drain_way == 0 && drain_dirty0)
                    next_state = S_WB;
                else if (drain_way == 1 && drain_dirty1)
                    next_state = S_WB;
                else begin
                    if (drain_way == 0)             next_state = S_DRAIN;
                    else if (drain_index == SETS-1) next_state = S_DONE;
                    else                            next_state = S_DRAIN;
                end
            end
            
            S_DONE:  next_state = S_DONE;
            default: next_state = S_IDLE;
        endcase
    end

    assign o_cache_finish = (state == S_DONE);
    reg curr_dirty; 

    // ============================================================
    // Sequential Logic
    // ============================================================
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state <= S_IDLE;
            draining <= 0;
            drain_index <= 0;
            drain_way <= 0;
            for (i = 0; i < SETS; i = i + 1) begin
                valid_way0[i] <= 0; dirty_way0[i] <= 0;
                valid_way1[i] <= 0; dirty_way1[i] <= 0;
                lru_bit[i]    <= 0;
            end
        end else begin
            state <= next_state;

            // Start Drain
            if (state == S_IDLE && i_proc_finish) begin
                draining <= 1;
                drain_index <= 0;
                drain_way   <= 0;
            end

            // ----------------------------------------------------
            // DRAIN ITERATOR (Advance only if clean)
            // ----------------------------------------------------
            if (state == S_DRAIN) begin
                if (drain_way == 0) curr_dirty = dirty_way0[drain_index];
                else                curr_dirty = dirty_way1[drain_index];

                if (!curr_dirty) begin
                    if (drain_way == 0) begin
                        drain_way <= 1;
                    end else begin
                        drain_way <= 0;
                        if (drain_index < SETS-1) drain_index <= drain_index + 1;
                    end
                end
            end

            // ------------------------------
            // WRITE HIT
            // ------------------------------
            if (state == S_IDLE && i_proc_cen && i_proc_wen && hit) begin
                if (hit0) begin
                    dirty_way0[idx0] <= 1;
                    lru_bit[idx0]    <= 1;
                    case (word_offset)
                        0: data_way0[idx0][31:0]   <= i_proc_wdata;
                        1: data_way0[idx0][63:32]  <= i_proc_wdata;
                        2: data_way0[idx0][95:64]  <= i_proc_wdata;
                        3: data_way0[idx0][127:96] <= i_proc_wdata;
                    endcase
                end else begin
                    dirty_way1[idx1] <= 1;
                    lru_bit[idx0]    <= 0;
                    case (word_offset)
                        0: data_way1[idx1][31:0]   <= i_proc_wdata;
                        1: data_way1[idx1][63:32]  <= i_proc_wdata;
                        2: data_way1[idx1][95:64]  <= i_proc_wdata;
                        3: data_way1[idx1][127:96] <= i_proc_wdata;
                    endcase
                end
            end

            // ------------------------------
            // REFILL (ALLOC)
            // ------------------------------
            if (state == S_ALLOC && !i_mem_stall) begin
                if (victim_way == 0) begin
                    valid_way0[idx0] <= 1;
                    dirty_way0[idx0] <= 0;
                    tag_way0[idx0]   <= tag;
                    data_way0[idx0]  <= aligned_data; 
                    lru_bit[idx0]    <= 1;
                end else begin
                    valid_way1[idx1] <= 1;
                    dirty_way1[idx1] <= 0;
                    tag_way1[idx1]   <= tag;
                    data_way1[idx1]  <= aligned_data;
                    lru_bit[idx0]    <= 0;
                end
            end

            // ------------------------------
            // CLEAR DIRTY BIT (After Writeback)
            // ------------------------------
            if (state == S_WB && !i_mem_stall && draining) begin
                if (drain_way == 0) dirty_way0[drain_index] <= 0;
                else                dirty_way1[drain_index] <= 0;
            end
        end
    end

    // ============================================================
    // Memory Interface Output
    // ============================================================
    always @(*) begin
        o_mem_cen   = 0;
        o_mem_wen   = 0;
        o_mem_addr  = 0;
        o_mem_wdata = 0;

        case (state)
            S_ALLOC: begin
                o_mem_cen = 1;
                o_mem_wen = 0;
                // Clamp address if below offset
                if ({tag, raw_index, 4'b0000} < i_offset)
                    o_mem_addr = i_offset;
                else
                    o_mem_addr = {tag, raw_index, 4'b0000};
            end

            S_WB: begin
                o_mem_cen = 1;
                o_mem_wen = 1;
                if (!draining) begin
                    // Normal Eviction
                    if (victim_way == 0) begin
                        o_mem_addr  = {tag_way0[idx0], idx0, 4'b0000};
                        o_mem_wdata = data_way0[idx0];
                    end else begin
                        o_mem_addr  = {tag_way1[idx1], victim_skew_idx, 4'b0000};
                        o_mem_wdata = data_way1[idx1];
                    end
                end else begin
                    // Draining
                    if (drain_way == 0) begin
                        o_mem_addr  = {tag_way0[drain_index], drain_index, 4'b0000};
                        o_mem_wdata = data_way0[drain_index];
                    end else begin
                        o_mem_addr  = {tag_way1[drain_index], drain_skew_idx, 4'b0000};
                        o_mem_wdata = data_way1[drain_index];
                    end
                end
            end
        endcase
    end

endmodule