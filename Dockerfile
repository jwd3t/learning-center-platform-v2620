# Build stage: Maven + Temurin 26 JDK
FROM maven:3.9-eclipse-temurin-26-noble AS build
WORKDIR /workspace

COPY pom.xml .
RUN mvn -B -f pom.xml -DskipTests dependency:go-offline

COPY . .
RUN mvn -B -DskipTests package

# Runtime stage: Temurin 26 JRE
FROM eclipse-temurin:26-jre
WORKDIR /app

COPY --from=build /workspace/target/*.jar app.jar

ENV SPRING_PROFILES_ACTIVE=dev
ENV PORT=8096
ENV JAVA_OPTS=""

EXPOSE 8096

ENTRYPOINT ["sh","-c","java $JAVA_OPTS -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE} -Dserver.port=${PORT} -jar /app/app.jar"]
