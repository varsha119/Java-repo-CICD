# Use the latest OpenJDK image as the base image
FROM openjdk:latest

# Create a directory in the Docker image to store the JAR file
WORKDIR /app

# Copy the JAR file from the host machine to the Docker image
COPY jenkins-test-2.0.jar /app/jenkins-test-2.0.jar

# Set the working directory
#WORKDIR /app

# Define the command to run the Java application when the container starts
ENTRYPOINT ["java", "-jar", "/app/jenkins-test-2.0.jar"]
