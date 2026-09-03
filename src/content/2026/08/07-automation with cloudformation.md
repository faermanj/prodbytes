---
title: 'Automation with AWS CloudFormation'
slug: automation-with-aws-cloudformation
date: '2026-08-07'
summary: Improving our automation with Infrastructure as Code — declaring the static website as a CloudFormation template that either creates everything or nothing at all.
---

Let's improve our automation a little using tools from Infrastructure as Code, starting with the one from AWS, [AWS CloudFormation](https://aws.amazon.com/cloudformation/). CloudFormation lets us declare what we want instead of going command by command. You say "I need this bucket, this instance, this policy", and the service will either create everything you specified or nothing at all. No more error scenarios where your script ran through half of the steps, hit an exception, and left you to deal with the leftovers and find out what happened. In this one, we'll deploy the same static website [from the CLI episode](../automation-with-aws-cli/), but with a template instead of a script full of commands.

> This post is part of the ["Delivering Software Projects"](https://prodbytes.substack.com/p/delivering-projects-on-aws?r=c4tlc) series, focused on helping YOU be sucessful in your tech career. Please consider becoming a member. For a small contribution, you'll help us keep the lights on and have full access to our content, events and tools.

## Declaring the resources

The example lives in the [DSP repository](https://github.com/prodbytes/DSP), under [samples/static-website-simple/cform](https://github.com/prodbytes/DSP/tree/main/samples/static-website-simple/cform). The template is a [YAML](https://yaml.org/) file (JSON works too) with a few sections, the most important one being `Resources`, plus a `Description` and `Outputs`. There are `Parameters` and other things we'll use in the future, but for now, a simple template will do:

```yaml
Resources:
  WebsiteBucket:
    Type: AWS::S3::Bucket
    Properties:
      WebsiteConfiguration:
        IndexDocument: index.html
        ErrorDocument: index.html
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        IgnorePublicAcls: true
        BlockPublicPolicy: false
        RestrictPublicBuckets: false
```

Inside `Resources`, the first thing is the name we give each resource, and right below it comes the type, `AWS::S3::Bucket`, with the double colons between the parts. If you search for that resource type, you land on [its documentation page](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-s3-bucket.html), with all the properties you can configure. Everything you can do in the console is usually available in CloudFormation too. Here it's the bucket with the website configuration serving `index.html` as the homepage, and public access allowed.

Then the website policy, the same policy from the last episode allowing read access to the objects:

```yaml
  WebsiteBucketPolicy:
    Type: AWS::S3::BucketPolicy
    Properties:
      Bucket: !Ref WebsiteBucket
      PolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Sid: PublicReadGetObject
            Effect: Allow
            Principal: "*"
            Action: s3:GetObject
            Resource: !Sub "${WebsiteBucket.Arn}/*"
```

A few things going on here. The bucket policy takes a bucket, and I need to reference the one created previously. If I just wrote `WebsiteBucket` as a plain string, CloudFormation would look for a bucket literally called "WebsiteBucket", and I don't want that. I want the name of the bucket that was actually created, so I use [`!Ref`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-ref.html), a reference to that element. What `Ref` returns is specified on the resource type page, under return values: for an S3 bucket, passing the logical ID to `Ref` returns the bucket name. It's always useful to check what `Ref` returns for each type.

There are other functions too. In the policy resource, [`!Sub`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-sub.html) substitutes a property into a string, in this case the bucket's ARN, the [Amazon Resource Name](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference-arns.html), followed by `/*` for all the objects in it. The [`!GetAtt`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-getatt.html) documentation shows which attributes each resource exposes: for the bucket, the ARN, the domain name, and others. With these functions I can write exactly what I want, making dynamic references to elements created earlier and composing strings with the correct syntax.

Finally, the `Outputs` section declares named outputs. I'll print the bucket name and the website URL:

```yaml
Outputs:
  BucketName:
    Value: !Ref WebsiteBucket
  WebsiteURL:
    Value: !GetAtt WebsiteBucket.WebsiteURL
```

## Deploying the stack

The deploy script gets a lot shorter. It calls `aws cloudformation deploy`, passing the template file, and that either creates the stack or updates it:

```bash
aws cloudformation deploy \
  --stack-name "${STACK_NAME}" \
  --template-file static-website-simple.cform.yaml
```

The update part is quite useful. If you keep the infrastructure with your code, you can evolve the infrastructure along with the code, not as a separate thing. Add a resource to the template, run deploy again, and the stack is updated.

However, CloudFormation is for the provisioning of the resources. It's going to create the bucket, but it's not going to put any content in it. So I still have a separate after-deploy script that fetches the bucket name from the created stack and syncs the files:

```bash
BUCKET_NAME="$(aws cloudformation describe-stacks \
  --stack-name "${STACK_NAME}" \
  --query "Stacks[0].Outputs[?OutputKey=='BucketName'].OutputValue" \
  --output text)"

aws s3 sync "${SITE_DIR}" "s3://${BUCKET_NAME}" --delete
```

Remember the `--query` parameter from the last episode? Without it, `describe-stacks` returns a huge JSON. Here I take the first stack, find the output whose key is `BucketName`, and get its value. That's how I get the bucket name that was generated automatically, because since I didn't specify one, CloudFormation generated it for me. Same thing for the website URL, which the script fetches and prints once it's done.

Run the deploy script and either everything on the template gets created or nothing does, so there are no weird half-done situations to manage. Out of curiosity, you can watch it happen on the [CloudFormation console](https://console.aws.amazon.com/cloudformation/): the stack goes from create in progress to create complete, the resources tab links straight to the bucket on the S3 console, the files are correctly uploaded, and the outputs tab shows the bucket name and the website URL. Click it and there's our very simple app, behaving just as we expected.

## Destroying the stack

We could just go to the CloudFormation console and hit delete stack. However, that will give an error, because a bucket must be empty to be deleted. A few resource types are like that: the ones that contain data, where you probably want to clean the data first before destruction. So the destroy script does exactly that, deletes the objects in the bucket, and then deletes the stack, which deletes all the resources:

```bash
aws s3 rm "s3://${BUCKET_NAME}" --recursive
aws cloudformation delete-stack --stack-name "${STACK_NAME}"
```

## Scripts don't go away

So the scripts are not entirely eliminated. It's not like we forget shell scripts and the [AWS CLI](https://aws.amazon.com/cli/) now; they're still important. But they get much shorter, usually just a deploy command and a delete command, with a little thing around them, like emptying buckets or uploading content.

And the template is just a YAML file, a declaration. CloudFormation doesn't go line by line like a script; it understands what you want to create and either creates everything or nothing at all. The intrinsic functions, `!Ref`, `!Sub`, `!GetAtt`, add a bit of dynamic behavior to an otherwise static file, and the CloudFormation engine processes them to give you the correct results.

That's how we deploy our static website with CloudFormation. What was the first thing you moved from a script into a template? Let me know in the comments, and see you in the next one!
