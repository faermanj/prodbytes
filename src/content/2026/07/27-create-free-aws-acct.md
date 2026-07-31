---
title: 'Delivering Projects on AWS: Getting Your AWS Account'
slug: daws-s00e02-aws-free-account
date: '2026-07-27'
summary: How the AWS Free Tier works in practice — $200 in credits, what it does and doesn't cover, what to expect on the bill, and sandbox environments as an alternative.
---

In this one, I want to talk about getting an [AWS](https://aws.amazon.com/) account. If you already have an account you can use and you know how it works, feel free to skip ahead. But if you're just starting, I highly recommend creating your own account, especially for learning — because in your learning account you can just delete everything and stop spending at any moment.

## What it actually costs

The account itself is free; you only pay when you start using services — and every cloud resource has a cost. AWS gives you credits to begin (more on that below), but after those run out, you pay for what you use.

In my experience, personal projects usually stay under $5 a month. Something more like a startup or an initial web app tends to land around $10 to $20 a month. Things can of course grow much more expensive than that — but cost usually correlates with usage, so that's usually fine.

## The free tier: up to $200 in credits

When you go to [aws.amazon.com](https://aws.amazon.com/) for the first time, you should see a create account button — or you can always go to [aws.amazon.com/free](https://aws.amazon.com/free/), which explains the free tier and how the credits work.

This changed recently. AWS used to give you a quota per service; now it's simpler, but different. When you create your first account and verify your identity, you get $100 in credits immediately. Then there are five challenges, each worth another $20:

- Set a budget alarm — we're going to do exactly that in the next episode
- Launch an [EC2](https://aws.amazon.com/ec2/) instance
- Create an [RDS](https://aws.amazon.com/rds/) database
- Talk to the AI service
- Create a [Lambda](https://aws.amazon.com/lambda/) function

These are very simple things — 10 or 15 minutes of work — and good ideas anyway. Together that's $200 you can use over six months to build and experiment without any charges to your credit card.

One warning, though: the free plan does not include all services. [Route 53](https://aws.amazon.com/route53/), for example, requires a paid account — so if you want to register domains and serve a .com address, you need to upgrade. The good news is you keep your remaining credits when you do, and you only get charged after the credits run out or the six months are over. So if the free plan gets in your way, upgrading early is worth it — you get access to everything without negative consequences.

Either way: create your account. It will ask for your email, phone, verification, security details — and once that's done, you have access to the AWS console, which is where everything else in this series happens: budget alarms, security measures, and everything you need to deliver projects.

## Sandbox environments as an alternative

There's another resource worth mentioning: the [AWS Builder Center](https://builder.aws.com/), where you can find [workshops](https://builder.aws.com/learn/workshops) for pretty much every service. These are a nice supplement to what we do here, and I'll keep pointing to them as often as possible.

Some workshops are tagged with a free AWS environment — you can request a temporary sandbox account, untied from your own AWS usage. Just check the fine print: those environments and their resources are temporary. But if you're learning, or you don't want (or can't) create your own account yet, a free sandbox environment is a great way to practice.

## Take it easy

Just to recall: AWS is ultimately a resource for delivering projects online — web apps, websites, IoT, whatever you want to build, there will be an AWS service for it. There are hundreds of them, so take it easy; we're going to go step by step. The first step is getting your account. From there, we'll monitor costs and learn how to keep your account clean and tidy so charges stay minimal.

Do you already have an AWS account, or is this your first one? Let me know in the comments — see you in the next one!
