#!/bin/bash

# Build if not already built
if [ ! -f "target/custom-config-server-1.0.0.jar" ]; then
    echo "Building application..."
    mvn clean package
fi

# Run the server
echo "Starting Custom Config Server on port 8080..."
java -jar target/custom-config-server-1.0.0.jar