Id = fopen('E:\CCS_prj_new\MyFilter\Debug\_output','r');
data = fscanf(Id,'%d ');
data = data/10^4;
sound(data,8000);   %����ʱ��ע���������Ҫ������ʱһ��
fclose(Id);