# Newstack Testdrive Repository

This repo has scripts to spin up newstack in Pure Storage's test drive

It currently works with Ansible and Kubernetes

Many thanks are due to kbkuebler for the idea, as well as ansible yaml files.

# Kubernetes with PSO Demo.

The following files are in the kube_yaml directory

## Installing the demo
clone the repo with:
'''
git clone https://puresealab/newstack_testdrive
'''

Run the install.sh script

Note that this will also install all of the ansible bits

## Running the Demo

### Create the PVC. Check that it is created on the Pure
'''
kubectl apply -f 1_createPVC.yaml
'''

### Creates Minio Deployment
'''
kubectl apply -f 2_minio.yaml

kubectl apply -f 3_service.yaml
'''

You can now log in to minio using the service port. Find the port with the kubectl get svc (should always be 9000) command. http://<linuxIP>:<port> Username/password: minio:minio123

Continuing with the rest of the commands, which will take a snap and clone a new PVC from that snapshot
You can then continue with spinning up a new minio instance (default will be port 9001)

**Don't forget that adding the snapshot spec adds the below object type**
'''
kubectl get VolumeSnapshots
'''

For a snap restore demo, you can scale to 0 replicas, restore the snap, and scale replicas to 1. The command to scale replicas is:
kubectl scale deploy minio-deployment --replicas=0

** NOTE: ** Both arrays are present in the PSO config, so your PVC may go to the second array

# Ansible Demo


## Installing the demo
clone the repo with:
'''
git clone https://puresealab/newstack_testdrive
'''

Run the install.sh or install_ansibleonly.sh script

I would also run:
'''
source ~/.bashrc
'''

## Running the Demo

This demo allows the driver to run playbooks in the ansible_playbooks directory. They are numbered to run through a progression.

You can run each playbook with 'ansible-playbook <yaml file>'

More notes to come.
