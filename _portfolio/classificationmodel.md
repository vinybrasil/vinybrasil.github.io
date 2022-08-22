---
title: "Deploying a classification model on AWS Lambda with Docker and FastAPI"
excerpt: "Create and deploy a model to classify selfies and IDs photos on AWS Lambda with Tensorflow, FastAPI and Docker<br/><img src='/images/doc550x300_4.png'>"
collection: API
og_image: '/images/doc550x300_4.png'
---

Does the user inserted the correct picture when the app requested? That's a pretty common problem companies faces when creating a onboarding process of a app or a web service. For example, during the onboarding process of a bank the app can ask for a selfie and the user insert a picture of it's ID, for example. Since in those kind of processes there's a huge amount of requests at the same time, a manual validation process can't be used and a machine learning model can be a good alternative. TensorFlow and FastAPI can be used to create that solution.

We need also to deploy the model on the cloud so it can be available to the app. For that, we can use the serverless service AWS Lambda since it has a low cost and we don't need to worry about servers.

In this article a model will be created to classify ID's/driver's licenses photos, selfies and invalid photos using TensorFlow, then a API with FastAPI will be created, it'll be containeraized with Docker and deployed on AWS Lambda. The full repository of the project can be checked [here](https://github.com/vinybrasil/doc_classifier). 

# The data
For the model, three types of images are needed: photos of ID's, selfies and images so called "invalid" ones. 

For the ID's photos we can use the BID Dataset[[1]](https://sol.sbc.org.br/index.php/sibgrapi_estendido/article/view/12997). It is a dataset with photos of brazilian driver's licences and ID's photos with fake data built by brazilian researchers. Below there's a example of these images.

![Result from the API call in the server](/images/doc_classifier_post/rg.jpg "Example of a fake ID photo")

To download the dataset, we can use the following code on Google Colab:

<script src="https://gist.github.com/vinybrasil/c8b35e0ec263bb4e69ace5843e163c9d.js"></script>

For the selfies and invalid photos we can use the Selfie-Image-Detection-Dataset[[2]](https://www.kaggle.com/datasets/jigrubhatt/selfieimagedetectiondataset), which contains selfies and non-selfies/invalid photos.
A example of a selfie

![Result from the API call in the server](/images/doc_classifier_post/selfie_example.jpg "Example of selfie")


and of a invalid image

![Result from the API call in the server](/images/doc_classifier_post/invalid.jpg "Example of selfie")


To download the dataset we can use the Kaggle API using the following code also in Google Colab:

<script src="https://gist.github.com/vinybrasil/cdcc90f5dd2211c7799997456e4d81c6.js"></script>

We now have the full dataset. We can split 80% for the training dataset and the rest for the test dataset.

# Data preparation and the model
We'll use the images in black and white. Also, the photos to be in the same size. We can use Tensorflow to perform these transformations:

<script src="https://gist.github.com/vinybrasil/cdd4987eb6a897da546c17ba38db74e9.js"></script>

The model we'll train to classify the images is a CNN (Convolutional Neural Network) since it can handle pretty well the task of classifition of images. The code of the model is

<script src="https://gist.github.com/vinybrasil/da183c40bd78a7de0b7683062c61f91e.js"></script>

The output of the model is a vector with a score for each class. The softmax function can be used to transform these scores into probabilities. For each $z_{i}$ score of the $i$ class of the K classes, the softmax function can be written as:
<center>
$$\sigma(z_i) = \frac{e^{z_i}}{\sum_{j=1}^{K} e^{z_j}}$$
</center>

We can now save the model using a method of the model class:


<script src="https://gist.github.com/vinybrasil/e6387e2c114dbc5c66d46e13e8102e6b.js"></script>

It will create a folder and it looks like this

![Result from the API call in the server](/images/doc_classifier_post/folder.png "Folder of the model")

The full code for training the model can be checked [here](https://github.com/vinybrasil/doc_classifier/blob/main/notebooks/train_document_classifier.ipynb).

# Creating the API
To serve the model, we need to create an API and we'll use FastAPI because it's a fast and reliable library. 

The overall structure of the project is the following:

<script src="https://gist.github.com/vinybrasil/1bd7dedbe3c9e03edf109dbc5ed38a22.js"></script>

We'll  explain all the files.
The main.py file should look like

<script src="https://gist.github.com/vinybrasil/3babe727bc1416ce74551de54784803e.js"></script>

The classifier route is the one we'll use to make the prediction. It recieves a dictionary containing two keys: the input_photo coded in base64 in a string format and the lead_id key to identification purposes. A example of the request in Python would be:

<script src="https://gist.github.com/vinybrasil/a766ad22a7250a1fabf3f4ae7966637d.js"></script>

We can test the API by running it with uvicorn:

<script src="https://gist.github.com/vinybrasil/c9f5fac99a7026044768bc1109ca5c22.js"></script>

When the request in made, the function calls the predict function of the make_prediction.py file. The function decodes the image, turns it to grayscale, resizes it and call the model to make the prediction. 


<script src="https://gist.github.com/vinybrasil/ba683cba6b0f8eb5ab0cc709802c16a2.js"></script>

The function returns a object of the Prediction class and a hash of the image to be store in a database so we don't need to classify the same image twice. The prediction class is built in the output.py file:


<script src="https://gist.github.com/vinybrasil/d64f584a78a8a5e52f577414c7b3abd0.js"></script>


When the predict function returns the Prediction object, the classifier function of the main.py file combines the Predition object with the lead_id of the original request to build the OutputPrediction object. 
A response would be:

![Result from the API call in the server](/images/doc_classifier_post/result0.png "Result from the API call in the server running locally")

For dependencies management Poetry can be used. It's a package in Python similar to pip. In the root folder we can write

<script src="https://gist.github.com/vinybrasil/237b2fb3c537d11d8841fb77e6d4a5aa.js"></script>

It'll create a pyproject.toml file, where the details of the project can be written. The full file is

<script src="https://gist.github.com/vinybrasil/c9713934f2f52b21ce3c19d9010c4845.js"></script>

With that we can install the API as a python package:

<script src="https://gist.github.com/vinybrasil/aca84061a0ed33c0b226577d09b32d13.js"></script>

In order to deploy on AWS Lambda, we need to create the lambda_function.py file in the root of the projects. It simply loads the app object of the main.py and calls the Mangum library.

<script src="https://gist.github.com/vinybrasil/2043f84db658904e73b4b6015a624f08.js"></script>

And that's it for the API.

# Deploying the API
With API ready, we can now containerize the with Docker. We'll be using the AWS version of Linux on the Docker container. On the Dockerfile we should write:

<script src="https://gist.github.com/vinybrasil/afd0a412b565b72f354b53c8460ceaaa.js"></script>

This implementation is based on the tutorial by AWS[[3]](https://docs.aws.amazon.com/lambda/latest/dg/images-create.html). The LAMBDA_TASK_ROOT is a variable with the value /var/task. 

Before creating the container, a repository in the AWS ECR (Elastic Container Registry) is needed. It can be created on AWS managment tool, searching for ECR, clicking in "create repository" and filling the informations needed.

![Result from the API call in the server](/images/doc_classifier_post/ecr.png "Create repository on ECR")

Following Cardoso's tutorial[[4]]( https://medium.com/dataengineerbr/how-to-run-aws-lambda-locally-on-your-computer-with-docker-containers-533a3add1b45), 
the container can be created by tipyng

<script src="https://gist.github.com/vinybrasil/c78592a37cf9db969c2ec7c982a3ee8a.js"></script>

Tagging the image:

<script src="https://gist.github.com/vinybrasil/c72c3dad3f71ceb7d02d2461e3da1b8a.js"></script>

Give permission to your CLI to access ECR:  [https://docs.aws.amazon.com/lambda/latest/dg/images-create.html]

<script src="https://gist.github.com/vinybrasil/6dd6382c05e0d95ed96c4403843302e6.js"></script>
Pushing it to the repository:

<script src="https://gist.github.com/vinybrasil/c7e7b84d8663eb4e7b0a2eaa8938238b.js"></script>
We can know see the image in ECR:

![Result from the API call in the server](/images/doc_classifier_post/ectr_rep.png "Image on ECR")

The Lambda function can now be created. Searching for "Lambda" in the AWS search bar and clicking in "create function", the following screen should apper:

![Result from the API call in the server](/images/doc_classifier_post/lambda1.png "Create function on Lambda")

By selecting to create the lambda function with a container, the container can be selected in the "browse images" button.

![Result from the API call in the server](/images/doc_classifier_post/lambda2.png "Selecting image to Lambda")

Under "Container image overrides" the variable "/var/task" shall be set in the WORKDIR box.

![Result from the API call in the server](/images/doc_classifier_post/lambda3.png "Small config on the Lambda function")

Finish the creation step by clicking  in the "create function" button. Since the model consumes some memory, we must increase the memory and the timeout limit of the lambda function.

![Result from the API call in the server](/images/doc_classifier_post/lambda4.png "Increase memory and timout limit")

The last step is to set the API Gateway as a trigger so we can call our model with a HTTP request. By searching by "API Gateway" in AWS search bar and clicking in API, we can select to create a new one and to create a HTTP API:

![Result from the API call in the server](/images/doc_classifier_post/papi1.png "Creating API on API Gateway")

The API can now be integrated it with the Lambda function created earlier:

![Result from the API call in the server](/images/doc_classifier_post/papi2.png "Integrating the Lambda function with the API")

The last step is to map the routes of the API Gateway to the routes of the API inside the Lambda function:

![Result from the API call in the server](/images/doc_classifier_post/papi3.png "Routing")

And that's it. By finishing the creation and going back to the lambda function screen, we shall see the following screen:

![Result from the API call in the server](/images/doc_classifier_post/papi35.png "The final Lambda config with the API Gateway")

The routes we created are now related to a URL:

![Result from the API call in the server](/images/doc_classifier_post/papi4.png "URL in the Lambda function")

So now our function can receive HTTP requests in those URLS. Using the following code to test:

<script src="https://gist.github.com/vinybrasil/6e2cd2a6c6fa0f16772a8b56d5803fc4.js"></script>
We shall receive the following response:

![Result from the API call in the server](/images/doc_classifier_post/result1.png "Result from the API call in the Lambda system")


That's it. Our model can know give predictions to photos, everything in the cloud.  Feel free to comment, explore the code on Github or contact me via LinkedIn. Keep on learning :D

# References

[1] BID Dataset: a challenge dataset for document processing tasks.  https://sol.sbc.org.br/index.php/sibgrapi_estendido/article/view/12997

[2] Selfie-Image-Detection-Dataset. https://www.kaggle.com/datasets/jigrubhatt/selfieimagedetectiondataset

[3] Creating Lambda container images. https://docs.aws.amazon.com/lambda/latest/dg/images-create.html

[4] How to run AWS Lambda on your computer using Docker containers. https://medium.com/dataengineerbr/how-to-run-aws-lambda-locally-on-your-computer-with-docker-containers-533a3add1b45