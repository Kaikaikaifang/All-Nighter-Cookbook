%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FileName      : DA_OUT.m
%  Description   : DA输出函数。功能：用于将PC产生数据输出到DA，用示波器观察。
%  Function List :
%                   [] = DA_OUT(CH1_data,CH2_data,divFreq,dataNum,isGain)
%  Parameter List:       
%	Output Parameter

%	Input Parameter
%       CH1_data	        信源数据
%       CH1_data	        载波频率
%       divFreq             分频值
%       dataNum             数据长度
%       isGain              增益开关，0表示不对值放大，1表示对值放大
%  History
%    1. Date        : 2022-10-24
%       Author      : chen
%       Version     : xx 
%       Modification: test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = DA_OUT(CH1_data,CH2_data,divFreq,dataNum,isGain)
%% dataNum数据长度，由于硬件ROM大小限制，设计要求dataNum范围100~30720
ROM_MAX_LEN=30720;
ROM_MIN_LEN=100;
if dataNum>ROM_MAX_LEN
    disp('数据长度，超过长度限制范围100～30720');
    dataNum=ROM_MAX_LEN;
end
if  dataNum<ROM_MIN_LEN
    disp('数据长度，超过小于限制范围100～30720');
    dataNum=ROM_MIN_LEN;
end

%% divFreq取值范围0~1024
if (divFreq>1024)||(divFreq<0)
    disp('fs采样率参数配置超过允许范围');
    divFreq=0;
end

%% 处理使CH1_data和CH2_data 数据长度和dataNum值一致，
%% （如果处理前CH1_data和CH2_data 数据长度“小于”dataNum值，则补0，这样方便观察数据起始头）
%% （如果处理前CH1_data和CH2_data 数据长度“等于”dataNum值，则数据显示连续）
%% （如果处理前CH1_data和CH2_data 数据长度“大于”dataNum值，则截取有效长度dataNum）
temp_data=zeros(1,30720);
CH1_data_temp= [CH1_data ,temp_data];
CH2_data_temp= [CH2_data ,temp_data];
CH1_out_data=CH1_data_temp(1,1:dataNum);
CH2_out_data=CH2_data_temp(1,1:dataNum);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_Set_router = uint8(hex2dec({'00','00','99','bb', '68','00','00','06',  '00','00','00','00',  '00','00','00','00',  '00','00','00','00'})); %06 DA 网口发送信号

%%%%%%%%%%%%%%%%%%%%%
%%发送数据命令参数
divFreqL=mod(divFreq,256);
divFreqH=(divFreq-divFreqL)/256;
divFreqL=dec2hex(divFreqL);
divFreqH=dec2hex(divFreqH);

dataNumL=mod(dataNum,256);
dataNumH=(dataNum-dataNumL)/256;
dataNumL=dec2hex(dataNumL);
dataNumH=dec2hex(dataNumH);

test_tx_command = uint8(hex2dec({'00','00','99','bb', '65','0A','03','ff',  divFreqH,divFreqL,dataNumH,dataNumL,  '00','00','00','00',  '00','00','00','00'})); %发射参数


test_Send_IQ = uint8(hex2dec({'00','00','99','bb', '64','00','00','00',  '00','00','00','00',  '00','00','00','00',  '00','00','00','00'}));    %发送启动命令




SAMPLE_LENGTH = dataNum;                  
SEND_PACKET_LENGTH = 180;          

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%创建配置UDP对象，并打开
udp_obj = udp('192.168.1.165',13345,'LocalHost','192.168.1.65','LocalPort',12345,'TimeOut',100,'OutputBufferSize',61440,'InputBufferSize',61440*10);
%udp_obj = udp('198.168.1.131',13345,'LocalHost','198.168.1.31','LocalPort',12345,'TimeOut',100,'OutputBufferSize',61440,'InputBufferSize',61440*10);
fopen(udp_obj);

dataIQ = zeros(1,SAMPLE_LENGTH*2);
dataIQ(1,1:2:end) = CH1_out_data(1,:);
dataIQ(1,2:2:end) = CH2_out_data(1,:);
if isGain==1
    dataIQ = dataIQ.*(2047/max(abs(dataIQ)));    %放大峰值至2000,接近理论峰值2047
end
dataIQ = fix(dataIQ);                   %浮点数强制取整

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%防止溢出，并对负数进行补码操作.将有符号12位数据，转化为无符号12位数据
%eg -2048~2047,转化为0~4095
%   0~2047  不变
%   -2048~-1 对应转为 2048~4095
for n = 1 : SAMPLE_LENGTH*2
    if dataIQ(n) > 2047
        dataIQ(n) = 2047;
    elseif  dataIQ(n) < 0
        dataIQ(n) = 4096 + dataIQ(n);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%%按接口定义排列比特序
%I路：b11~b0 空4bits
dataIQ(1,1:2:SAMPLE_LENGTH*2-1) = dataIQ(1,1:2:SAMPLE_LENGTH*2).*16;
%Q路：b7~b0 空4bits b11~b8
dataIQ(1,2:2:SAMPLE_LENGTH*2) = fix(dataIQ(1,2:2:SAMPLE_LENGTH*2)./256) + rem(dataIQ(1,2:2:SAMPLE_LENGTH*2),256).*256;
dataIQ = uint16(dataIQ);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%发送命令参数
fwrite(udp_obj, test_Set_router,  'uint8');
fwrite(udp_obj, test_tx_command, 'uint8');
fwrite(udp_obj, test_Send_IQ, 'uint8');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%发送数据

if SAMPLE_LENGTH*2<SEND_PACKET_LENGTH
    fwrite(udp_obj, dataIQ(1,1:(SAMPLE_LENGTH*2)), 'uint16');
else
    for pn = 1:fix(SAMPLE_LENGTH*2/SEND_PACKET_LENGTH)
        fwrite(udp_obj, dataIQ(1,((pn-1)*SEND_PACKET_LENGTH+1) : (pn*SEND_PACKET_LENGTH)), 'uint16');
    end
    fwrite(udp_obj, dataIQ(1,(pn*SEND_PACKET_LENGTH+1 ): (SAMPLE_LENGTH*2)),'uint16');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%关闭UDP对象
echoudp('off')
fclose(udp_obj);
delete(udp_obj); 
clear udp_obj;

end