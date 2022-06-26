---
title: "A asynchronous Consumer and Producer API for Kafka with FastAPI in Python"
excerpt: "Create a simple asynchronous API that works the same time as a Kafka's producer and consumer with Python's FastAPI library<br/><img src='/images/kafkafastapiasync500x300.png'>"
collection: API
---

Writing asynchronous code might be a little hard the first time you do it, mainly if you're trying to do it as you're working with some other difficult library like Kafka. Altough it's difficult, it's worth the effort when you're dealing with a high load or multiple microservices that can take some time to answer your calls. <br>
The porpuse of this article is to create a simple asynchronous API that works the same time as a Kafka's producer and consumer. The full project it's on my Github. 


# Setting up Kafka

In this tutorial we'll be using Docker to set up Kafka following the [Shuyi Yang's tutorial[1]](https://towardsdatascience.com/kafka-docker-python-408baf0e1088). The docker-compose.yml file used will be:
<script src="https://gist.github.com/vinybrasil/d9c75338af09ac28dd5294687c725cd9.js"></script>
To create it, we can navigate to the folder and write:
<script src="https://gist.github.com/vinybrasil/c7db2d5f8338657d53222e463594f6c7.js"></script>

OBS: I'm using Windows, so commands might differ in Linux distros or MacOS. <br>
We can now create a topic:
<script src="https://gist.github.com/vinybrasil/af9b190c8ae24581798b58ca8c84b0fd.js"></script>

And write some events to it:
<script src="https://gist.github.com/vinybrasil/db2f731a2721f66eed6eef6c7b7bd673.js"></script>

# Creating the API

We'll be using the library aiokafka to deal with Kafka and FastAPI to create the API, as in the awesome tutorial by [iwpnd[2]](https://iwpnd.pw/articles/2020-03/apache-kafka-fastapi-geostream). To simplify, the project will only have one python file called main.py. Importing the necessary libraries:

<script src="https://gist.github.com/vinybrasil/90c1f46bcdbb26d48e1e975713433267.js"></script>

Now, we need to create the FastAPI class and the loop objects.
<script src="https://gist.github.com/vinybrasil/640b7906e41a59260233c4d7968e06f3.js"></script>
The loop object will be referenced in the creating of the Producer and the Consumer classes:
<script src="https://gist.github.com/vinybrasil/8318ea2b98b0e295fe2584f46dc335dd.js"></script>
For the consumer part, we can create a consume function which has the porpouse of printing the message of the topic (and it's proprieties) in the server terminal everytime a new one arrives.
<script src="https://gist.github.com/vinybrasil/14c21dc9f36824e912509b80dfe970cc.js"></script>
Now here's the trick for the function of the consumer runs forever: the consume() funcion must be created at the startup of the API. With that, we guaratee that the function is running all the time.
<script src="https://gist.github.com/vinybrasil/6d1647fa281687c9bd0110813aa61d22.js"></script>
We can now create the POST route that will produce the message when someone calls it. Here we got two classes to standardize the input.
<script src="https://gist.github.com/vinybrasil/aa23381a14eabac560ffeb2ea5fe4e32.js"></script>
And that's it for the API. We can start it using uvicorn:
<script src="https://gist.github.com/vinybrasil/ef37f1eb9639ff4bab08162e247170d5.js"></script>
We can also test it using cURL:
<script src="https://gist.github.com/vinybrasil/ee558010f91b4fe41c7646111ac8e879.js"></script>
It should return something like this:
![Result from the API call as the client](/images/kafkafastapiasyncfig1.png "Result from the API call as the client")
In the server terminal, the results should look like:
![Result from the API call in the server](/images/kafkafastapiasyncfig2.png "Result from the API call in the server")

That's it. Feel free to ask any questions or to contribute in the github repository or in my personal email.

# References

[1] Shuyi Yang. Apache Kafka: Docker Container and examples in Python. Available at https://towardsdatascience.com/kafka-docker-python-408baf0e1088

[2] iwpnd. Apache Kafka producer and consumer with FastAPI and aiokafka. Available at https://iwpnd.pw/articles/2020-03/apache-kafka-fastapi-geostream

