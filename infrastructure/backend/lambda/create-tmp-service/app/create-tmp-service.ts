import axios from "axios";

const SSMClient = require('aws-sdk/clients/ssm');
const ssm = new SSMClient({region: 'eu-central-1'});

type CreateTmpServiceRequest = {
    userId: string,
    serviceId: string,
    currDateTime: string
}

const getParameter = async (name: string) => {
    const params = {
        Name: name,
        WithDecryption: true
    };
    const data = await ssm.getParameter(params).promise();
    return data.Parameter.Value;
};


/*
Better extract parameter
 */
const BUILD_BRANCH = "main"
const ECS_TF_BACKEND_BUCKET = "ecs-tmp-services-global-remote-backend";
const ECS_TF_BACKEND_KEY = "live/ecs-tmp-services/prod/backend/ecs/terraform.tfstate";
const ECR_TF_BACKEND_BUCKET = "ecs-tmp-services-global-remote-backend";
const ECR_TF_BACKEND_KEY = "live/ecs-tmp-services/prod/registry/ecr/terraform.tfstate";

const invokePipeline = async (url: string, userId: string, serviceId: string) => axios.post(url, {
    "TF_VAR_user_id": userId,
    "TF_VAR_service_id": serviceId,
    "TF_VAR_ecs_tf_backend_bucket": ECS_TF_BACKEND_BUCKET,
    "TF_VAR_ecs_tf_backend_key": ECS_TF_BACKEND_KEY,
    "TF_VAR_ecr_tf_backend_bucket": ECR_TF_BACKEND_BUCKET,
    "TF_VAR_ecr_tf_backend_key": ECR_TF_BACKEND_KEY,
});

exports.handler = async (event: CreateTmpServiceRequest, context: any): Promise<any> => {
    try {
        console.log(JSON.stringify(event));

        const {userId, serviceId, currDateTime} = event;
        console.log(`Invoking pipeline for user ${userId} and service ${serviceId} - ${currDateTime}`);
        const url = `https://gitlab.com/api/v4/projects/37959564/ref/${BUILD_BRANCH}/trigger/pipeline?token=${await getParameter("/gitlab/token")}`
        await invokePipeline(url, userId, serviceId);

        return "Finished";
    } catch (e) {
        console.error(e);
        return JSON.stringify({message: e.message})
    }
};
