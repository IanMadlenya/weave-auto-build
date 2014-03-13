#!/bin/bash
ulimit -m 768000
cd
export FLEX_HOME=/home/build/flex
export ANT_OPTS="-XX:MaxPermSize=256m -Xmx768m"
pushd Weave > /dev/null
WEAVE_VERSION="./WeaveUISpark/src/weave/weave_version.txt"
git checkout HEAD -- $WEAVE_VERSION 2>&1 > ~/output-build
git pull -q origin master 2>&1 >> ~/output-build
echo "Nightly Build (`date`)" > $WEAVE_VERSION
#echo "Milestone 1.7 (`date`)" > $WEAVE_VERSION
pushd WeaveClient > /dev/null
ant -f buildall.xml dist 2>&1 >> ~/output-build
BUILD_RESULT=$?
popd > /dev/null
popd > /dev/null
if (( ! $BUILD_RESULT )); then
	pushd Weave-Binaries > /dev/null
	( git fetch -q  && unzip -qqo ../Weave/weave.zip && git add . && git commit --amend -qam "Automated build" && git push -fq origin master ) 2>&1 >> ~/output-build
	popd > /dev/null
else
	echo "Binary Build Failed:"
	cat ~/output-build
fi;

#Doc update
pushd Weave > /dev/null
pushd WeaveClient > /dev/null
ant -f build-asdoc.xml 2>&1 > ~/output-doc
ASDOC_RESULT=$?
popd > /dev/null
pushd WeaveServices > /dev/null
ant doc 2>&1 >> ~/output-doc
JAVADOC_RESULT=$?
popd > /dev/null
popd > /dev/null

pushd WeaveDoc > /dev/null
if (( ! $ASDOC_RESULT && ! $JAVADOC_RESULT )); then
	git pull -q origin gh-pages 2>&1 >> ~/output-doc
	rm -Rf asdoc javadoc
	mv ../Weave/WeaveClient/bin-debug/asdoc/ . 
	mv ../Weave/WeaveServices/javadoc/ .
	git add asdoc javadoc 2>&1 >> ~/output-doc
	git commit --amend -qam "Automated Documentation Build." 2>&1 >> ~/output-doc
	git push -fq origin gh-pages 2>&1 >> ~/output-doc
else
	echo "Documentation Build Failed:"
	cat ~/output-doc
fi
popd > /dev/null
