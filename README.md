You will need those applications:
- [Docker](https://docs.docker.com/get-docker/)
- [Kubectl CLI](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [Helm CLI](https://helm.sh/docs/intro/install/)
- [Azure Function Tools CLI](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=windows%2Cisolated-process%2Cnode-v4%2Cpython-v2%2Chttp-trigger%2Ccontainer-apps&pivots=programming-language-csharp#install-the-azure-functions-core-tools)

## IMAGE CREATION ON CONTAINER

The first thing you must do is to create a project for any Azure Function. For this current example, we will work with a simple HttpTrigger function.

Once we have the project created (and runnable), we go for the next step: dockerize it. You only need to define the Dockerfile as must be for an azure function. The main difference with other kind of project is that you will use the 'dotnet isolated' repository:

```mcr.microsoft.com/azure-functions/dotnet-isolated:4-dotnet-isolated8.0```

The, we need to store our new image for docker in a right repository. You can use any type that you want:
- [ACR](https://azure.microsoft.com/es-es/products/container-registry) (Azure Container Registry)
- [Docker Hub](https://hub.docker.com/)
- Local repository, for testing purposes [(see LOCAL REPOSITORY...)](/#local-repository)




### <a name="local-repository"></a> LOCAL REPOSITORY

If you have a local Docker instance (like [Docker Desktop](https://www.docker.com/products/docker-desktop/), [Rancher](https://rancherdesktop.io/),.. ) you can easily test that your current function is ready to be used into a Kubernetes cluster.

The first thing you must do is to ensure you have a 'registry container' simulator on docker. For it, you need to create a local registry repository. Next statement will download all the things you need to install and run it under a particular port (mapping 5100:5000 in this case).

```docker run -d -p 5100:5000 --name registry registry:2.7 ```

To install the right image into the local repository, you can build the Dockerfile executing:

```docker build . -f .\src\AzFunction.Http\Dockerfile -t localhost:5100/azfunctionhttp```

**NOTE**: If you create the image from VisualStudio is probably that it couldn't be placed in the registry, so you need to be sure that it is in the right place. If not, you can execute those lines to put it there:

```
    docker tag azfunctionhttp:latest <CONTAINER_REGISTRY_HOSTNAME>/azfunctionhttp:latest
    docker push <CONTAINER_REGISTRY_HOSTNAME>/azfunctionhttp:latest
```


### KUBERNETES INSTALL

#### _Using HELM_
You need to define a chart that will install the repository from Docker container.

Execute the next statement to install via HELM:

```
helm upgrade --install az-func-http deploy/charts/az-func-http --namespace azfunctest --create-namespace
```

<br/>

## CHECK IT OUT!
Search for the current pod, extrac the information and navigate through a browser to check the Http Function.

```
http://localhost:54990/api/MyHttpFunction
```

Enjoy it!