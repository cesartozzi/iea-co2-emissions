# CI/CD Setup for Mage Project

## Overview
This guide will help you set up and deploy your Mage project using Docker and Terraform.

## Repository Setup

1. **Create a Parent Folder**:
   Create a parent directory for your Mage project. For example:
   ```bash
   mkdir my_team
   cd my_team
   ```

2. **Start Mage Locally**:
   Use the following command to run Mage locally:
   ```bash
   docker run -it -p 6789:6789 -v $(pwd):/home/src mageai/mageai /app/run_app.sh mage start demo_project
   ```
   Replace `demo_project` with your project name.

3. **Create a Dockerfile**:
   Copy the following template into a new Dockerfile in your parent folder:
   ```dockerfile
   FROM mageai/mageai:latest

   ARG PROJECT_NAME=[project_name]
   ARG MAGE_CODE_PATH=/home/mage_code
   ARG USER_CODE_PATH=${MAGE_CODE_PATH}/${PROJECT_NAME}

   WORKDIR ${MAGE_CODE_PATH}

   COPY ${PROJECT_NAME} ${PROJECT_NAME}

   ENV USER_CODE_PATH=${USER_CODE_PATH}

   RUN pip3 install -r ${USER_CODE_PATH}/requirements.txt
   RUN python3 /app/install_other_dependencies.py --path ${USER_CODE_PATH}

   ENV PYTHONPATH="${PYTHONPATH}:/home/mage_code"

   CMD ["/bin/sh", "-c", "/app/run_app.sh"]
   ```
   Replace all instances of `[project_name]` with your actual project name.

4. **Folder Structure**:
   Your folder structure should look like this:
   ```
   my_team/
   ├── demo_project/
   └── Dockerfile
   ```

5. **Build the Docker Image**:
   Build your custom Docker image:
   ```bash
   docker build --platform linux/amd64 --tag mageprod:latest .
   ```

6. **Test the New Image**:
   Run the following command to ensure the new image works:
   ```bash
   docker run -it -p 6789:6789 mageprod:latest /app/run_app.sh mage start demo_project
   ```

## Push Docker Image to Container Registry

1. **Authenticate with Google Cloud**:
   ```bash
   gcloud auth configure-docker
   ```

2. **Tag Your Image for Google Container Registry (GCR)**:
   ```bash
   docker tag mageprod:latest gcr.io/iea-co2-project/mageprod:latest
   ```

3. **Push the Image to GCR**:
   ```bash
   docker push gcr.io/iea-co2-project/mageprod:latest
   ```

## Update Terraform Configuration

1. **Update Your Terraform Variable**:
   After pushing, update your `docker_image` variable:
   ```hcl
   variable "docker_image" {
     type        = string
     description = "The docker image to deploy to Cloud Run."
     default     = "gcr.io/iea-co2-project/mageprod:latest"
   }
   ```

2. **Re-run Terraform**:
   Run `terraform apply` again to deploy the updated configuration.

## Note
After making changes to your local code or Docker image, remember to:
1. Rebuild your Docker image:
   ```bash
   docker build -t mageprod:latest .
   ```
2. Tag and push the new image to GCR:
   ```bash
   docker tag mageprod:latest gcr.io/iea-co2-project/mageprod:latest
   docker push gcr.io/iea-co2-project/mageprod:latest
   ```
3. Deploy with Terraform:
   ```bash
   terraform apply
   ```

This will ensure that your Cloud Run service uses the latest version of your code.
```

