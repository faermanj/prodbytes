---
title: 'Presence: A Project We Can Build Together'
slug: presence
date: '2026-10-01'
summary: Starting Presence, an open source camera app for people and pet recognition, running live on AWS so we can collaborate on a real project and watch every contribution reach production.
---

I'm really excited about this one, because we're finally starting a project. [Presence](https://github.com/prodbytes/presence) is an idea that's been brewing for a while. I've mentioned it in a few talks, and it's finally coming together. It's a camera app with people and pet recognition, and it lives in the prodbytes organization on GitHub.

My first goal is not the camera, though. It's to have a project running in production, live on AWS, that we can work on together. If you submit a pull request, it goes through the same process mine do, and you can see your change live, just like I see mine. That's what makes it useful for learning: not a toy sample that stops at the README, but a real delivery pipeline with real users, even if there are only a few of us.

> This post is part of the ["Delivering Software Projects"](https://prodbytes.substack.com/p/delivering-projects-on-aws?r=c4tlc) series, focused on helping YOU be sucessful in your tech career. Please consider becoming a member. For a small contribution, you'll help us keep the lights on and have full access to our content, events and tools.

## What it does

Presence is a security camera for private spaces. If you have a private club, a church, a group, a farm, or whatever place you're responsible for, you can see the people and pets there and, hopefully, recognize them. It turns a phone, tablet, or laptop into an always-on camera.

The obvious comparisons are [Blink](https://blinkforhome.com/) cameras, which I use a lot here at home, and [AlfredCamera](https://alfred.camera/), which also turns an old phone into a security camera. There are also pet trackers that tell you where your pet is, but most use GPS collars, which can be uncomfortable for the animal and need recharging. I'd rather use cameras to find out where my little cat is on the property. And if you run an office and are allowed to know who is in and who is out, why not have that automated too?

One important caveat. Before you point a camera at anything, make sure you're allowed to record that place. Laws on recording people, and especially audio, vary a lot by country, state, and city. The [README](https://github.com/prodbytes/presence) says it plainly, and I mean it: only record places you have the right to monitor.

## A quick tour

The production app is at [presence.nu01.com](https://presence.nu01.com). Open it and you see the camera, plus an option to sign in. Most features are only available to signed-in, authorized users, because storing and processing video costs money. I'm trying to keep that cost as low as possible, with serverless services all the way, but it's not zero, so you only want to pay for the users you actually want.

Right now, access is allowed by email domain. When I sign in with my own domain, I get every feature. Anyone else can sign in and request membership, and an admin screen lets me approve or reject those requests.

Once you're in, there's the list of events. When you take a clip, or when motion is detected, an event is saved. You can open a frame and tag who's in it, say "this is Julio", so that in the future it can, hopefully, recognize me by itself. I want to be honest about that "hopefully": tagging works today, but recognition that's reliable enough to trust is the hard part, and we'll get to it in later episodes.

There are also settings for brightness and motion detection sensitivity, and for how long to keep before and after each event. The camera is always recording into a short buffer, so when something happens, the clip includes a little context before it and a little after. If an animal walks by, you probably want to see where it came from and where it went, not just the one second that triggered the motion.

## Shipping it

The architecture, components, and services are described in the [repository](https://github.com/prodbytes/presence). In short, the app is written in [Flutter](https://flutter.dev/), so the same code runs on web, Android, iOS, and Linux. Behind it are the building blocks from the first section of this series: [static content on S3](https://prodbytes.substack.com/p/static-websites-on-amazon-s3) served through CloudFront on [our own secure domain](https://prodbytes.substack.com/p/your-own-secure-domain), an auth API on [AWS Lambda deployed with SAM](https://prodbytes.substack.com/p/functions-with-the-aws-sam), [Amazon DynamoDB](https://aws.amazon.com/dynamodb/) for roles and memberships, and [Cognito](https://prodbytes.substack.com/p/user-management-with-amazon-cognito) identity pools, so each user can only read and write their own data on S3. All of it is [CloudFormation](https://prodbytes.substack.com/p/automation-with-aws-cloudformation), in [presence_infra](https://github.com/prodbytes/presence/tree/main/presence_infra).

There are two environments. Besides production, there's [rc.presence.nu01.com](https://rc.presence.nu01.com), the release candidate: the same app, at a newer version, for testing before it reaches everyone.

What decides where a version goes is the tag. The [releases](https://github.com/prodbytes/presence/releases) carry the same names as the [tags](https://github.com/prodbytes/presence/tags). Whenever a tag ending in RC, or RC1, RC2, and so on, is pushed, the [Deploy RC](https://github.com/prodbytes/presence/blob/main/.github/workflows/deploy-rc.yml) workflow on [GitHub Actions](https://github.com/features/actions) deploys it to the RC environment. Similarly, a tag ending in GA, for generally available, triggers the [Deploy](https://github.com/prodbytes/presence/blob/main/.github/workflows/deploy.yml) workflow to production at presence.nu01.com. You can watch every run on the [Actions tab](https://github.com/prodbytes/presence/actions). Neither workflow stores AWS keys: each one exchanges GitHub's OIDC token for a role that only trusts its own kind of tag, so an RC run can't touch production.

Is tag-driven deployment the best possible pipeline? Probably not for every team. It puts the decision of what ships in a human hand, which is what I want for a project this size, but it also means nothing ships until someone tags it. We'll revisit that as the project grows.

## What's next

From here, we'll look at how much this actually costs to run, how to improve it, how to add other kinds of detection, and much more. I'll certainly be using it here at my place, so I have a personal interest in making it work well.

If you want to take it for a spin, you're most welcome to open [issues](https://github.com/prodbytes/presence/issues), send [pull requests](https://github.com/prodbytes/presence/pulls), or get in touch on LinkedIn and talk to me directly. What would you point a camera like this at, and what would you want it to recognize first? Let me know in the comments, and see you in the next one!
