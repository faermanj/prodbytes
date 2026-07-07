---
title: What should I study next?
slug: what-to-study-next
date: '2026-07-06'
summary: Why keep learning in the age of AI, and how to invest your time — ticket by ticket, not doctorate first.
---

This question comes up often, most recently in a session with my friend Ricardo, a senior software engineer who was anxious about a very fair question: with all this AI, what should he study next? What should be the next investment of our precious time? In this video I share how I think about that — why we should still study at all, how to approach the investment, and some things you might enjoy learning.

## Why study if there is AI?

For most people, the goal is to get and hold a job, or to take the next step in their current position. For that, you need to know things — you can't just ask AI for everything. The best place to start is the job description of the position you want. Looking at an [NVIDIA](https://www.nvidia.com/) posting, for example, I would need [Kubernetes](https://kubernetes.io/), GPUs, the NVIDIA software stack like [NeMo](https://developer.nvidia.com/nemo), [Go](https://go.dev/) and [Python](https://www.python.org/), and cloud providers. Even with AI, those positions are still there, and there is still a lot to learn. And if you like AI itself, search for AI opportunities — building and using it — and you will find plenty to study in every one of them.

There is also a simpler reason: We like the experience. People still enjoy chess, a game computers have essentially solved, and they play it without cheating. Computing, software, even music have that same quality. AI being able to do something doesn't take away my enjoyment of learning and doing it myself.

## Focus on the ticket

You probably study more than you need already, and the amount of things to learn can be overwhelming. So don't be anxious about it: I'm a strong advocate of ticket-oriented learning. You don't need to become a doctor in a field before you get a job, a project, or a ticket. Do it the other way around — take one ticket, then another, then hundreds. After that you'll have the experience and the expertise, and then, if you want, go get your doctorate.

Look at the [issue queue](https://github.com/quarkusio/quarkus/issues) of a project like [Quarkus](https://quarkus.io/): reactive messaging, [OpenShift](https://www.redhat.com/en/technologies/cloud-computing/openshift), Kubernetes clients, [Hibernate](https://hibernate.org/) memory usage — impossible for anyone to take on single-handedly. But pick one ticket, say a native integration for the OpenShift client, and now the scope is clear: learn just enough OpenShift to close it, then move on to the next.

## How to find tickets?

If you don't have a project yet, the [project-based learning](https://github.com/practical-tutorials/project-based-learning) repo on GitHub collects projects across programming stacks — games, enterprise apps, web, each with its own context. You are also most welcome to join [our org](https://github.com/prodbytes), where we have [pet-hub](https://github.com/prodbytes/pet-hub), [insurance-hub](https://github.com/prodbytes/insurance-hub), and demo apps to showcase technology and grow together. And of course, you can start your own project and your own organization.

## Creating a project

If you go that route, I recommend starting the way Amazon does, with the [Working Backwards](https://www.aboutamazon.com/news/workplace/an-insiders-look-at-amazons-culture-and-approach-to-innovation) process: write the launch document first. Not a big document — one page or two, a press release for the thing you want to launch. The [2006 press release](https://press.aboutamazon.com/) for [Amazon S3](https://aws.amazon.com/s3/) announced the object storage service we all use and love before most of us could touch it: writing and reading objects, published on the web, scalable, fast, reliable, inexpensive. Writing up what you want to launch — and when, say six months out — gives you scope and time perspective before you build anything.

One more recommendation: don't start with the tech stack, and especially not with the language. Start with the business, the concepts, the launch. Then look at libraries and frameworks — they will usually determine the language for you. The language debates on social media are mostly useless because you often can't do anything about it: if you're using [Apache Spark](https://spark.apache.org/) for a data project, your realistic options are Python, SQL, [Scala](https://www.scala-lang.org/), [Java](https://dev.java/), or even [R](https://www.r-project.org/). C or C++ for a Spark project is sometimes possible, but probably not a good idea. Every domain has its libraries and frameworks, and once those are chosen, the language is just a consequence.

When it's time to build, start as low-code as possible and go up in complexity:

- **No code and low code.** Our new website runs on [Squarespace](https://www.squarespace.com/) with barely a line of code, though I can inject custom code when I need to — limited, but a real way to start. Services like [AWS Blocks](https://aws.amazon.com/products/developer-tools/blocks/) and tools like [Antigravity](https://antigravity.google/) now build apps with databases, authentication, and asynchronous jobs without you coding all of that yourself.
- **Static sites.** If your project is about content — a blog, or a knowledge collection like [IMDb](https://www.imdb.com/) — generators like [Hugo](https://gohugo.io/) build the pages for you. You serve files directly, no server to run, and they are very efficient.
- **Web apps.** For real enterprise apps, pick your favorite web framework. I've done [React](https://react.dev/), [Angular](https://angular.dev/), and [Vue.js](https://vuejs.org/), but [SvelteKit](https://svelte.dev/docs/kit) and [Vaadin](https://vaadin.com/) are usually my tools of choice. They're not the most popular, and that's okay — I'm not hiring a lot. If you are, React or Vue.js may serve you better. But SvelteKit is more pleasant to work with, and its [adapters](https://svelte.dev/docs/kit/adapters) cover serverless and static generation with the same framework.
- **Native apps.** When you need optimal performance, or the cameras and sensors that mobile devices offer, go to a full-blown app framework like [Flutter](https://flutter.dev/), with all the power of the device at your service.

Always stay focused on the business proposition — the thing you're trying to launch — broken down as soon as possible into individual tickets, so you learn just enough to close the ticket or to prepare for the opportunity at hand.

What about you — what's the next ticket on your queue? Let me know in the comments!
