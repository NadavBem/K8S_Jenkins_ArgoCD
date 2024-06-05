FROM jenkins/jenkins:lts-jdk11
USER root
RUN apt update && curl -fsSL https://get.docker.com | sh
RUN usermod -aG docker jenkins
USER jenkins

## the run command
# docker run -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock <imagename> 
# docker exec -it -u root <container name> /bin/bash
# chown root:docker /var/run/docker.sock