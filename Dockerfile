FROM eclipse-temurin:21.0.2_13-jre-alpine
COPY target/*.jar spring-petclinic-3.2.0-SNAPSHOT.jar
CMD ["java", "-jar", "spring-petclinic-3.2.0-SNAPSHOT.jar"]