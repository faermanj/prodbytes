---
title: "Let's Build!"
slug: lets-build
date: '2026-09-28'
summary: Wrapping up the first section of the series, the serverless building blocks we covered, what a month of running them actually costs, and an invitation to go build your next thing.
---

In this first section of the series, we explored how to deliver serverless websites and apps on AWS. We saw how to store content on [Amazon S3](https://prodbytes.substack.com/p/static-websites-on-amazon-s3), compute with [AWS Lambda](https://prodbytes.substack.com/p/functions-with-the-aws-sam), keep data in [Aurora Serverless PostgreSQL](https://prodbytes.substack.com/p/serverless-databases), serve [your own secure domain](https://prodbytes.substack.com/p/your-own-secure-domain) with Route 53, ACM, and CloudFront, and manage users and permissions with [Amazon Cognito](https://aws.amazon.com/cognito/). That's pretty much everything we need to build and ship an app.

> This post is part of the ["Delivering Software Projects"](https://prodbytes.substack.com/p/delivering-projects-on-aws?r=c4tlc) series, focused on helping YOU be sucessful in your tech career. Please consider becoming a member. For a small contribution, you'll help us keep the lights on and have full access to our content, events and tools.

## Paying only for what you use

The common thread in all of those services is that they're serverless, meaning that we only pay for the resources we actually use. If we get, for example, a single request during the entire night, we don't pay for all the hours a server was sitting there waiting. We pay just for the resources consumed by that one request, which is probably going to be a fraction of a penny. The pricing pages for [Lambda](https://aws.amazon.com/lambda/pricing/), [S3](https://aws.amazon.com/s3/pricing/), and [CloudFront](https://aws.amazon.com/cloudfront/pricing/) all work that way, per request, per gigabyte, per millisecond.

That's not free, and it's not always cheaper. Under steady, heavy traffic, capacity you provision yourself can come out ahead, and scaling from zero has the cold start trade-offs we discussed with the database. But for a new project, when you have no idea how much traffic you're going to get, it's a very good place to start.

## What it actually costs

To show very transparently what I mean, here's what my bill looks like this month on the [AWS Billing console](https://console.aws.amazon.com/billing/). Most of it is a one-time charge for the domain I registered with Route 53. The actual service cost, for everything running across these episodes, is around $3, because I don't have a lot of traffic.

Your numbers will be different, of course, depending on what you leave running and how much traffic you get. That's why the [budget alerts](https://prodbytes.substack.com/p/budgets-and-utilization-alarms) from the beginning of the series are still worth having in place. A small bill is only reassuring if you'd notice when it stops being small.

## Your turn

So this is the idea: not wasting money or resources on your applications, and still being able to build and publish your next big thing. I hope this section encourages you to do exactly that, and to share it with me, with the world, and with the open source community if you want. The code for everything we've built so far is in the [DSP repository](https://github.com/prodbytes/DSP), so feel free to start from there.

I'd be delighted to see what you build, so send it my way. In the next sections, I'm going to show you a lot more, other kinds of projects, other AWS services, and some apps for us to play with.

What are you going to build first? Let me know in the comments, and see you in the next one!
