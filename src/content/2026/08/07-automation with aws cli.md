---
title: 'Automation with the AWS CLI'
slug: automation-with-aws-cli
date: '2026-08-07'
summary: Getting started with the AWS command line interface — configuring credentials with IAM access keys and deploying our static website with a repeatable shell script.
---

Let's start talking about automation, beginning with the [AWS Command Line Interface](https://aws.amazon.com/cli/). Automation is important first to save you time, so you don't have to click and drag through elements in the [AWS console](https://aws.amazon.com/console/). And when you go more professional and have to manage several different systems and environments, it becomes essential. In this one, we'll get started with the AWS CLI and use it to deploy the static website we built [in the last episode](../static-websites-on-s3/).

> This post is part of the ["Delivering Software Projects"](https://prodbytes.substack.com/p/delivering-projects-on-aws?r=c4tlc) series, focused on helping YOU be sucessful in your tech career. Please consider becoming a member. For a small contribution, you'll help us keep the lights on and have full access to our content, events and tools.

## Installing the CLI

Everything about the tool lives on the [AWS CLI page](https://aws.amazon.com/cli/), with installers for Linux, macOS, and Windows. Pick whichever fits your machine, or install it with [Devbox](https://www.jetify.com/devbox) like we set up in the [devbox episode](../devbox-setup/). Once installed, open a terminal (in [VS Code](https://code.visualstudio.com/), that's Terminal, New Terminal) and the command is just `aws`.

The CLI is organized in subcommands, one per service: S3, EC2, and everything else we may need. For example, to list all the buckets in your account:

```bash
aws s3 ls
```

Mine returns nothing right now, because I destroyed the bucket at the end of the last episode. Which is exactly what we expect.

## Configuring credentials

If this is your first time, the CLI doesn't know who you are yet. The simplest way to set that up is:

```bash
aws configure
```

It asks for an access key pair, and to get one we go to [IAM](https://aws.amazon.com/iam/), Identity and Access Management. It's a key service for authentication and authorization on your AWS account. Under IAM users, create a new user (I called mine `julio-cli`). For permissions, you can add the user to a group, copy permissions from another user, or attach policies directly. I'm giving this user administrator access, which lets it do basically anything. That's convenient for now, but you should choose or compose a policy that fits your case; we'll see how to write IAM policies in future episodes.

With the user created, go to its security credentials and create an access key for the command line interface. There are alternatives, like `aws login` and single sign-on setups, and we'll cover those in future videos too, but access keys are still what many companies use, so let's start there. Copy the access key ID and the secret access key into the `aws configure` prompts, pick a default region, and a default output format (JSON, text, or table).

To check it worked:

```bash
aws sts get-caller-identity
```

This shows who you are according to AWS. If it returns the user you just created, you're authenticated correctly.

## Scripting the deployment

You can run commands one by one like this, but the real value comes from grouping them in a shell script, so the whole thing becomes repeatable and testable. The example lives in the [DSP repository](https://github.com/prodbytes/DSP), under [samples/static-website-simple/bash](https://github.com/prodbytes/DSP/tree/main/samples/static-website-simple/bash), as a `deploy.sh` that publishes the same website from the last episode. Let's walk through it.

First, the script figures out where it's running:

```bash
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
BUCKET_NAME="static-website-simple-${ACCOUNT_ID}"
REGION="$(aws configure get region)"
```

We just used `get-caller-identity`, but here it has two extra flags. The `--query` option filters the response to just the field I want, using [JMESPath](https://jmespath.org/) expressions, and `--output text` returns it as plain text instead of a quoted JSON string. That gives me the account ID, which goes into the bucket name to make sure it doesn't clash with a bucket in someone else's account. The region comes from `aws configure get region`, the same one you set during configuration.

The script also resolves its own directory (not the directory you happen to be in) to find the `hello-website` content next to it, the HTML file and the cat picture we want to deploy.

Then it checks whether the bucket already exists with `aws s3api head-bucket`. If it does, we go straight to uploading; if not, we create it and configure it the same way we did in the console, but now automatically:

```bash
aws s3api create-bucket --bucket "${BUCKET_NAME}"

aws s3api put-bucket-website --bucket "${BUCKET_NAME}" \
  --website-configuration \
  '{"IndexDocument": {"Suffix": "index.html"}, "ErrorDocument": {"Key": "index.html"}}'
```

Next comes public access. Remember the acknowledgement we clicked in the console? Public objects are denied by default, so the script explicitly relaxes the public access block. This is me saying I know what I'm doing: I'm serving a website, and public is the point.

In the previous episode we set permissions on each object individually. This time we attach a bucket policy that makes every object public in one statement:

```bash
aws s3api put-bucket-policy --bucket "${BUCKET_NAME}" --policy "{
  \"Version\": \"2012-10-17\",
  \"Statement\": [{
    \"Sid\": \"PublicReadGetObject\",
    \"Effect\": \"Allow\",
    \"Principal\": \"*\",
    \"Action\": \"s3:GetObject\",
    \"Resource\": \"arn:aws:s3:::${BUCKET_NAME}/*\"
  }]
}"
```

Resources in AWS are identified by [Amazon Resource Names](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference-arns.html), or ARNs. This is the ARN for an S3 bucket, in its shorter form, followed by `/*`, meaning all the objects within it. The statement allows any principal to `GetObject` on those objects, which is what makes it a public website.

Finally, the upload and the address:

```bash
aws s3 sync "${CONTENT_DIR}" "s3://${BUCKET_NAME}" --delete
```

The `sync` command synchronizes the content directory with the bucket, and `--delete` removes anything in the bucket that's no longer in the source, so old files don't linger. The script then prints the website URL. Run it, and you'll see the bucket being created, the website hosting enabled, the policy applied, and the files uploaded. Click the link and there it is, our public website, exactly as we built it. Here it's a simple page, but feel free to make yours as complex as you need.

## Don't forget to destroy

All of this has costs, so the same folder has a `destroy.sh`, and I'm always going to include one. It empties the bucket, removing all the objects inside, and then deletes the bucket itself, so we don't waste any money. When you're done, run it, and within a minute a refresh of the website URL shows nothing there anymore.

That's how you set up the AWS CLI for your projects. In future episodes we'll go further and automate more complex scenarios. What was the first thing you automated with it? Let me know in the comments, and see you in the next one!
