module VGA_OUT (
	input CLK,
	output reg[3:0]VGA_R, VGA_G, VGA_B,
	output reg VGA_HS, VGA_VS
);


// 水平方向の定数
parameter horz_a = 96; // サイクル
parameter horz_b = 48;
parameter horz_c = 640;
parameter horz_d = 16;

parameter horz_max = horz_a + horz_b + horz_c + horz_d;
parameter width = horz_c;

parameter h_sync_start = horz_d;
parameter h_sync_end = horz_d + horz_a;


// 垂直方向の定数
parameter vert_a = 2; // サイクル
parameter vert_b = 33;
parameter vert_c = 480;
parameter vert_d = 10;

parameter vert_max = vert_a + vert_b + vert_c + vert_d;
parameter height = vert_c;




/*
	VGAは25MHzで駆動する. CLKは50MHzなので, 半周期のクロックを生成している.
*/
reg VGA_CLK; // VGA用のClock
always @(posedge CLK) begin
	VGA_CLK = ~VGA_CLK;
end

/*
	縦×横=800*525を使う. 800は2進数では1100100000なので, 10桁必要となる.
*/
reg[9:0] cnt_v = 10'b0; // 縦
reg[9:0] cnt_h = 10'b0; // 横

/*
	水平・垂直走査信号をカウント
*/
always@(negedge VGA_CLK) begin
	if (cnt_h < horz_max)
		cnt_h <= cnt_h + 1;
	else begin
		cnt_h <= 10'd0;
		if (cnt_v < vert_max)
			cnt_v <= cnt_v + 1;
		else
			cnt_v <= 10'd0;
	end
end

/*
	水平同期信号
*/
always @(posedge VGA_CLK) begin
	if(cnt_h == 16)
		VGA_HS = 1'b0;
	else if (cnt_h == 16 + 96)
		VGA_HS = 1'b1;
end

/*
	垂直同期信号
*/
always @(posedge VGA_CLK) begin
	if(cnt_h == 16) begin
		if(cnt_v == 10)
			VGA_VS = 1'b0;      
		else if(cnt_v == 10 + 2)
			VGA_VS = 1'b1;
	end
end


always @(posedge VGA_CLK) begin
	if (cnt_h < 96 + 48 + 16 || cnt_v < 2 + 33 + 10) begin
		VGA_R <= 4'b0000;
		VGA_G <= 4'b1111;
		VGA_B <= 4'b0000;
	end
	else begin
		VGA_R <= 4'b1111;
		VGA_G <= 4'b0000;
		VGA_B <= 4'b0000;
	end
end

endmodule
