Frequency_in = 1000;    %��Ҫ����ĸ������Ҳ���Ƶ��
size_cut = 100000;   %�ضϵ����ٵ�
is_Filte = 1;   %Ϊ��ʱ���ż�����ź����Ƶ��Ϊһʱ�����˲������Ƶ
[data,fs] = audioread('C:\Users\high_sky\Desktop\��Ƶ�˲���Ŀ\��Ʒ2.wav');  %Ҫ��Ϸ����Ƶ���ĳ����Լ���·��
result_Fs = 8000;   %����Ĳ�����
%[size_raw,~] = size(data);
%ע�⣬�������������������������Ƶ���ݣ����´���ֻȡ�������ĵ�һ������
temp = data(1:size_cut,1);  %����DSP�����ٶȹ��ͣ�����Ҫѹ������        
temp2 = resample(temp,result_Fs,fs); %��ԭ��Ƶ���ٴβ���
[size_data,~] = size(temp2);    %��ȡ��Ƶ����
%����Ƶ��Ϊ����Ӹ��ţ����ŵ�Ƶ����Frequency_in����
noise = sin(2*pi*Frequency_in*size_data/result_Fs*linspace(0,1,size_data));
temp2 = temp2 + noise'; %��������

temp3 = int32(temp2*10^4);  %�����ݴ�������Σ�����DSP����
temp4 = double(temp3)/10^4; %���԰��������ݻָ��ɸ���������

Hn = getFilter(result_Fs);  %��ȡ�˲�����ʱ������
if is_Filte
    temp4 = conv(temp4,Hn);     %�Լ����˸��ŵ���Ƶ���ݽ����˲�
end
sound(temp4,result_Fs);     %���Ŵ�����

%�Ѽ�������������������ת���Ľ��д�뵽�ļ�������DSP����
fp = fopen('_input','w');
for i = 1:size(temp3)
    fprintf(fp,'%d ',temp3(i));
end
fclose(fp);

%�����Ӹ��ź��Ƶ��ͼ
figure(1);
plot(abs(fft(temp2)));
%�����˲����Ƶ��ͼ
figure(2);
plot(abs(fft(temp4)));
%�����˲����ķ���ͼ
figure(3);
freqz(Hn);

%��ʽ������˲������ݣ�����д��DSP
fprintf("{");
for i = 1:length(Hn)
    fprintf("%e,",Hn(i));
end
fprintf("};\n");

%����˲����ķ���
function result = getFilter(result_Fs)
    fcuts = [200 900 1100 2000]; %����ͨ���������Ƶ��
    mags = [1 0 1];             %����ͨ�������
    devs = [0.1 0.01 0.1];      %����ͨ����������Ʋ�ϵ��
    [n,Wn,beta,ftype] = kaiserord(fcuts,mags,devs,result_Fs);  %�����������N��beta��ֵ
    result = fir1(n,Wn,ftype,kaiser(n+1,beta),'noscale');   %�����˲���
end
