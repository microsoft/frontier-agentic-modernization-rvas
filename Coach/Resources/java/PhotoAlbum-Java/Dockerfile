# Use Maven with OpenJDK 21 for building
FROM maven:3.9.6-eclipse-temurin-21 AS build

WORKDIR /app

# Copy Maven files for dependency resolution
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Use OpenJDK 21 runtime for the final image
FROM eclipse-temurin:21-jre

WORKDIR /app

# Copy the built jar file
COPY --from=build /app/target/photo-album-*.jar app.jar

# Expose port
EXPOSE 8080

# Set JVM options for container environment
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]