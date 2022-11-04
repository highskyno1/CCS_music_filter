#include <stdio.h>
#include <stdlib.h>

#define N 27   //滤波器的长度
/**
 * hello.c
 */

//滤波器数据
const static double filter[] = {-1.817133e-03,-1.030943e-02,-1.486092e-02,-6.554923e-03,5.310618e-03,-3.484461e-17,-1.961028e-02,-1.277302e-02,5.264802e-02,1.370936e-01,1.426501e-01,1.707388e-02,-1.639884e-01,7.500000e-01,-1.639884e-01,1.707388e-02,1.426501e-01,1.370936e-01,5.264802e-02,-1.277302e-02,-1.961028e-02,-3.484461e-17,5.310618e-03,-6.554923e-03,-1.486092e-02,-1.030943e-02,-1.817133e-03,};

int temp_Music[N]; //音频缓冲器

//循环保存数据时，取音频缓冲器的值
//为了减少时间复杂度，直接以新数据覆盖最旧的数据
//减少了移位的环节
/**
 * 循环保存数据时，取音频缓冲器的值
 * @param index 需要取得数据的相对索引
 * @param bias  索引偏置，即当前最新数据的直接索引
 * @return 取出的数据
 */
int getValue(int index,int bias){
    int temp = bias + index;
    if(temp < N)
        return temp_Music[temp];
    else
        return temp_Music[temp - N];
}

//此函数用于计算滤波结果，每次输出一个值
//index为当前最新时域数据在音频缓冲器中的位置
/**
 * 实现单个数据的卷积并输出结果
 * @param index 最新的数据的直接索引
 * @return 卷积结果
 */
int output(int index){
    int i;
    double sum = 0;
    for(i = 0;i < N;i++)
        sum += getValue(N-i-1,index) * filter[i];
    return (int)sum;
}

int main(void)
{
    int i;  //我就是一个移位计数器
    int out_Count = 0;  //在输出百分比时，用户换行以方便观看
    unsigned long Conter = 0;   //用于统计进行了多少次结果输出
    int index_new = 0;  //用于记录新数据插入的位置
    int out_temp;   //乘积缓冲
    long input_length;  //用于统计程序进行了百分之多小，计算时用作分母
    double input_size = 0;    //保存输入数据的长度,如果超出了，我也没办法，哈哈哈
    char temp;  //缓存器
    printf("Hello World!\n");
    FILE *fp_input,*fp_output; //输入和输出的音频信号的文件
    if((fp_input = fopen("_input","r")) == NULL){   //尝试打开文件
        printf("The file can not be opened\n"); //文件打开失败
        return 1;   //退出程序
    }
    printf("OK0!\n");
    if((fp_output = fopen("_output","w")) == NULL){ //创建结果输出文件
        printf("The file can not be created\n");    //输出文件无法创建
        return 2;   //退出程序
    }
    printf("OK1!\n");
    //统计输入文件有多大，基于输入文件的空格字符数
    while((temp = fgetc(fp_input)) != EOF){
        if(temp == ' ')
            input_size++;
    }
    input_length = (long)(input_size/1000); //计算输出进度统计的分母
    //使文件指针回到文件初位置
    fseek(fp_input,0L,SEEK_SET);
    //用数据来喂饱饥饿已久的缓冲数组
    for(i = 0;i < N;i++){
        fscanf(fp_input,"%d",&out_temp);
        temp_Music[i] = out_temp;
    }
    printf("OK2!\n");
    fprintf(fp_output,"%d ",output(index_new)); //写入第一个卷积输出结果
    printf("OK3!\n");

    while(fscanf(fp_input,"%d",&out_temp) != EOF){  //不断地往循环数据添加新数据
        temp_Music[index_new] = out_temp;
        index_new++;
        if(index_new >= N)  //触及输入缓冲数组最大索引（即数组顶）
            index_new = 0;  //回到输入缓冲数组的底部
        fflush(fp_output);  //因为写入是异步的，为防止漏写，添加此步
        fprintf(fp_output,"%d ",output(index_new));
        Conter++;   //输出结果的计数器+1
        if(Conter % input_length == 0){ //更新进度条
            printf("%d/1000 \0",(int)(Conter/input_length));
            out_Count++;
            if(out_Count >= 15){
                printf("\n");
                out_Count = 0;
            }
        }
    }
    printf("OK4!\n");   //滤波完成
    //关闭文件IO
    fclose(fp_input);
    fclose(fp_output);

    return 0;
}
