---
title: 'Functions with AWS SAM'
slug: functions-with-aws-sam
date: '2026-08-10'
summary: Running your own code in the cloud with AWS Lambda and the Serverless Application Model — a Fibonacci function behind API Gateway, deployed with one command.
---

Previously on this series, we saw [how to host a static website on Amazon S3](https://prodbytes.substack.com/p/static-websites-on-amazon-s3?r=c4tlc&utm_campaign=post&utm_medium=web&showWelcomeOnShare=true) and serve our files: HTML, CSS, JavaScript, images, videos, whatever you want. But keep in mind that S3 will just take the files as they are and ship them to the network, or take content from the network and store it. It will not process anything, it will not execute code in your programming language. For that we need a separate service, and there are different tools to work with it. In this one I'll show you the tool I use a lot, the [AWS Serverless Application Model](https://aws.amazon.com/serverless/sam/), SAM.

> This post is part of the ["Delivering Software Projects"](https://prodbytes.substack.com/p/delivering-projects-on-aws?r=c4tlc) series, focused on helping YOU be sucessful in your tech career. Please consider becoming a member. For a small contribution, you'll help us keep the lights on and have full access to our content, events and tools.

## Getting SAM CLI

You can find the documentation and installation guides on the [AWS SAM page](https://aws.amazon.com/serverless/sam/). If you're using the code we've been working on from the [DSP repository](https://github.com/prodbytes/DSP), you don't need to worry about installing anything: it's already set up through [Devbox](https://www.jetify.com/devbox), as we did when we set up our development environment. Open a terminal, run `devbox shell`, and the AWS SAM CLI is there with all the other dependencies.

From there, `sam help` shows the options. The `init` command creates a new SAM application, and `sam init --help` lists its configuration options. The most important one is the runtime: you can choose your favorite programming language, .NET, [Go](https://go.dev/), [Java](https://www.java.com/), [Node.js](https://nodejs.org/), [Python](https://www.python.org/), [Ruby](https://www.ruby-lang.org/), or even provide your own. For today, let's use Python, which is probably familiar to many developers, and any other language would work quite the same.

## The code: a Fibonacci function

I initialized a project and adjusted the code a little, but it's basically what you get out of `sam init`, plus a small example. We're going to calculate elements of the [Fibonacci sequence](https://en.wikipedia.org/wiki/Fibonacci_sequence), the one where each element is the sum of the previous two. The fifth is the sum of two and three, three is the sum of two and one, and so on. The tenth is 55, which we'll use to check our results.

It's important to understand that this is *your code*. We could be doing anything here: validating data, querying a database, sending messages. A simple calculation just keeps the example focused.

There are many ways to implement Fibonacci. The iterative approach walks the sequence, summing the two previous elements starting from zero and one. The recursive one is my favorite for readability, since it reads just like the definition: Fibonacci of n is Fibonacci of n minus one plus Fibonacci of n minus two, returning zero or one at the base cases. It may not be the most efficient, but it's very expressive. The implementation in our `app.py` uses the [fast doubling method](https://www.nayuki.io/page/fast-fibonacci-algorithms), which is quicker for big numbers; you can read up on it or just use whichever implementation you like.

## The template

The project also comes with a `template.yaml`, and this is a [CloudFormation](https://aws.amazon.com/cloudformation/) template. SAM sits on top of CloudFormation and adds a `Transform` directive at the top. That transform is what turns the SAM template, with conveniences like `Globals` that plain CloudFormation doesn't have, into the final template CloudFormation actually deploys.

A few properties are worth understanding:

- **Timeout and memory.** Here it's 29 seconds to execute, and the memory size is our main cost criteria. The more memory you give a function, the more it costs, in units of gigabyte-seconds. That's the great thing about functions: they only charge for the time they run and the memory you give them.
- **CodeUri** is where the code lives; `sam deploy` packages that and ships it to AWS.
- **Handler** is the function that actually gets executed.
- **Runtime and architecture**, Python 3.14 on x86 in this case, define the container that will execute the code.

The other thing to understand is that code execution is separate from HTTP request handling. The HTTP side is declared as an API event source, handled by [Amazon API Gateway](https://aws.amazon.com/api-gateway/), a separate service from [AWS Lambda](https://aws.amazon.com/lambda/), which handles the execution. API Gateway takes GET requests on the `/fib` path and passes the event to our function. And in `Outputs`, as usual, we expose what the stack generated: the API address so we can call the function, its ARN, and the role with the permissions it has.

## Deploying

The deploy script in the repository is basically a `sam deploy` command. It also runs `sam build` first, using the container provided by SAM, to package the code and check everything is correct. The API URL is fetched just like in the previous episodes, with `describe-stacks` and a query that picks the output by name and returns its value as text.

Run the deploy script and SAM validates the template, uploads the code to S3, and runs the deployment. Meanwhile, you can watch the [CloudFormation console](https://console.aws.amazon.com/cloudformation/): it's a stack in progress like any other, and if anything goes wrong, the events tab is where the errors show up. When it's done, the function appears in the [Lambda console](https://console.aws.amazon.com/lambda/).

One thing you'll notice there is that functions are event-driven. They don't execute out of nowhere; they need to be bound to a trigger that sends them events. Many triggers are supported: an [Alexa](https://developer.amazon.com/en-US/alexa) voice request, API Gateway, a load balancer, [CloudFront](https://aws.amazon.com/cloudfront/) (which we'll see in the future), and many other services can call Lambda. For now we're sticking with API Gateway.

## Calling it, and what it costs

The deploy script prints the URL at the end. Paste it in the browser: Fibonacci of 1 is 1, Fibonacci of 10 is 55, and Fibonacci of 1000 is a really big number. You can check what's the largest Fibonacci your function can compute and how long it takes. And the longer it takes, of course, the more it costs.

On the [Lambda pricing page](https://aws.amazon.com/lambda/pricing/), for my region and architecture, it's $0.0000166667 per gigabyte-second: for every gigabyte of memory you give your function, and every second it executes, you pay that rate. ARM is a little cheaper, which is worth knowing when you pick the architecture.

And that's AWS Lambda with SAM. Remember, it's just calling your code. I'm calculating Fibonacci, but you could be querying a database, sending messages, validating and transforming data, whatever you need. We're going to see a full application in a little while.

What would you run in your first function? Let me know in the comments, and see you in the next one!
