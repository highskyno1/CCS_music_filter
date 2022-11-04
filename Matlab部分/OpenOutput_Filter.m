Id = fopen('E:\CCS_prj_new\MyFilter\Debug\_output','r');
data = fscanf(Id,'%d ');
data = data/10^4;
sound(data,8000);   %播放时，注意采样率需要与生成时一致
fclose(Id);