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