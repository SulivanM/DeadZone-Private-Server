#!/bin/bash
echo "Starting Deadzone Server..."

# Try JAVA_HOME first
if [[ -x "$JAVA_HOME/bin/java" ]]; then
    JAVA="$JAVA_HOME/bin/java"
elif [[ -x "/usr/bin/java" ]]; then
    JAVA="/usr/bin/java"
else
    echo "Java not found. Please install Java or set JAVA_HOME."
    exit 1
fi

"$JAVA" -jar deadzone-server.jar
