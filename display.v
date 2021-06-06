module VGA_OUT (
	input  CLK,
	output reg[3:0]VGA_R, VGA_G, VGA_B,
	output reg VGA_HS, VGA_VS
);

parameter H_FRONT   = 16;
parameter H_SYNC    = 96;
parameter H_BACK    = 48;
parameter H_DISPLAY = 640;

parameter V_FRONT   = 10;
parameter V_SYNC    = 2;
parameter V_BACK    = 33;
parameter V_DISPLAY = 480;

parameter H_SYNC_START = H_FRONT;
parameter H_SYNC_END   = H_FRONT + H_SYNC;
parameter H_MAX        = H_FRONT + H_SYNC + H_BACK + H_DISPLAY - 1;

parameter V_SYNC_START = V_FRONT;
parameter V_SYNC_END   = V_FRONT + V_SYNC;
parameter V_MAX        = V_FRONT + V_SYNC + V_BACK + V_DISPLAY - 1;


// VGAは25MHzで駆動する. CLKは50MHzなので, 半周期のクロックを生成している.

reg VGA_CLK; // VGA用のClock

always @(posedge CLK) begin
	VGA_CLK = ~VGA_CLK;
end


// 縦×横=800*525を使う. 800は2進数では1100100000なので, 10桁必要となる.

reg[9:0] cnt_h = 10'b0; // 横
reg[9:0] cnt_v = 10'b0; // 縦


// 水平・垂直走査信号をカウント

always@(negedge VGA_CLK) begin
	if (cnt_h < H_MAX)
		cnt_h <= cnt_h + 1;
	else begin
		cnt_h <= 10'd0;
		if (cnt_v < V_MAX)
			cnt_v <= cnt_v + 1;
		else
			cnt_v <= 10'd0;
	end
end


// 水平同期信号

always @(posedge VGA_CLK) begin
	if (cnt_h == H_SYNC_START)
		VGA_HS = 1'b0;
	if (cnt_h == H_SYNC_END)
		VGA_HS = 1'b1;
end


// 垂直同期信号

always @(posedge VGA_CLK) begin
	if (cnt_v == V_SYNC_START)
		VGA_VS = 1'b0;
	if (cnt_v == V_SYNC_END)
		VGA_VS = 1'b1;
end


// 色付け

always @(posedge VGA_CLK) begin
	if (cnt_h < H_MAX - H_DISPLAY || cnt_v < V_MAX - V_DISPLAY) begin
		// 非表示領域
		VGA_R <= 4'b0000;
		VGA_G <= 4'b0000;
		VGA_B <= 4'b0000;
	end
	else begin
		VGA_R <= 4'b0000;
		VGA_G <= 4'b1111;
		VGA_B <= 4'b0000;
	end
end

endmodule
