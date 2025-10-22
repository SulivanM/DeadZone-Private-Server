#!/bin/bash
set -e
.\gradlew shadowJar
echo
echo "Finished. Press Enter to exit..."
read