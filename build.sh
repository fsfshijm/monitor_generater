#!/bin/bash

PNAME=monitor_generater
VERSION=0.1.2

rm -rf target
mkdir target

SCRATCH_DIR="$PNAME-$VERSION"

cd target
mkdir $SCRATCH_DIR

# 在这里将需要发布的文件，放到scratch目录下
cp -r ../templates ../dmpy.sh $SCRATCH_DIR


# 删除svn目录
find . -name '.svn' -exec rm -rf {} \; 2>/dev/null
find . -name *~ -exec rm -rf {} \; 2>/dev/null

tar czf $SCRATCH_DIR.tar.gz $SCRATCH_DIR
# 运行时目录，需要在puppet的配置中去设置0777权限
#fpm -s dir -t rpm -n $PNAME -v $VERSION --epoch=`date +%s` --prefix=/usr/local/xxxxxxxx/prog.d $SCRATCH_DIR

rm -rf $SCRATCH_DIR

