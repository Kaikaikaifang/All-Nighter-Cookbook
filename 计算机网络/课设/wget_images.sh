#!/bin/bash

# 基础URL
base_url="https://s3.ananas.chaoxing.com/sv-w8/doc/4c/3f/e0/bf3ea0ac6aba43d46b37f6d421a9e767/thumb/"

# 下载图片的起始和结束编号
start=1
end=5

# 本地保存目录
save_dir="./images"

# 创建保存目录
mkdir -p "$save_dir"

# 循环下载每一张图片
for ((i=start; i<=end; i++))
do
	# 构建完整的URL和本地文件名
	url="${base_url}${i}.png"
	file_name="${save_dir}/summary_${i}.png"
	        
	# 使用wget下载图片
	wget -q -O "$file_name" "$url"

	# 检查下载是否成功
	if [ $? -eq 0 ]; then
		echo "Downloaded: ${file_name}"
	else
		echo "Failed to download: ${url}"
	fi
done

echo "All downloads completed."

