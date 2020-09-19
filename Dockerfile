FROM docker:latest
MAINTAINER Akash Das <akash.das@springml.com>
ADD . /src
WORKDIR /src 
# other commands
RUN chmod +x ./deploy-ohif.sh