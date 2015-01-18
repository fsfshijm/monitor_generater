#!/bin/bash
VERSION=0.1.0

NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2; tput bold)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
 
function red() {
    echo -e "$RED$*$NORMAL"
}
 
function green() {
    echo -e "$GREEN$*$NORMAL"
}
 
function yellow() {
    echo -e "$YELLOW$*$NORMAL"
}

function generate {
	FULL=$1
	NAME=$2
	# info_server => InfoServer
	CAPITAL_FULL=`echo "$FULL" | sed 's/\b[a-z]/\U&/g'`
	arr=(${NAME//_/ })
	for i in ${arr[@]}
	do
		CAPITAL_PART=`echo "$i" | sed 's/\b[a-z]/\U&/g'`
		CAPITAL_NAME=$CAPITAL_NAME$CAPITAL_PART
	done

	git clone http://git.xxxxxxxx-inc.cn/xxxxxxxxqa/monitor_generater.git tmp
	#USER_PROJ_DRI=$USER"-"$NAME
	USER_PROJ_DRI=$NAME
	cp -r tmp/templates/$FULL/ $USER_PROJ_DRI

	cd $USER_PROJ_DRI

	find . -type f | xargs sed -i "s/$FULL/$NAME/g"
	find . -type f | xargs sed -i "s/$CAPITAL_FULL/$CAPITAL_NAME/g"
	find . -name "$FULL*" -type f | xargs rename "$FULL" "$NAME"
	
	cd ..
	cp .gitignore $USER_PROJ_DRI
	rm -rf tmp
}

red "Domob Python Project Generator\nv$VERSION"

echo 'supported project template:'
green "fileScaner" 
echo "fileScaner: 本地明文的扫描，可以统计总数，或者统计某些key的数量."

green "dm303Scaner"
echo "dm303Scaner: 读取dm303数据."

green "thiftScaner"
echo "thiftScaner: 读取thrift结构的二进制文件"


yellow "\nWhich Python project model do you want, f(fileScaner) or d(dm303Scaner) or t(thiftScaner):"
read TYPE
case "$TYPE" in
	f)
		FULL=fileScaner
		;;
	d)
		FULL=dm303Scaner
		;;
	t)
		FULL=thiftScaner
		;;
	*)
		echo "Sorry, unsupported."
		exit 1
esac

yellow "What name do you like for your new project:"
read NAME

generate $FULL $NAME

exit 0
