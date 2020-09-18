#!/bin/bash
client_id=
host_name=
image=
project=
image_tag=
usage()
{
    echo "usage: sysinfo_page [[[-id oauth_client_id ] [-i]] | [-h]]"
}
while [ "$1" != "" ]; do
    case $1 in
        -id | --client_id )     shift
                                client_id=$1
                                ;;
        -host | --host_name )   shift
		                        host_name=$1
                                ;;
	    -p | --project ) 	    shift
		                        project=$1
				                ;;
	    -n | --image_name )	    shift
				                image=$1
				                ;;
	    -t | --image_tag )	    shift
				                image_tag=$1
				                ;;
        -ip | --external_ip )   shift
                                external_ip=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

echo "Setting infra using terraform"
terraform plan 

replace_statement='s/OAUTH_CLIENT_ID/'$client_id'/g'
hostname_replace='s/HOST_NAME/'$host_name'/g'

sed -i $hostname_replace OHIF/platform/viewer/.webpack/webpack.pwa.js
echo "Assigned Hostname"
sed -i $replace_statement OHIF/platform/viewer/public/config/google.js
echo "Assigned ClientID"

project_replace='s/PROJECT/'$project'/g'
image_replace='s/IMAGE/'$image'/g'
tag_replace='s/TAG/'$image_tag'/g'
externalip_replace='s/IPADDRESS/'$external_ip'/g'

sed -i $image_replace GKE-deployment/deployment.yaml
echo "Placed image name in deployment"
sed -i $project_replace GKE-deployment/deployment.yaml
echo "Placed project name in deployment"
sed -i $tag_replace GKE-deployment/deployment.yaml
echo "Fixed tag in deployment"
sed -i $externalip_replace GKE-deployment/service.yaml
echo "Fixed external ip in service"

docker build -t gcr.io/$project/$image:$image_tag OHIF/
docker push gcr.io/$project/$image:$image_tag

kubectl apply -f GKE-deployment/deployment.yaml
kubectl apply -f GKE-deployment/service.yaml

default_client='s/'$client_id'/OAUTH_CLIENT_ID/g'
default_hostname='s/'$host_name'/HOST_NAME/g'

sed -i $default_hostname OHIF/platform/viewer/.webpack/webpack.pwa.js
sed -i $default_client OHIF/platform/viewer/public/config/google.js

default_project='s/'$project'/PROJECT/g'
default_image='s/'$image'/IMAGE/g'
default_tag='s/'$image_tag'/TAG/g'
default_ip='s/'$external_ip'/IPADDRESS/g'

sed -i $default_image GKE-deployment/deployment.yaml
sed -i $default_project GKE-deployment/deployment.yaml
sed -i $default_tag GKE-deployment/deployment.yaml
sed -i $default_ip GKE-deployment/service.yaml
