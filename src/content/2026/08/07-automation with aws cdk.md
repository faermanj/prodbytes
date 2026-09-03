---
title: 'Automation with AWS CDK'
slug: automation-with-aws-cdk
date: '2026-08-07'
summary: Building CloudFormation templates with a real programming language — deploying the same static website with the AWS CDK and Python instead of YAML.
---

Next, let's look at the [AWS Cloud Development Kit](https://aws.amazon.com/cdk/), the CDK, which lets us develop CloudFormation templates using our favorite programming language instead of YAML or JSON. [Java](https://www.java.com/), [Python](https://www.python.org/), [Go](https://go.dev/), [TypeScript](https://www.typescriptlang.org/), whatever you like. In this one, we'll deploy the same static website [from the CloudFormation episode](../automation-with-aws-cloudformation/), but written in Python.

> This post is part of the ["Delivering Software Projects"](https://prodbytes.substack.com/p/delivering-projects-on-aws?r=c4tlc) series, focused on helping YOU be sucessful in your tech career. Please consider becoming a member. For a small contribution, you'll help us keep the lights on and have full access to our content, events and tools.

## What the CDK is

You can find the CDK at [aws.amazon.com/cdk](https://aws.amazon.com/cdk/), and it's also an open source project. On [GitHub, under aws/aws-cdk](https://github.com/aws/aws-cdk), you have the source code, the issues, the pull requests, and you can even join the project if you'd like.

The idea is that the CDK helps you build CloudFormation templates and deploy your infrastructure using other languages. It's built on top of [JSII](https://github.com/aws/jsii), another project from AWS, and that one is interesting on its own: it generates the bindings from TypeScript to other languages. So if you're building something and want to expose functionality to clients in several different languages, JSII might be useful for you too. Instead of rewriting things in Java, Python, TypeScript, and so on, you generate the implementations from one codebase. The largest usage of it is probably the CDK itself.

## Getting started

Installing is simple, it's an [npm](https://www.npmjs.com/package/aws-cdk) package:

```bash
npm install -g aws-cdk
```

Running `cdk help` shows all the supported commands, like `import`, `deploy`, `rollback`, and so on. Let's get started with `init`, which sets up a new project, and with `-l` we choose the language:

```bash
cdk init -l python
```

This creates a project in the current directory, including a Python virtual environment, and the README lists all the commands we need to run it. Activate the environment, install the requirements (that only needs to be done once), and we're ready.

Before synthesizing anything, take a look at the source code. In the package with the same name as the project, there's the code for our stack, and instead of YAML, it's Python. The generated project comes with a commented-out example for an [Amazon SQS](https://aws.amazon.com/sqs/) queue. Uncomment it and add something ridiculous, like a visibility timeout of 333, just to prove the template is being generated from our code:

```python
queue = sqs.Queue(
    self, "CdkDemoQueue",
    visibility_timeout=Duration.seconds(333),
)
```

Then `cdk synth` synthesizes the CloudFormation template. The output has support for multiple regions and some extra metadata, and most importantly, the queue has exactly the visibility timeout we specified. We're building with our favorite language, its module system, its libraries, whatever we want to bring in, and in the end we have a CloudFormation template we can deploy.

## The website stack in Python

The example lives in the [DSP repository](https://github.com/prodbytes/DSP), under [samples/static-website-simple/cdk](https://github.com/prodbytes/DSP/tree/main/samples/static-website-simple/cdk), next to the CloudFormation and Bash versions of the same website. The stack is the same idea we've been doing before, but in Python:

```python
website_bucket = s3.Bucket(
    self, "WebsiteBucket",
    website_index_document="index.html",
    public_read_access=True,
    block_public_access=s3.BlockPublicAccess(
        block_public_acls=False,
        block_public_policy=False,
        ignore_public_acls=False,
        restrict_public_buckets=False,
    ),
    removal_policy=RemovalPolicy.DESTROY,
    auto_delete_objects=True,
)
```

The same properties from the previous episodes: the index document, allowing public read access, relaxing the public access block. Something different here is that the CDK can also deploy content to S3. With the [`s3_deployment` module](https://docs.aws.amazon.com/cdk/api/v2/python/aws_cdk.aws_s3_deployment.html), the copying of the files happens directly in the stack, without doing it in the script as we did for CloudFormation:

```python
s3_deployment.BucketDeployment(
    self, "WebsiteDeployment",
    sources=[s3_deployment.Source.asset("../hello-website/")],
    destination_bucket=website_bucket,
)
```

That bucket deployment is quite useful. And then the output with the website URL, just like the `Outputs` section in the YAML template:

```python
CfnOutput(
    self, "WebsiteURL",
    value=website_bucket.bucket_website_url,
)
```

## Deploying

As usual, there's a deploy script in the `scripts` folder, and it's just a few lines. The usual Python stuff, creating the virtual environment and installing the requirements, and then the two important commands:

```bash
npx cdk bootstrap
npx cdk deploy --require-approval never --outputs-file cdk-outputs.json
```

The `bootstrap` step creates resources for the CDK to work: a bucket for the source files, the required policies, and things like that. It only needs to happen once per account and region. Once bootstrapping is complete, `cdk deploy` generates the template from our code and deploys it to AWS. The script prints the website URL at the end, click it, and there's the same website with the same behavior we've been using.

Over on the [CloudFormation console](https://console.aws.amazon.com/cloudformation/), the bucket stack is just a regular CloudFormation stack, nothing different or special about it. You can even see the template that was generated from our code. A little more metadata, but all in all, just a CloudFormation template with the settings to have a public website running.

Destroying is one command, `cdk destroy`, and since the bucket was declared with `auto_delete_objects=True`, the CDK takes care of emptying it first. One less thing for the destroy script to do.

## YAML or code?

Some people prefer YAML, some people prefer Python, some prefer Java. Each one will be better according to your context, so take your favorite. The most important difference is that this is not a static declaration, but something that gets executed. You can read environment variables, fetch secrets, do loops and conditionals, whatever you need. It's your code. We'll go further into the CDK in other examples; it's a great tool.

That's the CDK deploying our static website. What do you think, is it better in a proper programming language, or do you prefer CloudFormation in YAML? See you in the comments and in the next one!
