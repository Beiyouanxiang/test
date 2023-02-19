module decode_top(
    input wire clk_in,
    input wire rst_n,
    input wire [63:0] data_in,
    
    output wire clk_384,
    output wire clk_192,
    output wire locked,

    output reg [23:0] pixel0_fin,
    output reg [23:0] pixel1_fin,
    output reg [23:0] pixel2_fin,
    output reg [23:0] pixel3_fin,
    output reg [23:0] pixel4_fin,
    output reg [23:0] pixel5_fin,
    output reg [23:0] pixel6_fin,
    output reg [23:0] pixel7_fin,
    output reg pic_test
//��Ҫ�����������̣����Զ��˷��˼���ʱ���Լ������Ƿ���ȷ
//i��j�����ţ�������޸ġ�
//i jû���õ���������Ҫ������
//9.15

);

  pll_0 u0_pll_0
   (
    // Clock out ports
    .clk_out1(clk_384),     // output clk_out1
    .clk_out2(clk_192),     // output clk_out2
    // Status and control signals
    .reset(~rst_n), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(clk_in));      // input clk_in1




//�Ҳ�֪����������û��vs��hs��deŶ
//***************************ͷ����Щ����
//wire [63:0] data_in_0;
//always @(posedge clk_in or negedge rst_n )
//begin
//    if (~rst_n)
//    begin
//        data_in <= 0;//�Ҳ�֪����û��vs��hs��de
//    end
//    else
//    begin
//        data_in_0 <= data_in;
//    end
//end


//���У�һ��ʱ��һ������
//parameter cnt_flag = 8'd64 ;
//reg [3:0] data_cnt0;//������64�����ݷֿ�
//always @(posedge clk_in or negedge rst_n)
//begin
//    if (~rst_n)
//    begin
//        data_cnt0 <= 0;
//    end
//    else
//    begin
//        data_cnt0 <= data_cnt0 + 1;
//    end
//end




//Ҫ�������������ķ�ʽ,�������ɣ�������ô����������ת��Ϊ64λ���н�
//����һ��ʱ��һ��64λ����
//���������ֱ�������ݣ������Ǽ��м���
reg [63:0] data_cut;
always @(posedge clk_in or negedge rst_n )
begin
    if (~rst_n)
    begin
        data_cut <= 0;
    end
    else
    begin
        data_cut <= data_in;//ÿһ��ʱ�Ӷ��������͸�data_cut
    end
end

//�õ�ȡ������������ǵڼ����У��ڼ�����
reg [7:0] i = 0;
reg [9:0] j = 0;//��i���У���j����720x1560;720/4;1560/2//����Ŀǰû���õ�
always @(posedge clk_in or negedge rst_n )
begin
    if (~rst_n)
    begin
        i <= 0;
    end
    else
    begin
        i <= i+1;
    end
end
always @(posedge clk_in or negedge rst_n )
begin
    if (~rst_n)
    begin
        j <= 0;
    end
    else
    begin
        if (i == 8'd179)
        begin
            j <= j+1;
            i <= 0;
        end
        else
            j <= j;
    end
end
always @(posedge clk_in or negedge rst_n )
begin
    if (~rst_n)
    begin
        j <= 0;
    end
    else
    begin
        if (j == 10'd779)
        begin
            i <= 0;
            j <= 0;
        end
        else
            i <= i;
            j <= j;
    end
end//������дһ��

reg [1:0] sig_flag [7:0] [9:0];//�и��־λ
reg [63:0] data_single [7:0] [9:0];//�и�������
always @(posedge clk_in or negedge rst_n )
begin
    if (~rst_n) 
    begin
        data_single [i][j] <= 0;
    end
    else
        data_single [i][j] <= data_cut;
        sig_flag [i] [j] <= 1;
end//Ҳ���ǰ�����д�����������ά����
//reg [63:0] data_in_0[0:1];
//assign data_cnt[i];
wire sig_flag_0;
assign sig_flag_0 = sig_flag [i] [j];
//�ж��������ֱ���
wire [63:0] data_dec;//decide���ݵĵ�һ��head����
assign data_dec = data_single [i][j];//assign��߲���Ӧ����wire��,OK��

wire [1:0] dec_head1;
assign dec_head1 = data_dec[63:62];//detective

reg SP_flag;
reg IC_flag;
reg SP2_flag;
reg HPTC_flag;
reg i_out_SP;
reg j_out_SP;
reg i_out_IC;
reg j_out_IC;//ÿһ��2x4�����λ��
reg i_out_SP2;
reg j_out_SP2;
reg i_out_HPTC;
reg j_out_HPTC;
reg [63:0] data_SP;
reg [63:0] data_IC;
reg [63:0] data_SP2;
reg [63:0] data_HPTC;




//flag�źź�selƬѡ�ź�����ȫһ���ģ�����ֻ��һ��flag�ź�

always @(posedge clk_in or negedge rst_n)
begin
    if (~rst_n)
    begin
        SP_flag <= 0;
        IC_flag <= 0;
        SP2_flag <= 0;
        HPTC_flag <= 0;

    end
    else if(sig_flag_0)
    case (dec_head1)
        2'b00:  begin
            SP_flag <= 1;
            IC_flag <= 0;
            SP2_flag <= 0;
            HPTC_flag <= 0;
            i_out_SP <= i;
            j_out_SP <= j;
            data_SP <= data_dec;



                end
        2'b01:  begin
            SP_flag <= 0;
            IC_flag <= 1;
            SP2_flag <= 0;
            HPTC_flag <= 0;
            i_out_IC <= i;
            j_out_IC <= j;
            data_IC <= data_dec;

                end
        2'b10:  begin
                SP_flag <= 0;
                IC_flag <= 0;
                SP2_flag <= 1;
                HPTC_flag <= 0;
                i_out_SP2 <= i;
                j_out_SP2 <= j;
                data_SP2 <= data_dec;

                end
        2'b11:  begin
                SP_flag <= 0;
                IC_flag <= 0;
                SP2_flag <= 0;
                HPTC_flag <= 1;

                i_out_HPTC <= 1;
                j_out_HPTC <= 1;
                data_HPTC <= data_dec;

                end
        default:;
    endcase
    else;

end

//Ȼ������ģ��
//********************SP_decode
wire [23:0] pixel0_SP;
wire [23:0] pixel1_SP;
wire [23:0] pixel2_SP;
wire [23:0] pixel3_SP;
wire [23:0] pixel4_SP;
wire [23:0] pixel5_SP;
wire [23:0] pixel6_SP;
wire [23:0] pixel7_SP;


SP_decode u0_SP_decode(
    .rst_n          (rst_n),
    .clk_in         (clk_in),
    .data_in        (data_SP),
    .SP_flag        (SP_flag),
    .i_in           (i_out_SP),
    .j_in           (j_out_SP),

    .pixel0_fin         (pixel0_SP),
    .pixel1_fin         (pixel1_SP),
    .pixel2_fin         (pixel2_SP),
    .pixel3_fin         (pixel3_SP),
    .pixel4_fin         (pixel4_SP),
    .pixel5_fin         (pixel5_SP),
    .pixel6_fin         (pixel6_SP),
    .pixel7_fin         (pixel7_SP)

);


//********************IC_decode
wire [23:0] pixel0_IC;
wire [23:0] pixel1_IC;
wire [23:0] pixel2_IC;
wire [23:0] pixel3_IC;
wire [23:0] pixel4_IC;
wire [23:0] pixel5_IC;
wire [23:0] pixel6_IC;
wire [23:0] pixel7_IC;
//wire [10:0] addr0_h_IC;
//wire [11:0] addr0_v_IC;
//wire [10:0] addr1_h_IC;
//wire [11:0] addr1_v_IC;
//wire [10:0] addr2_h_IC;
//wire [11:0] addr2_v_IC;
//wire [10:0] addr3_h_IC;
//wire [11:0] addr3_v_IC;
//wire [10:0] addr4_h_IC;
//wire [11:0] addr4_v_IC;
//wire [10:0] addr5_h_IC;
//wire [11:0] addr5_v_IC;
//wire [10:0] addr6_h_IC;
//wire [11:0] addr6_v_IC;
//wire [10:0] addr7_h_IC;
//wire [11:0] addr7_v_IC;


IC_decode u0_IC_decode(
    .rst_n          (rst_n),
    .clk_in         (clk_in),
    .data_in        (data_IC),
    .IC_flag        (IC_flag),
    .i_in           (i_out_IC),
    .j_in           (j_out_IC),

    .pixel0         (pixel0_IC),
    .pixel1         (pixel1_IC),
    .pixel2         (pixel2_IC),
    .pixel3         (pixel3_IC),
    .pixel4         (pixel4_IC),
    .pixel5         (pixel5_IC),
    .pixel6         (pixel6_IC),
    .pixel7         (pixel7_IC)

//    .addr0_h        (addr0_h_IC),
//    .addr0_v        (addr0_v_IC),
//    .addr1_h        (addr1_h_IC),
//    .addr1_v        (addr1_v_IC),
//    .addr2_h        (addr2_h_IC),
//    .addr2_v        (addr2_v_IC),
//    .addr3_h        (addr3_h_IC),
//    .addr3_v        (addr3_v_IC),
//    .addr4_h        (addr4_h_IC),
//    .addr4_v        (addr4_v_IC),
//    .addr5_h        (addr5_h_IC),
//    .addr5_v        (addr5_v_IC),
//    .addr6_h        (addr6_h_IC),
//    .addr6_v        (addr6_v_IC),
//    .addr7_h        (addr7_h_IC),
//    .addr7_v        (addr7_v_IC)

);


//**********************SP2_decode
wire [23:0] pixel0_SP2;
wire [23:0] pixel1_SP2;
wire [23:0] pixel2_SP2;
wire [23:0] pixel3_SP2;
wire [23:0] pixel4_SP2;
wire [23:0] pixel5_SP2;
wire [23:0] pixel6_SP2;
wire [23:0] pixel7_SP2;
//wire [10:0] addr0_h_SP2;
//wire [11:0] addr0_v_SP2;
//wire [10:0] addr1_h_SP2;
//wire [11:0] addr1_v_SP2;
//wire [10:0] addr2_h_SP2;
//wire [11:0] addr2_v_SP2;
//wire [10:0] addr3_h_SP2;
//wire [11:0] addr3_v_SP2;
//wire [10:0] addr4_h_SP2;
//wire [11:0] addr4_v_SP2;
//wire [10:0] addr5_h_SP2;
//wire [11:0] addr5_v_SP2;
//wire [10:0] addr6_h_SP2;
//wire [11:0] addr6_v_SP2;
//wire [10:0] addr7_h_SP2;
//wire [11:0] addr7_v_SP2;



SP2_decode u0_SP2_decode(
    .rst_n          (rst_n),
    .clk_in         (clk_in),
    .data_in        (data_SP2),
    .SP2_flag       (SP2_flag),
    .i_in           (i_out_SP2),
    .j_in           (j_out_SP2),

    .pixel0         (pixel0_SP2),
    .pixel1         (pixel1_SP2),
    .pixel2         (pixel2_SP2),
    .pixel3         (pixel3_SP2),
    .pixel4         (pixel4_SP2),
    .pixel5         (pixel5_SP2),
    .pixel6         (pixel6_SP2),
    .pixel7         (pixel7_SP2)

//    .addr0_h        (addr0_h_SP2),
//    .addr0_v        (addr0_v_SP2),
//    .addr1_h        (addr1_h_SP2),
//    .addr1_v        (addr1_v_SP2),
//    .addr2_h        (addr2_h_SP2),
//    .addr2_v        (addr2_v_SP2),
//    .addr3_h        (addr3_h_SP2),
//    .addr3_v        (addr3_v_SP2),
//    .addr4_h        (addr4_h_SP2),
//    .addr4_v        (addr4_v_SP2),
//    .addr5_h        (addr5_h_SP2),
//    .addr5_v        (addr5_v_SP2),
//    .addr6_h        (addr6_h_SP2),
//    .addr6_v        (addr6_v_SP2),
//    .addr7_h        (addr7_h_SP2),
//    .addr7_v        (addr7_v_SP2)
);

//*************************HPTC

wire [23:0] pixel0_HPTC;
wire [23:0] pixel1_HPTC;
wire [23:0] pixel2_HPTC;
wire [23:0] pixel3_HPTC;
wire [23:0] pixel4_HPTC;
wire [23:0] pixel5_HPTC;
wire [23:0] pixel6_HPTC;
wire [23:0] pixel7_HPTC;


HPTC_decode u0_HPTC_decode(
    .rst_n          (rst_n),
    .clk_in         (clk_in),
    .data_in        (data_HPTC),
    .HPTC_flag      (HPTC_flag),
    .i_in           (i_out_HPTC),   
    .j_in           (j_out_HPTC),
        
        
        
    .pixel0_fin         (pixel0_HPTC),
    .pixel1_fin         (pixel1_HPTC),
    .pixel2_fin         (pixel2_HPTC),
    .pixel3_fin         (pixel3_HPTC),
    .pixel4_fin         (pixel4_HPTC),
    .pixel5_fin         (pixel5_HPTC),
    .pixel6_fin         (pixel6_HPTC),
    .pixel7_fin         (pixel7_HPTC)

);


//***************************��һ����ô��������:

//����һ�����⣬�����ҵ�������ô���кϲ��������ĺ�vs��hs��de����ϵ�������������
//Ŀǰ�뷨�Ǹ���ÿ����ַaddrh��v�Ĵ�С��������
//����������ΰѵ�ַ������������������ά������

//*********************************��ΰ�ÿ��pixel�����������

//Ҫ�ǵð��Ǹ��޴���cnt��ȡ����
//reg [7:0] pixel0_fin;
//reg [7:0] pixel1_fin;
//reg [7:0] pixel2_fin;
//reg [7:0] pixel3_fin;
//reg [7:0] pixel4_fin;
//reg [7:0] pixel5_fin;
//reg [7:0] pixel6_fin;
//reg [7:0] pixel7_fin;





//*******************zhuanyedapai30nian
reg SP_flag_0;
reg SP_flag_1;
reg SP_flag_2;
reg SP_flag_3;
reg SP_flag_4;
reg IC_flag_0;
reg IC_flag_1;
reg IC_flag_2;
reg IC_flag_3;
reg IC_flag_4;
reg SP2_flag_0;
reg SP2_flag_1;
reg SP2_flag_2;
reg SP2_flag_3;
reg SP2_flag_4;
reg HPTC_flag_0;
reg HPTC_flag_1;
reg HPTC_flag_2;
reg HPTC_flag_3;
reg HPTC_flag_4;

reg SP_flag_5;
reg IC_flag_5;
reg SP2_flag_5;
reg HPTC_flag_5;


reg [23:0] pixel0_IC_0;
reg [23:0] pixel1_IC_0;
reg [23:0] pixel2_IC_0;
reg [23:0] pixel3_IC_0;
reg [23:0] pixel4_IC_0;
reg [23:0] pixel5_IC_0;
reg [23:0] pixel6_IC_0;
reg [23:0] pixel7_IC_0;
reg [23:0] pixel0_IC_1;
reg [23:0] pixel1_IC_1;
reg [23:0] pixel2_IC_1;
reg [23:0] pixel3_IC_1;
reg [23:0] pixel4_IC_1;
reg [23:0] pixel5_IC_1;
reg [23:0] pixel6_IC_1;
reg [23:0] pixel7_IC_1;

reg [23:0] pixel0_SP2_0;
reg [23:0] pixel1_SP2_0;
reg [23:0] pixel2_SP2_0;
reg [23:0] pixel3_SP2_0;
reg [23:0] pixel4_SP2_0;
reg [23:0] pixel5_SP2_0;
reg [23:0] pixel6_SP2_0;
reg [23:0] pixel7_SP2_0;
//reg [23:0] pixel0_HPTC_0;
//reg [23:0] pixel1_HPTC_0;
//reg [23:0] pixel2_HPTC_0;
//reg [23:0] pixel3_HPTC_0;
//reg [23:0] pixel4_HPTC_0;
//reg [23:0] pixel5_HPTC_0;
//reg [23:0] pixel6_HPTC_0;
//reg [23:0] pixel7_HPTC_0;

//SP��6��ʱ��
always @(posedge clk_in or negedge rst_n) 
begin
    if (~rst_n) 
    begin
        
    end 
    else 
    begin
        SP_flag_0 <= SP_flag;
        SP_flag_1 <= SP_flag_0;
        SP_flag_2 <= SP_flag_1;
        SP_flag_3 <= SP_flag_2;
        SP_flag_4 <= SP_flag_3;
        SP_flag_5 <= SP_flag_4;

        IC_flag_0 <= IC_flag;
        IC_flag_1 <= IC_flag_0;
        IC_flag_2 <= IC_flag_1;
        IC_flag_3 <= IC_flag_2;
        IC_flag_4 <= IC_flag_3;
        IC_flag_5 <= IC_flag_4;

        SP2_flag_0 <= SP2_flag;
        SP2_flag_1 <= SP2_flag_0;
        SP2_flag_2 <= SP2_flag_1;
        SP2_flag_3 <= SP2_flag_2;
        SP2_flag_4 <= SP2_flag_3;
        SP2_flag_5 <= SP2_flag_4;

        HPTC_flag_0 <= HPTC_flag;
        HPTC_flag_1 <= HPTC_flag_0;
        HPTC_flag_2 <= HPTC_flag_1;
        HPTC_flag_3 <= HPTC_flag_2;
        HPTC_flag_4 <= HPTC_flag_3;
        HPTC_flag_5 <= HPTC_flag_4;

        pixel0_IC_0 <= pixel0_IC;
        pixel1_IC_0 <= pixel1_IC;
        pixel2_IC_0 <= pixel2_IC;
        pixel3_IC_0 <= pixel3_IC;
        pixel4_IC_0 <= pixel4_IC;
        pixel5_IC_0 <= pixel5_IC;
        pixel6_IC_0 <= pixel6_IC;
        pixel7_IC_0 <= pixel7_IC;

        pixel0_IC_1 <= pixel0_IC_0;
        pixel1_IC_1 <= pixel1_IC_0;
        pixel2_IC_1 <= pixel2_IC_0;
        pixel3_IC_1 <= pixel3_IC_0;
        pixel4_IC_1 <= pixel4_IC_0;
        pixel5_IC_1 <= pixel5_IC_0;
        pixel6_IC_1 <= pixel6_IC_0;
        pixel7_IC_1 <= pixel7_IC_0;

        pixel0_SP2_0 <= pixel0_SP2;
        pixel1_SP2_0 <= pixel1_SP2;
        pixel2_SP2_0 <= pixel2_SP2;
        pixel3_SP2_0 <= pixel3_SP2;
        pixel4_SP2_0 <= pixel4_SP2;
        pixel5_SP2_0 <= pixel5_SP2;
        pixel6_SP2_0 <= pixel6_SP2;
        pixel7_SP2_0 <= pixel7_SP2;

    end    
end

//reg pic_test;
//���һ��Ҫע�⣺
//1.�Ǹ����ݵ�ͬ����
//2.���ĵ���Ҫ��
//3.flag���ܵ��������ݿ϶���Ҫ���ĵ�
always @(posedge clk_in or negedge rst_n ) 
begin
    if (~rst_n) begin
        
    end 
    else if(SP_flag_5)
    begin
        pixel0_fin <= pixel0_SP;
        pixel1_fin <= pixel1_SP;
        pixel2_fin <= pixel2_SP;
        pixel3_fin <= pixel3_SP;
        pixel4_fin <= pixel4_SP;
        pixel5_fin <= pixel5_SP;
        pixel6_fin <= pixel6_SP;
        pixel7_fin <= pixel7_SP;
        pic_test <= 1;
    end
    else if(IC_flag_5)
    begin
        pixel0_fin <= pixel0_IC_1;
        pixel1_fin <= pixel1_IC_1;
        pixel2_fin <= pixel2_IC_1;
        pixel3_fin <= pixel3_IC_1;
        pixel4_fin <= pixel4_IC_1;
        pixel5_fin <= pixel5_IC_1;
        pixel6_fin <= pixel6_IC_1;
        pixel7_fin <= pixel7_IC_1;
        pic_test <= 1;
    end
    else if(SP2_flag_5)
    begin
        pixel0_fin <= pixel0_SP2_0;
        pixel1_fin <= pixel1_SP2_0;
        pixel2_fin <= pixel2_SP2_0;
        pixel3_fin <= pixel3_SP2_0;
        pixel4_fin <= pixel4_SP2_0;
        pixel5_fin <= pixel5_SP2_0;
        pixel6_fin <= pixel6_SP2_0;
        pixel7_fin <= pixel7_SP2_0;
        pic_test <= 1;
    end
    else if(HPTC_flag_5)
    begin
        pixel0_fin <= pixel0_HPTC;
        pixel1_fin <= pixel1_HPTC;
        pixel2_fin <= pixel2_HPTC;
        pixel3_fin <= pixel3_HPTC;
        pixel4_fin <= pixel4_HPTC;
        pixel5_fin <= pixel5_HPTC;
        pixel6_fin <= pixel6_HPTC;
        pixel7_fin <= pixel7_HPTC;
        pic_test <= 1;
    end

    else;
end


endmodule