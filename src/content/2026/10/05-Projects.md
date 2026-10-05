---
title: 'Real Projects, Live, Together'
slug: nu01-projects
date: '2026-10-05'
summary: Open source projects running live on nu01.com that we can work on together, where every contribution goes through the same pipeline to production, starting with Presence and uplink.
---

Most of what we learn about delivering software comes from samples that stop at the README. They build, maybe they run on localhost, and that's the end of it. Nobody uses them, nothing breaks at 2 a.m., and nobody has to decide whether a change is ready for production. That's exactly the part that matters most in a real job, and it's the part that's hardest to practice on your own.

So here's the idea: real projects, running live, that we work on together. Each one is open source on the [prodbytes organization](https://github.com/prodbytes) on GitHub and deployed on AWS under nu01.com, the domain we set up in [our own secure domain](https://prodbytes.substack.com/p/your-own-secure-domain). If you send a pull request and it's merged, it goes through the same pipeline my changes do, first to a release candidate, then to production, and you can open the site and see your change live. Small projects, with few users, but real ones.

All members of Production Bytes have access to these projects. The code is public for anyone to read, but some features, like storing and processing video on Presence, cost money to run, so they're open to signed-in users we've approved. As a member, you're in: you can use the live apps, not just read about them, and help shape where they go.

This post is a map of what's running today, where the code is, and how to get involved, starting with Presence and uplink.

> This post is part of the ["Delivering Software Projects"](https://prodbytes.substack.com/p/delivering-projects-on-aws?r=c4tlc) series, focused on helping YOU be sucessful in your tech career. Please consider becoming a member. For a small contribution, you'll help us keep the lights on and have full access to our content, events and tools.

## Presence

[Presence](https://presence.nu01.com) is the camera app for people and pet recognition that we [started a few days ago](https://prodbytes.substack.com/p/reference-project-presence). It turns a phone, tablet, or laptop into an always-on camera, saves an event with a bit of context before and after whenever motion is detected, and lets you tag who's in each frame. Recognition that's good enough to trust is still ahead of us, so for now, think of it as a camera with a very good memory.

The app is written in [Flutter](https://flutter.dev/), and the backend is the serverless set from the first section of the series: S3 and CloudFront for the static app, Lambda for the auth API, [Amazon DynamoDB](https://aws.amazon.com/dynamodb/) for roles and memberships, and Cognito identity pools so each user only touches their own data.

- App: [presence.nu01.com](https://presence.nu01.com)
- Release candidate: [rc.presence.nu01.com](https://rc.presence.nu01.com)
- Source: [github.com/prodbytes/presence](https://github.com/prodbytes/presence), with the infrastructure in [presence_infra](https://github.com/prodbytes/presence/tree/main/presence_infra)

## uplink

[uplink](https://github.com/prodbytes/uplink) is a broken link checker. It started from a very practical need: every post here links to a lot of documentation, and documentation moves. A link that worked when I published can 404 a few months later, and nobody tells you. So uplink crawls a site, follows every link on the same host, checks each link that goes elsewhere once, and reports what's good, what's broken, and what it couldn't verify.

It's written in Java with [Quarkus](https://quarkus.io/) and [TamboUI](https://tamboui.dev/), and compiled to a native executable with [GraalVM](https://www.graalvm.org/), so it starts fast and needs no JVM installed. You can run the latest release without installing anything:

```bash
curl -fsSL https://sh.uplink.nu01.com | sh -s -- https://prodbytes.substack.com/archive
```

That script, served from sh.uplink.nu01.com, downloads the binary for your machine from the latest [release](https://github.com/prodbytes/uplink/releases), checks it against the published `SHA256SUMS`, and runs it. Piping a script from the internet into your shell deserves some suspicion, so do read [run.sh](https://github.com/prodbytes/uplink/blob/main/scripts/run.sh) first. It's short.

In a terminal, uplink opens a dashboard that keeps crawling on an interval, showing broken links, recoveries, and slow pages as they happen. In CI, it detects the environment, crawls once, prints a report, and exits with `1` if anything is broken. The repository is also a [GitHub Action](https://github.com/prodbytes/uplink/blob/main/action.yml), so failing a build on broken links is a few lines of YAML:

```yaml
- uses: prodbytes/uplink@main
  with:
    url: https://example.com
```

There are some honest limits. Many servers refuse automated clients, answering 403 or 429, and LinkedIn famously answers 999. uplink reports those as unverified instead of broken, since they probably work in a browser, but it can't prove it. And some sites block GitHub's runners outright: Substack's Cloudflare answers them with 403, so checking this newsletter from a hosted runner doesn't work. From my laptop it's fine.

The site at [uplink.nu01.com](https://uplink.nu01.com) is the same crawler running in the browser, compiled to [WebAssembly](https://webassembly.org/) with GraalVM's Web Image. It's a nice demo of how far that toolchain has come, but the browser's security rules apply. A page can only be crawled if its site allows cross-origin reads, and links to other sites often hide their status, so a 404 elsewhere can go unnoticed. For a real check, use the CLI.

- Web: [uplink.nu01.com](https://uplink.nu01.com)
- Release candidate: [rc.uplink.nu01.com](https://rc.uplink.nu01.com)
- Installer: [sh.uplink.nu01.com](https://sh.uplink.nu01.com)
- Source: [github.com/prodbytes/uplink](https://github.com/prodbytes/uplink), with the infrastructure in [infra](https://github.com/prodbytes/uplink/tree/main/infra)

## The shape they share

The two projects are very different, a Flutter camera app and a Java command line tool, but they're delivered the same way, and that's on purpose.

Each project gets its own subdomain, with two environments, production and a release candidate on `rc.`, both behind CloudFront with ACM certificates, all described in CloudFormation. The DNS is where they differ, and where I've changed my mind along the way. Presence keeps its records in the nu01.com hosted zone itself. uplink came later and got its own zone, uplink.nu01.com, delegated from the parent. That keeps the blast radius smaller: uplink's deploy role can only change records in its own zone, so a mistake there can't touch the root domain or the other projects. I expect new projects to follow uplink's approach, and Presence to move over at some point.

Deployments are driven by tags. Pushing a tag ending in `RC` runs the Deploy RC workflow on [GitHub Actions](https://github.com/features/actions), and a tag ending in `GA` deploys to production. Neither workflow stores AWS keys: each one exchanges GitHub's OIDC token for a role that only trusts its own kind of tag, so a release candidate can't touch production. You can follow every run on the [Presence](https://github.com/prodbytes/presence/actions) and [uplink](https://github.com/prodbytes/uplink/actions) Actions tabs.

Is this the right setup for every project? Probably not. Tag-driven releases keep a human in the loop, which I want at this size, but nothing ships until someone tags it, and two environments per project add up if you have dozens. For a handful of small, cheap, serverless projects, it has been a good trade so far.

## What's next

The next one I expect to land on the domain is [rbacr](https://github.com/prodbytes/rbacr), a role manager for applications. Users sign in with Google, and it records which roles each email address or whole domain holds in each system, serving them as web pages and as JSON. It's a SvelteKit app on Lambda, and the code is already public, but it isn't live on nu01.com yet. Presence handles its own memberships today, and I'm curious whether pulling that out into a shared service is worth the extra moving part.

That's the whole point: projects that are real enough to break, that members can use, and that anyone can contribute to. All of these are open for issues and pull requests, and a merged change goes through the same pipeline mine do, so you can watch it reach production. Which of these would you try first, and what would you want hosted next to them? Let me know in the comments, and see you in the next one!
