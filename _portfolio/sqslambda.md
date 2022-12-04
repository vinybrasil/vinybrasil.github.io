---
title: "Trigger a AWS Lambda with a SQS message with Python"
excerpt: "Comunicate your microsservices with a messaging service<br/><img src='/images/sqslambdalogo.png'>"
collection: API
og_image: '/images/sqslambdalogo.png'
---

# Introduction

In the context of microservices, the communication of them must be fast and realiabe. This communication can be through messages and a tool for this communication can be SQS (Simple Queue Service), a messaging service by AWS. 

This project will be a example of a system that can receive a SQS message from a client, process it, and give the information to another client. As a example of this process, we'll create a microservice in a AWS Lambda that will act when receive a SQS message. It'll write the message in a .txt file and return all the messages when receives a HTTP call to a certain endpoint. We'll be using AWS Lambda because it is a serverless framework, in which the idea is you don't have to worry about servers. 

Python's library FastAPI will be used to create the API, Docker to containerize it and Poetry will be the library manager. As always, the [code of the project is on my Github](https://github.com/vinybrasil/triggersqs).

# Building the API
We'll be using FastAPI as the backend tool for this project. The package has a simple syntax and makes easy to create APIs. To create a health check route: 
<script src="https://gist.github.com/vinybrasil/85cb21e46bea92ed8618bbdd0c5ab2b6.js"></script>

Calling the file main.py, Uvicorn can run this API by running the following code:

<script src="https://gist.github.com/vinybrasil/a495cea0f89143eeda37918161abe22b.js"></script>

Inside the main.py file, we'll create another route called "/records". When the API receives a SQS message, it writes it down on a .txt file called "log.txt". The new route retrives all of the messages in the file. The full "main.py" will be

<script src="https://gist.github.com/vinybrasil/2f5457e57bf3fcf699b66924ab7cbb2d.js"></script>

# Creating the SQS handler

To create the SQS handler, we first need to undestand how our Lambda will receive the SQS message. It will come in a JSON like this

<script src="https://gist.github.com/vinybrasil/08d61e9f7e169ccd09783f7c7510b282.js"></script>

There's a few details here. First of all, the eventSourceARN, which is the address of the SQS Queue. The second is the body of the message. For this example, we want to receive messages in the format of 

<script src="https://gist.github.com/vinybrasil/2f2f7137da5adf99622a080bf0fa4965.js"></script>

A parser must be created to extract the data and put it in a object called Message. 

<script src="https://gist.github.com/vinybrasil/07b32d56cde547e93dfc5f2dfdd464bf.js"></script>

The ideia is to create a object which will be receiving a ARN_SOURCE variable, the ARN of the SQS queue. It will only try to parse the messages from that queue and will try to parse based on the Message Class in the function parse_messages. If it can, will return an object of the Message Class. Replace the ARN_SOURCE variable with the one will create in a moment. Our handler will be then

<script src="https://gist.github.com/vinybrasil/1770618d555e250edecdef5bb3babaf5.js"></script>

It will try to parse the messages and write it down to a log.txt file. 
The full sqs_handler.py will be
<script src="https://gist.github.com/vinybrasil/7ddc54da1b8f1c598f33bb5f5df1472e.js"></script>

That's it for the API. We need to create the lambda_handler.py now

<script src="https://gist.github.com/vinybrasil/5fdf273e02354900baf6bb88ab949cb9.js"></script>

Everytime it receives a event, it will check if it's a HTTP request (which Mangum will handle) or if it's a SQS message (which our handler sqs_handler.py will handle).
The final structure of the project will be

![final structure of the projec](/images/sqslambda/img1.png "Final structure of the project")

To handle our dependencies, we can use poetry
<script src="https://gist.github.com/vinybrasil/dfba275fa3527ac52e1216a1a4433005.js"></script>

We can use Docker to containerize the project

<script src="https://gist.github.com/vinybrasil/8b1cdbd329c1e0370c8e0e97c91d618d.js"></script>

# Creating the ECR and the SQS Queue

To deploy the package to a AWS Lambda, we first need to create a repository and upload the image.
We can also create the SQS object here. Export your AWS Account Id to a enviroment variable 
called AWSACCOUNTID and run:


<script src="https://gist.github.com/vinybrasil/0f5f9d3164bca6a8b136f21cdc5ae54d.js"></script>

# Creating the Lambda

We can create the Lambda in a lot a different ways, from the CLI or using some Infra as a Code
tool (like Terraform). I strongly
recommend the use of Terraform, mainly because you can replicate the same infrastructure in many 
different enviroments.  For this tutorial we'll be using the management console, mainly because of the simplicity.

A Lambda function can be created on the AWS Lambda page:

![final structure of the projec](/images/sqslambda/lambda1.png "Final structure of the project")

Our Lambda will use the container created before:

![final structure of the projec](/images/sqslambda/lambda2.png "Final structure of the project")

We need to give access to the SQS in the role of the Lambda. We can do this by adding:
![final structure of the projec](/images/sqslambda/lambda3.png "Final structure of the project")

An alternative is to add full access to the SQS services on the role of the Lambda. By finding the role of the Lambda, we need to attach the following policy:

![final structure of the projec](/images/sqslambda/lambda5.png "Final structure of the project")


Our final Lambda should look something like this:
![final structure of the projec](/images/sqslambda/lambda4.png "Final structure of the project")

# Testing
To test it, we can test it using the Test tab on the same Lambda 
page we are working. First, we need to test receving a SQS message:

![final structure of the projec](/images/sqslambda/lambda8.png "Final structure of the project")

Now a API call to the endpoint /records to get all the messages:
![final structure of the projec](/images/sqslambda/img6.png "Final structure of the project")

The response should be
![final structure of the projec](/images/sqslambda/lambda12.png "Final structure of the project")

That's it. Feel free to ask me any questions, explore the code on Github or contact me via LinkedIn. Keep on learning :D
