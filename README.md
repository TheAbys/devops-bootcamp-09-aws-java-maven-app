# 7 - Introduction to EC2 Virtual Cloud Server

We've created our own instance
- own security group which handles port forwarding etc
    - had to reconfigure it as the IP address changes regulary
- own ssh pem key to ssh into the machine
    - stored that under ~/.ssh
- added the instance to existing vpn and subnet
    ssh -i ~/.ssh/ docker-server.pem ec2-user@3.68.213.53
- company specific policy: add SERVICE tag to instance and volume

Installing docker on the ec2 instance
- update packages

    sudo yum update

- install docker

    sudo yum install docker

- start the docker service, this allows to pull, run, build, ...

    sudo service docker start

- check weather docker is running or not
    
    ps aux | grep docker

We want to add the user to the docker group

    sudo usermod -aG docker $USER

- check weather the group is see (relog is required)

    group

# 8 - Deploy to EC2 server from Jenkins Pipeline - CI/CD Part 1

Through having to take a break on this subject I had to cancel DigitalOcean and therefore re-setup jenkins as docker container (ec2) and a new docker repository (ecr)

- Installing jenkins again was a good practise, especially mounting docker again into the jenkins container
    took a while but in the end the pipelines were working again
- Introducing ECR (instead of Nexus or dockerhub) was more of a jenkins challenge
    made some changes in the **devops-bootcamp-08-jenkins** project which were necessary to authenticate with AWS and push images there
- Checked out the project https://gitlab.com/twn-devops-bootcamp/latest/09-aws/java-maven-app and moved it to my github
    It seems like this is actually doable automatically through https://github.com/new/import but I did it another way
        
        git clone https://gitlab.com/twn-devops-bootcamp/latest/09-aws/java-maven-app.git devops-bootcamp-09-aws-java-maven-app

    This short script tracks every branch locally so that it can be pushed through git pull --all later

        #!/bin/bash
        for branch in $(git branch --all | grep '^\s*remotes' | egrep --invert-match '(:?HEAD|master)$'); do
            git branch --track "${branch##*/}" "$branch"
        done

    set origin and push

        git remote remove origin
        git remote add origin git@github.com:TheAbys/devops-bootcamp-09-aws-java-maven-app.git
        git push --all


The pipeline now automatically runs the container on the second ec2 instance.

    docker run -p 3080:8080 -d 561656302811.dkr.ecr.eu-central-1.amazonaws.com/k0938261-training:latest

While in the video port 3080 should be exposed I found that I've still got an image with port 8080 exposed.
After some troubleshooting I've changed the port when running the application and everything works now.

If the port 3080 is used for the container and the host, than obviously the application must run on the defined port.

This solution is
- only really applicable for small applications.
- working great with different clouds (DigitalOcean, Linode, AWS, ...) or self hosted like within the company as it is just a basic ssh access to those servers

For more complexe scenarios a container orchestration tool like Kubernetes is required.

# 8 - Deploy to EC2 server from Jenkins Pipeline - CI/CD Part 2

At first we need to install docker-compose and make it executable

    sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

We can check the version through

    docker-compose --version

Cleanup ec2 instance

    docker ps
    docker stop <container-hash>
    docker rm <container-hash>