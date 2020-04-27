onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_frame_extender/DUT/video_i/aclk
add wave -noupdate /tb_frame_extender/DUT/video_i/aresetn
add wave -noupdate /tb_frame_extender/DUT/video_i/tvalid
add wave -noupdate /tb_frame_extender/DUT/video_i/tready
add wave -noupdate /tb_frame_extender/DUT/video_i/tdata
add wave -noupdate /tb_frame_extender/DUT/video_i/tstrb
add wave -noupdate /tb_frame_extender/DUT/video_i/tkeep
add wave -noupdate /tb_frame_extender/DUT/video_i/tlast
add wave -noupdate /tb_frame_extender/DUT/video_i/tid
add wave -noupdate /tb_frame_extender/DUT/video_i/tdest
add wave -noupdate /tb_frame_extender/DUT/video_i/tuser
add wave -noupdate /tb_frame_extender/DUT/extended_video/aclk
add wave -noupdate /tb_frame_extender/DUT/extended_video/aresetn
add wave -noupdate /tb_frame_extender/DUT/extended_video/tvalid
add wave -noupdate /tb_frame_extender/DUT/extended_video/tready
add wave -noupdate /tb_frame_extender/DUT/extended_video/tdata
add wave -noupdate /tb_frame_extender/DUT/extended_video/tstrb
add wave -noupdate /tb_frame_extender/DUT/extended_video/tkeep
add wave -noupdate /tb_frame_extender/DUT/extended_video/tlast
add wave -noupdate /tb_frame_extender/DUT/extended_video/tid
add wave -noupdate /tb_frame_extender/DUT/extended_video/tdest
add wave -noupdate /tb_frame_extender/DUT/extended_video/tuser
add wave -noupdate /tb_frame_extender/DUT/eof_video/aclk
add wave -noupdate /tb_frame_extender/DUT/eof_video/aresetn
add wave -noupdate /tb_frame_extender/DUT/eof_video/tvalid
add wave -noupdate /tb_frame_extender/DUT/eof_video/tready
add wave -noupdate /tb_frame_extender/DUT/eof_video/tdata
add wave -noupdate /tb_frame_extender/DUT/eof_video/tstrb
add wave -noupdate /tb_frame_extender/DUT/eof_video/tkeep
add wave -noupdate /tb_frame_extender/DUT/eof_video/tlast
add wave -noupdate /tb_frame_extender/DUT/eof_video/tid
add wave -noupdate /tb_frame_extender/DUT/eof_video/tdest
add wave -noupdate /tb_frame_extender/DUT/eof_video/tuser
add wave -noupdate /tb_frame_extender/DUT/clk_i
add wave -noupdate /tb_frame_extender/DUT/rst_i
add wave -noupdate /tb_frame_extender/DUT/eof
add wave -noupdate /tb_frame_extender/DUT/dup_req
add wave -noupdate /tb_frame_extender/DUT/flush_fifo
add wave -noupdate /tb_frame_extender/DUT/top_cnt
add wave -noupdate /tb_frame_extender/DUT/bot_cnt
add wave -noupdate /tb_frame_extender/DUT/eof_video_tready
add wave -noupdate /tb_frame_extender/DUT/eof_video_tvalid
add wave -noupdate /tb_frame_extender/DUT/first_eol
add wave -noupdate /tb_frame_extender/DUT/last_eol
add wave -noupdate /tb_frame_extender/DUT/pop_dup_top
add wave -noupdate /tb_frame_extender/DUT/pop_dup_bot
add wave -noupdate /tb_frame_extender/DUT/passthrough_en
add wave -noupdate /tb_frame_extender/DUT/line_buf_empty
add wave -noupdate /tb_frame_extender/DUT/state
add wave -noupdate /tb_frame_extender/DUT/next_state
add wave -noupdate /tb_frame_extender/DUT/duplicated_video/aclk
add wave -noupdate /tb_frame_extender/DUT/duplicated_video/aresetn
add wave -noupdate /tb_frame_extender/DUT/duplicated_video/tvalid
add wave -noupdate /tb_frame_extender/DUT/duplicated_video/tready
add wave -noupdate /tb_frame_extender/DUT/duplicated_video/tdata
add wave -noupdate /tb_frame_extender/DUT/duplicated_video/tstrb
add wave -noupdate /tb_frame_extender/DUT/duplicated_video/tkeep
add wave -noupdate /tb_frame_extender/DUT/duplicated_video/tlast
add wave -noupdate /tb_frame_extender/DUT/duplicated_video/tid
add wave -noupdate /tb_frame_extender/DUT/duplicated_video/tdest
add wave -noupdate /tb_frame_extender/DUT/duplicated_video/tuser
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/clk_i
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/rst_i
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/pop_line_i
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/flush_line_i
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/empty_o
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/unread_o
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/tdata_d1
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/tvalid_d1
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/tlast_d1
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/tuser_d1
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/wr_ptr
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/line_size
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/rd_ptr
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/read_in_progress
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/empty
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/was_sof
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/unread
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/rd_req
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/line_locked
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/line_locked_d1
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/buf_data
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/rd_mem
add wave -noupdate /tb_frame_extender/DUT/duplicate_buf/wr_mem
add wave -noupdate /tb_frame_extender/DUT/eof_video_to_line_buf/aclk
add wave -noupdate /tb_frame_extender/DUT/eof_video_to_line_buf/aresetn
add wave -noupdate /tb_frame_extender/DUT/eof_video_to_line_buf/tvalid
add wave -noupdate /tb_frame_extender/DUT/eof_video_to_line_buf/tready
add wave -noupdate /tb_frame_extender/DUT/eof_video_to_line_buf/tdata
add wave -noupdate /tb_frame_extender/DUT/eof_video_to_line_buf/tstrb
add wave -noupdate /tb_frame_extender/DUT/eof_video_to_line_buf/tkeep
add wave -noupdate /tb_frame_extender/DUT/eof_video_to_line_buf/tlast
add wave -noupdate /tb_frame_extender/DUT/eof_video_to_line_buf/tid
add wave -noupdate /tb_frame_extender/DUT/eof_video_to_line_buf/tdest
add wave -noupdate /tb_frame_extender/DUT/eof_video_to_line_buf/tuser
add wave -noupdate /tb_frame_extender/DUT/passthrough_video/aclk
add wave -noupdate /tb_frame_extender/DUT/passthrough_video/aresetn
add wave -noupdate /tb_frame_extender/DUT/passthrough_video/tvalid
add wave -noupdate /tb_frame_extender/DUT/passthrough_video/tready
add wave -noupdate /tb_frame_extender/DUT/passthrough_video/tdata
add wave -noupdate /tb_frame_extender/DUT/passthrough_video/tstrb
add wave -noupdate /tb_frame_extender/DUT/passthrough_video/tkeep
add wave -noupdate /tb_frame_extender/DUT/passthrough_video/tlast
add wave -noupdate /tb_frame_extender/DUT/passthrough_video/tid
add wave -noupdate /tb_frame_extender/DUT/passthrough_video/tdest
add wave -noupdate /tb_frame_extender/DUT/passthrough_video/tuser
add wave -noupdate /tb_frame_extender/video_o/aclk
add wave -noupdate /tb_frame_extender/video_o/aresetn
add wave -noupdate /tb_frame_extender/video_o/tvalid
add wave -noupdate /tb_frame_extender/video_o/tready
add wave -noupdate /tb_frame_extender/video_o/tdata
add wave -noupdate /tb_frame_extender/video_o/tstrb
add wave -noupdate /tb_frame_extender/video_o/tkeep
add wave -noupdate /tb_frame_extender/video_o/tlast
add wave -noupdate /tb_frame_extender/video_o/tid
add wave -noupdate /tb_frame_extender/video_o/tdest
add wave -noupdate /tb_frame_extender/video_o/tuser
add wave -noupdate /tb_frame_extender/DUT/input_fifo/clk_i
add wave -noupdate /tb_frame_extender/DUT/input_fifo/rst_i
add wave -noupdate /tb_frame_extender/DUT/input_fifo/full_o
add wave -noupdate /tb_frame_extender/DUT/input_fifo/empty_o
add wave -noupdate /tb_frame_extender/DUT/input_fifo/drop_o
add wave -noupdate /tb_frame_extender/DUT/input_fifo/used_words_o
add wave -noupdate /tb_frame_extender/DUT/input_fifo/pkts_amount_o
add wave -noupdate /tb_frame_extender/DUT/input_fifo/pkt_size_o
add wave -noupdate /tb_frame_extender/DUT/input_fifo/wr_data
add wave -noupdate /tb_frame_extender/DUT/input_fifo/rd_data
add wave -noupdate /tb_frame_extender/DUT/input_fifo/wr_addr
add wave -noupdate /tb_frame_extender/DUT/input_fifo/wr_req
add wave -noupdate /tb_frame_extender/DUT/input_fifo/full
add wave -noupdate /tb_frame_extender/DUT/input_fifo/full_comb
add wave -noupdate /tb_frame_extender/DUT/input_fifo/rd_addr
add wave -noupdate /tb_frame_extender/DUT/input_fifo/rd_req
add wave -noupdate /tb_frame_extender/DUT/input_fifo/used_words
add wave -noupdate /tb_frame_extender/DUT/input_fifo/used_words_comb
add wave -noupdate /tb_frame_extender/DUT/input_fifo/pkt_cnt
add wave -noupdate /tb_frame_extender/DUT/input_fifo/pkt_word_cnt
add wave -noupdate /tb_frame_extender/DUT/input_fifo/pkt_word_cnt_m1
add wave -noupdate /tb_frame_extender/DUT/input_fifo/pkt_word_cnt_p1
add wave -noupdate /tb_frame_extender/DUT/input_fifo/pkt_word_cnt_p2
add wave -noupdate /tb_frame_extender/DUT/input_fifo/rd_en
add wave -noupdate /tb_frame_extender/DUT/input_fifo/data_in_ram
add wave -noupdate /tb_frame_extender/DUT/input_fifo/data_in_o_reg
add wave -noupdate /tb_frame_extender/DUT/input_fifo/svrl_w_in_mem
add wave -noupdate /tb_frame_extender/DUT/input_fifo/first_word
add wave -noupdate /tb_frame_extender/DUT/input_fifo/wr_pkt_done
add wave -noupdate /tb_frame_extender/DUT/input_fifo/rd_pkt_done
add wave -noupdate /tb_frame_extender/DUT/input_fifo/drop_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 728
configure wave -valuecolwidth 147
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1457691977 ps}
