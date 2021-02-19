# 基于 Bowtie2 的 16S 扩增子测序和参考序列比对

### 环境配置


首次登录服务器需要安装 conda 并配置基本环境。conda 可以使用非管理员账户安装。首先使用 `wget` 下载 conda：
```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
```
运行安装
```bash
bash Miniconda3-latest-Linux-x86_64.sh
```
在 `base` 环境下安装配置 `fastqc`、`bowtie2` 等：
```bash
conda install -c bioconda fastqc #在base环境下,安装fastqc
conda install -c bioconda samtools #在base环境下, 安装samtools  
conda install -c bioconda bowtie2 #在base环境下,安装bowtie2
conda install -c bioconda bedtools #在base环境下,安装bedtools
```


#### 激活环境
现在 `qiime2-2019.4` 等环境已经配置在新服务器 `*.134` 的 `/home/LDlab/BioSoft/anaconda3/envs/` 下，可以直接激活
```bash
conda activate /home/LDlab/BioSoft/anaconda3/envs/qiime2-2019.4 #激活qiime2-2019.4
```


#### 配置 `screen` 
可以使用 `screen` 命令创建新的‘屏幕’在后台运行，可以在丢失连接的时候维持运行并看到报错等信息。
```bash
screen -S 1 #后台运行防掉线，1为文件名
```


### 序列拆分
#### 主要流程


#### 双端合并
将正向和反向的测序结果合并在一起
```bash
cd ~/seqdata-20200421
mkdir result
cd ./result/
#在qiime2-2019.04环境运行，输入两个文件
vsearch --fastq_mergepairs /home/zuowl/seqdata-20200421/QZP1_S1_L001_R1_001.fastq.gz \
				--reverse /home/zuowl/seqdata-20200421/QZP1_S1_L001_R2_001.fastq.gz \
        --fastqout qzp_merged.fq \
        --fastqout_notmerged_fwd qzp_unmapped_1.fq \ 
        --fastqout_notmerged_rev qzp_unmapped_2.fq \
        1>>vserach_log_qzp.txt \
        2>>vserach_log_qzp.txt
```


#### 测序质量检测
```bash
conda deactivate
fastqc qzp_merged.fq #在base环境运行，看测序数据质量
```


#### 测序数据拆分
```bash
conda activate /home/LDlab/BioSoft/anaconda3/envs/qiime2-2019.4
#在qiime2-2019.04环境运行，输入1个文件1个脚本
python /home/LDlab/BioSoft/Scripts/parse_sample_perfectmatch.py \
		-i qzp_merged.fq \
		-t ~/seqdata-20200421/reference/sample_indexes.txt \
    -f 20 -r 18 
```


#### 使用 Bowtie2 与 Reference 对比
```bash
#在base环境运行，输入2个文件1个脚本
conda deactivate
bash /home/LDlab/BioSoft/Scripts/Bowtie2align_and_feature_extract.sh \
		~/seqdata-20200421/result/parse \
    ~/seqdata-20200421/reference/53strains_v5_v7.fa \
		~/seqdata-20200421/reference/53strains_bed.bed 
```


