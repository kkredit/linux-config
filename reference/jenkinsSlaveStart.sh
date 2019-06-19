#!/bin/bash

pushd $(dirname $0) > /dev/null

JENKINS_USER=jenkins_user
URL="http://your_jenkins_server:8080"
SECRET=YOURSECRET1234
AGENT_NAME="agent_name"
AGENT_WORKDIR="/agent/working/dir"
AGENT_JAR=slaveAgentJnlp.jar

if [[ "$(whoami)" != "$JENKINS_USER" ]]; then
    echo "The $JENKINS_USER user must run this script"
    exit 1
fi

if [[ ! -f $AGENT_JAR ]]; then
    wget -O $AGENT_JAR $URL/jnlpJars/slave.jar
fi

PID=$(ps -aux | grep "java -jar $AGENT_JAR" | grep -v grep | awk '{print $2}')
if [[ $PID ]]; then
    echo "JNLP slave agent is already running. Killing first..."
    kill $PID
fi

echo "Starting JNLP slave agent..."
java -jar $AGENT_JAR -jnlpUrl $URL/computer/$AGENT_NAME/slave-agent.jnlp -secret $SECRET \
    -workDir $AGENT_WORKDIR &

popd > /dev/null
