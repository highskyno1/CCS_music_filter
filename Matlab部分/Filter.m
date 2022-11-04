Frequency_in = 1000;    %需要引入的干扰正弦波的频率
size_cut = 100000;   %截断到多少点
is_Filte = 1;   %为零时播放假如干扰后的音频，为一时播放滤波后的音频
[data,fs] = audioread('C:\Users\high_sky\Desktop\音频滤波项目\样品2.wav');  %要调戏的音频，改成你自己的路径
result_Fs = 8000;   %结果的采样率
%[size_raw,~] = size(data);
%注意，如果是两个或者以上声道的音频数据，以下代码只取读进来的第一个声道
temp = data(1:size_cut,1);  %由于DSP处理速度过低，可能要压缩数据        
temp2 = resample(temp,result_Fs,fs); %对原音频的再次采样
[size_data,~] = size(temp2);    %求取音频长度
%给音频人为地添加干扰，干扰的频率由Frequency_in给定
noise = sin(2*pi*Frequency_in*size_data/result_Fs*linspace(0,1,size_data));
temp2 = temp2 + noise'; %加入噪声

temp3 = int32(temp2*10^4);  %把数据处理成整形，方便DSP读入
temp4 = double(temp3)/10^4; %尝试把整形数据恢复成浮点型数据

Hn = getFilter(result_Fs);  %获取滤波器的时域数据
if is_Filte
    temp4 = conv(temp4,Hn);     %对加入了干扰的音频数据进行滤波
end
sound(temp4,result_Fs);     %播放处理结果

%把加了噪声并且做了整形转换的结果写入到文件，方便DSP分析
fp = fopen('_input','w');
for i = 1:size(temp3)
    fprintf(fp,'%d ',temp3(i));
end
fclose(fp);

%画出加干扰后的频谱图
figure(1);
plot(abs(fft(temp2)));
%画出滤波后的频谱图
figure(2);
plot(abs(fft(temp4)));
%画出滤波器的分析图
figure(3);
freqz(Hn);

%格式化输出滤波器数据，方便写入DSP
fprintf("{");
for i = 1:length(Hn)
    fprintf("%e,",Hn(i));
end
fprintf("};\n");

%获得滤波器的方法
function result = getFilter(result_Fs)
    fcuts = [200 900 1100 2000]; %定义通带和阻带的频率
    mags = [1 0 1];             %定义通带和阻带
    devs = [0.1 0.01 0.1];      %定义通带或阻带的纹波系数
    [n,Wn,beta,ftype] = kaiserord(fcuts,mags,devs,result_Fs);  %计算出凯塞窗N，beta的值
    result = fir1(n,Wn,ftype,kaiser(n+1,beta),'noscale');   %生成滤波器
end
