aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 595063936811.dkr.ecr.eu-central-1.amazonaws.com \
&& docker build -t config-service . \
&& docker tag config-service:latest 595063936811.dkr.ecr.eu-central-1.amazonaws.com/config-service:latest \
&& docker push 595063936811.dkr.ecr.eu-central-1.amazonaws.com/config-service:latest
