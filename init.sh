#!/usr/bin/env bash

echo ""
echo "Setting up wrapped clis"
echo "(sdfcli, sdfcli-createproject)"
echo ""

(which wget || ( which brew && brew install wget || which apt-get && apt-get install wget || which yum && yum install wget || which choco && choco install wget)) &> /dev/null
(which tar || ( which brew && brew install gnu-tar || which apt-get && apt-get install tar || which yum && yum install tar || which choco && choco install tar)) &> /dev/null
(which find || ( which brew && brew install findutils || which apt-get && apt-get install findutils || which yum && yum install findutils || which choco && choco install findutils)) &> /dev/null

PARENT_DIR=$(pwd)
DEPS_DIR=$PARENT_DIR/.dependencies

mkdir -p $DEPS_DIR
cd $DEPS_DIR
# download all paths from urls file check content-disposition header for name and skip if file exists
wget -i $PARENT_DIR/urls --content-disposition -nc -q --show-progress

for filename in *.tar.gz
do
  tar zxf $filename
done


NODE_MODULES=$PARENT_DIR/node_modules
if [ ! -d "$NODE_MODULES" ]; then
  # is installed as npm package
  NODE_MODULES=$(find $(echo $(cd ../.. && pwd)) -maxdepth 1 -type d -name 'node_modules')
fi

JRE_DIR=$NODE_MODULES/node-jre/jre
JAVA_DIR=$(find $JRE_DIR -maxdepth 1 -type d -name '*.jre')
JAVA_HOME="JAVA_HOME=$JAVA_DIR/Contents/Home"

MAVEN_DIR=$(find $DEPS_DIR -maxdepth 1 -type d -name '*maven*')
MAVEN_BIN=$MAVEN_DIR/bin/mvn

# rewrite sdfcli script
echo "#!/bin/bash\n$JAVA_HOME $MAVEN_BIN -f $DEPS_DIR/pom.xml exec:java -Dexec.args=\"\$*\"" > sdfcli

rm -f $PARENT_DIR/sdfcli $PARENT_DIR/sdfcli-createproject
ln -s $DEPS_DIR/sdfcli $PARENT_DIR/sdfcli
ln -s $DEPS_DIR/sdfcli-createproject $PARENT_DIR/sdfcli-createproject

echo ""
echo "Setup completed"
echo ""