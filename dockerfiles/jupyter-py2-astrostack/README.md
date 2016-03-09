<!--- To render this locally, use `grip --wide` on this file. -->

# A Docker image with the Jupyter Notebook and an astronomical software stack

This `Dockerfile` creates an image that runs a [Jupyter
Notebook](http://jupyter.org/) on port 80 with a sizeable set of preinstalled
astronomical software. It uses the Python 2.7 interpreter.


## Building and running it locally

There’s not much advantage to running a Jupyter Notebook server in a Docker
container on your main work machine, but it’s pretty clearly the first step
for testing and learning the technology. To build the image, you’d run
something like the following in the directory containing this file:

```
$ TAG=$(date +%Y%m%d)
$ docker build --rm -t jupyter-py2-astrostack:$TAG .
```

Then to start a trial instance:

```
$ docker run --rm -p 8888:80 jupyter-py2-astrostack:$TAG
```

You should then have access to a containerized Jupyter Notebook running on
<http://localhost:8888/>. To access any actual data on your local machine,
you’d likely want to provide the `-V` option to the `docker run` command. You
can shut down the server by Control-C’ing it.

To run a persistant instance that runs in the background, do:

```
$ CONTAINERID=$(docker create -p 8888:80 jupyter-py2-astrostack:$TAG)
$ docker start $CONTAINERID
```

And then to shut it down and delete it:

```
$ docker stop $CONTAINERID
$ docker rm $CONTAINERID
```


## Running it with Google’s Container Engine

I created this image because I wanted to see if I could get this setup running
on a cloud-based Docker service. I attempted to do so with Google Cloud
services, namely their [Container
Engine](https://cloud.google.com/container-engine/docs/). **I could *almost* but
not quite get things working.**

There’s a problem with [WebSockets](https://en.wikipedia.org/wiki/WebSocket);
I think what’s going on is that Google’s load-balancing infrastructure doesn’t
allow WebSocket connections to propagate in to the running container. You can
connect see the notebook server’s tree view and create a notebook, but you
can’t actually communicate with a kernel, or run a terminal. For posterity,
here are my notes on how to get things going. Note that Google churns their
infrastructure **very** quickly and instructions like these go out of date
correspondingly quickly.

You need a Google Cloud project that’s got the Compute Engine enabled, which
means you need to enable billing. (If you run `docker` as root, you also need
to make sure that `root` is logged in to you GCloud setup since `gcloud` needs
to sub-invoke `docker`) Then there are other bits to set up that aren’t
documented well. In my local environment:

```
$ export PROJECT_ID=gcloud-docker-testbed
$ /a/google-cloud-sdk/bin/gcloud auth login
$ /a/google-cloud-sdk/bin/gcloud config set project $PROJECT_ID
$ gcloud config set project $PROJECT_ID
$ gcloud config set compute/zone us-central1-a
```

You also need to make sure that the `beta` and `kubectl` components of the
`gcloud` command-line helper are installed (using `gcloud components install`
if needed). Then you build and upload the image. If you already have a built
image, you can use `docker tag` to mark it for upload into the Google Cloud
Repository.

```
$ export IMAGENAME=jupyter-py2-astrostack
$ docker build -t gcr.io/$PROJECT_ID/$IMAGENAME .
$ /a/google-cloud-sdk/bin/gcloud docker push gcr.io/$PROJECT_ID/$IMAGENAME
```

Then deployment onto the Compute Engine:

```
$ export CLUSTERNAME=mycluster
$ export SERVICENAME=myservice
$ gcloud container clusters create $CLUSTERNAME --num-nodes 1 --machine-type g1-small
$ gcloud beta container clusters get-credentials $CLUSTERNAME --project=$PROJECT_ID
$ gcloud compute instances list # just a diagnostic
$ kubectl run $SERVICENAME --image=gcr.io/$PROJECT_ID/$IMAGENAME --port=80
$ kubectl expose rc $SERVICENAME --type=LoadBalancer
```

Wait for a bit then get IP address for load balancer / replication controller:

```
$ kubectl get services $SERVICENAME
```

Then you can actually do stuff (potentially after waiting for another bit). Then clean up:

```
$ kubectl delete services $SERVICENAME
$ kubectl delete rc $SERVICENAME
$ gcloud container clusters delete $CLUSTERNAME
```
