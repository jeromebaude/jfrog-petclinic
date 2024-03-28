# Spring PetClinic Sample Application

This project is a fork of https://github.com/spring-projects/spring-petclinic which is a springboot sample application.

The idea here is to create a CI workflow to build the sample app and a runnable docker image. We will use JFrog Artifactory to resolve dependencies in a secure way. We will also use JFrog Artifactory to store all build artifacts (maven build and docker build) so that everything is centralised with traceability and auditability.


## Run Petclinic locally

You can build a jar file and run it from the command line (it should work just as well with Java 17 or newer):

```bash
git clone https://github.com/jeromebaude/jfrog-petclinic.git
cd spring-petclinic
./mvnw package
java -jar target/*.jar
```

You can then access the Petclinic at <http://localhost:8080/>

## Build a runnable docker image

We created a simple Dockerfile based on [eclipse-temurin](https://hub.docker.com/_/eclipse-temurin)
Here is the [Dockerfile](https://github.com/jeromebaude/jfrog-petclinic/blob/main/Dockerfile)

```bash
docker build -t jeromebaude/petclinic:v1 .
docker run -d -p 8080:8080 jeromebaude/petclinic:v1
```

You can then access the Petclinic at <http://localhost:8080/>

## Make use of Artifactory

We now want to use Artifactory to resolve dependencies and deploy maven artifacts to Artifactory.

We need to login into Artifactory, generate a settings.xml file and copy it /c/Users/Jerome/.m2

We also need to add the following xml to pom.xml

```
<distributionManagement>
    <snapshotRepository>
        <id>snapshots</id>
        <name>a0etclnb4i7yf-artifactory-primary-0-snapshots</name>
        <url>https://jeromebaude.jfrog.io/artifactory/petclinic-libs-snapshot</url>
    </snapshotRepository>
</distributionManagement>
```

Finally you can run:
```bash
mvn clean deploy
```

## Store and scan a docker image with Artifactory

Artifactory stores all artifacts: the dependencies required to build your application, the binary and the Docker image you build.
Let's upload a Docker image and scan it with JFrog Xray. 
(I am here using JFrog  Cloud Platform. My URL is https://jeromebaude.jfrog.io)

First, we tag our local image according to our Artifactory repo name:
```bash
docker tag jeromebaude/petclinic:v1 jeromebaude.jfrog.io/petclinic-docker/jeromebaude/petclinic:v1
```

Now we login to Artifactory and push our image

```bash
docker login -u jerome.baude@gmail.com jeromebaude.jfrog.io
docker push jeromebaude.jfrog.io/petclinic-docker/jeromebaude/petclinic:v1
```

Then we go to the Artifactory console Xray > Scan List > petclinic-docker-local. We click on ...> Export Data. We download the report in a zip file containing all json files. (see Docker_jeromebaude-petclinic_version-v1_jerome.baude@gmail.com_2024-03-28.zip)

## Automate things through a CI workflow

We are going to use GitHub Actions as a CI/CD tool
(The current Github actions workflow is disable on my repo. Once enabled, it will trigger a build as soon as there is a new push to the repo)

The yaml file describing the workflow is [here](https://github.com/jeromebaude/jfrog-petclinic/blob/main/.github/workflows/maven-build.yml)

It is a pretty standard maven and docker build workflow but I want to highlight a few things:
- We set up JFrog CLI to collect VCS details from git and add them to the build
- We generate the Maven settings.xml to resolve dependencies securely with Artifactory  
- Once we build the Docker image, we login to JFrog to push the image to Artifactory and scan it