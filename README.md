
## Deploying OHIF Medical Viewer to GKE Cloud Healthcloud Integrated

**Prerequisites**

- GKE cluster access
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) 
- OAuth Client ID

Run the following command to deploy everything in the cluster.

    $ chmod +x deploy-ohif.sh
    $ ./deploy-ohif.sh -id [OAUTH_CLIENT_ID] -ip [IP/Hostname] -p [GCP_PROJECT] -n [NAME_OF_IMAGE] -t [TAG]

To Create OAuth Client ID follow the steps [here](https://docs.ohif.org/connecting-to-image-archives/google-cloud-healthcare.html).

NOTE - 

 - For IP/Hostname you need to provide the domain name where you are planning to host the server.
 - To enable pulling the images from GCR via the GKE please follow the link [here](https://blog.container-solutions.com/using-google-container-registry-with-kubernetes)
 - To enable the pushing of images into GCR repositiory.
	$ gcloud auth application-default login
    $ gcloud auth configure-docker
	 

After doing the above steps check the k8s service -

    $ kubectl get svc ohif-service
Note the load balancer IP. 
To access the OHIF viewer you need to setup a domain name. For this you need to either register a domain name or create an entry within your local /etc/resolv.conf like-

    loadbalancer_ip				HOSTNAME

Now you can access your OHIF viewer via **HOSTNAME:3000**.


