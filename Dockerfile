# Use a Maven image with JDK 17 for the build stage
FROM maven:3.8.4-openjdk-17 as build

# Set the working directory in the Docker image
WORKDIR /app

# Optimize the build by caching dependencies
# First, copy the pom.xml file
COPY pom.xml .

# Download dependencies
RUN mvn dependency:go-offline -B

# Copy the rest of the project
COPY src src

# Build the application without running tests to speed up the build
RUN mvn package -DskipTests

# Use OpenJDK 17 for the runtime stage
FROM openjdk:17-slim

# Set the working directory in the runtime image
WORKDIR /app

# Copy the built jar file from the build stage to the runtime stage
COPY --from=build /app/target/*.jar app.jar

# Expose the port the application listens on
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "app.jar"]
