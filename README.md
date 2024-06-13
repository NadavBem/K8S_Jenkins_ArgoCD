# K8S_Jenkins_ArgoCD - project
This project showcases how Kubernetes, Jenkins, DockerHub, ArgoCD, and GitHub work together. Its aim is to automate the deployment process of a basic Flask application using CI/CD. Whenever modifications are made to the app.py file on GitHub, Jenkins constructs a Docker image, uploads it to DockerHub, and then modifies the deployment.yaml file. This triggers ArgoCD to deploy the updated application to the Kubernetes cluster.

  ![Diagram](https://github.com/NadavBem/K8S_Jenkins_ArgoCD/blob/main/assets/Diagram.png?raw=true)
  
  
## Plugins Used
- **Docker Plugin**
- **Docker-build-step**
- **Git Plugin**
- **GitHub Plugin**


## Project Workflow

1. **Setup Kubernetes Cluster**
    - Created a Kubernetes cluster using minikube.
      
    ![minikube](https://github.com/NadavBem/K8S_Jenkins_ArgoCD/blob/main/assets/minikube%20start.png?raw=true)

2. **Run Jenkins Container**
    - Started Jenkins container using image created by the docker file (attached in the repo).
    - I created the image of jenkins that support docker commands to use them on the pipeline (docker build . -t <imagename>). 
    - run the following commands: 
    
    ```sh
    docker run -p 9090:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock <imagename> 
    docker exec -it -u root <container name> /bin/bash
    chown root:docker /var/run/docker.sock
    ```
    - now i was able to run jenkins locally on my local host and access it via the web server

3. **Configure ArgoCD**
    - This will create a new namespace, ArgoCD, where Argo CD services and application resources will live.
    ```sh
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    ```

    - how to get the url of the ArgoCD? 
    ```sh
    kubectl get svc -n argocd
    kubectl port-forward svc/argocd-server -n argocd 8080:443
    ```

    - ArgoCD username : admin
    -how to get the ArgoCD password?
    ```sh
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
    ```

4. **Connect Jenkins to GitHub**
    - Set up a GitHub webhook and configured Jenkins credentials to trigger the pipeline upon a commit 
    - Used Ngrok to expose Jenkins to the public for GitHub webhook integration.
    - **Note that each time Ngrok is restarted, the URL changes, requiring updating the webhook in GitHub accordingly.**

5. **Connect Jenkins to DockerHub**
    - create Docker Hub credentials in Jenkins using a username and password (make sure that the password is TOKEN , and now your github password)
![credential](https://github.com/NadavBem/K8S_Jenkins_ArgoCD/blob/main/assets/Credentials.png?raw=true)


6. **Configure Jenkins Pipeline [jenkinsfile]**
    - Checkout:
        - Purpose: This stage ensures that the latest code from the specified branch in the GitHub repository is checked out for further processing.
        - Steps:
        - It retrieves the author's name of the last commit made to the repository.
        - If the author is identified as "Jenkins", it skips the build to avoid infinite loops where Jenkins continuously builds itself.
        - It then proceeds to checkout the code from the specified branch in the GitHub repository using the provided credentials.

    - Build Docker Image:
        - Purpose: This stage builds a Docker image of the Flask application using the Dockerfile present in the repository.
        - Steps:
        - It utilizes Docker's build functionality to construct the Docker image with the specified tag.
    
    - Push to DockerHub:
        - Purpose: This stage pushes the built Docker image to DockerHub for storage and distribution.
        - Steps:
        - It uses Docker's registry functionality along with DockerHub credentials to authenticate and push the Docker image.

    - Update Kubernetes Deployment.yaml:
        - Purpose: This stage updates the Kubernetes deployment manifest file (deployment.yaml) with the latest version of the Docker image.
        - Steps:
        - It employs a sed command to replace the existing image tag in the deployment.yaml file with the newly built Docker image's tag.
        - Then, it commits this change to the GitHub repository, using "Jenkins" credentials to authenticate, along with the provided username and password.
        - Finally, it pushes the updated deployment.yaml file to the GitHub repository's main branch.

8. **Deployment Verification**
    - Verified the deployment using the ArgoCD interface, ensuring new pods replace the old ones.

    - **So ,How can I access the Flask application after the deployment?** 
    ```sh
    kubectl port-forward pod/<pod name> 5000:80 -n <name space>
    ```
    ![port-forward](https://github.com/NadavBem/K8S_Jenkins_ArgoCD/blob/main/assets/Flask%20port-forward.png?raw=true)
   
    - run http://localhost:5000
    
    ![app](https://github.com/NadavBem/K8S_Jenkins_ArgoCD/blob/main/assets/Flask%20app.png?raw=true)


## Troubleshooting

### Docker Commands Not Found
    - Issue: Jenkins container did not recognize Docker commands.
    - Solution: started the Docker daemon manually.

### GitHub Webhook and Localhost Issues
    - Issue: Webhook did not work due to Jenkins running on localhost.
    - Solution: Used Ngrok to expose Jenkins to the public and allow GitHub to trigger the webhook.

## Summary
The pipeline workflow begins by checking out the latest code from a GitHub repository. It then builds a Docker image of a Flask application, pushes it to DockerHub, and updates the Kubernetes deployment manifest file with the new image version. Finally, it commits and pushes this change back to the GitHub repository.
The outcome of the pipeline is an automated deployment of the Flask application on a Kubernetes cluster. Whenever changes are made to the app.py file and pushed to GitHub, Jenkins automatically triggers the pipeline, ensuring that the latest version of the application is built, deployed, and updated in the Kubernetes cluster without manual intervention.

Following the pipeline's completion, ArgoCD takes over, detecting changes in the Git repository's Kubernetes manifests. It then synchronizes the live state of the application with the desired state specified in the Git repository. This ensures that any updates pushed through the pipeline are automatically deployed to the Kubernetes cluster, maintaining consistency between the defined configuration in Git and the actual running application.

![argocd](https://github.com/NadavBem/K8S_Jenkins_ArgoCD/blob/main/assets/ArgoCD.png?raw=true)

