---
title: 'Your New Project Canvas: Dev Containers and Devbox'
slug: devbox-setup
date: '2026-07-10'
summary: How to set up a modern development environment that anyone on your team can start in seconds — with Dev Containers and Devbox.
---

In this video I'd like to address a question I got from a student at [LINUXtips](https://linuxtips.io/) just the other day — and a very frequent one with customers too: how do you set up a new project? How do we build a modern development environment? Of course that depends on the project — different libraries, frameworks, and dependencies will need a different setup. But there are tools that let you share the project with your team in a way that everybody can contribute without going through a detailed recipe. That's what I'd like to demonstrate today, using [Dev Containers](https://containers.dev/) and [Devbox](https://www.jetify.com/devbox).

## Starting from a template

Everything I'm going to show works from scratch in a new repository, but I prepared something for you: the [blank-devbox](https://github.com/prodbytes/blank-devbox) template repository in our [ProdBytes org](https://github.com/prodbytes), with all the setup already done (and if you want to leave a star, I'd appreciate it). Template repos are very simple to use: click "Use this template", create your new repository — in the video I create [pizza-hub](https://github.com/prodbytes/pizza-hub), to get the best pizza around you — and in a few seconds you have a copy of everything.

From there you can click Code → Codespaces and start a [GitHub Codespace](https://github.com/features/codespaces). It's a good idea to go with "New with options" — the defaults work, but you get a bit more control; I picked a four-core machine. This gets you started quickly without cloning the repo or setting up your machine at all: it runs on GitHub's cloud, and there is a [monthly free tier](https://docs.github.com/en/billing/concepts/product-billing/github-codespaces). After that, you can clone the repo locally or pay for more Codespaces, whatever you need.

## Using DevContainers

While the Codespace builds, you can see what it's doing — and all of it is defined in `.devcontainer/devcontainer.json`. The definition is short: the configuration lives in a Containerfile with the code as build context, the remote user is `vscode`, and I add the [docker-in-docker feature](https://github.com/devcontainers/features) so [Docker](https://www.docker.com/) comes already set up and ready to use inside the container. There are also a few [VS Code](https://code.visualstudio.com/) settings — you can add extensions and whatever else you'd like there — and a `postCreateCommand` that installs the Devbox dependencies.

That last part matters: Devbox is a separate tool, and `devbox.json` — not the container — is where the actual dependencies live. We could install everything in the container image, but keeping the tools in Devbox makes it much easier to clone the repo and use your own machine if you want. It's a matter of freedom: develop in a dev container if that's fine for you, or on your local machine just as well — the same definition works for both.

## Devbox: same dependencies everywhere

Once the Codespace finishes, the README opens with your project files. Start a new terminal and type `devbox shell`, and you get a shell with all the dependencies defined in `devbox.json` — for this template, [Java](https://dev.java/) on the [GraalVM](https://www.graalvm.org/) virtual machine, [Python](https://www.python.org/), [Node.js](https://nodejs.org/), and [PostgreSQL](https://www.postgresql.org/). The prompt prefix shows the Devbox shell is active, and `java -version` or `node --version` confirm you're running exactly the versions the project specified — the same for everybody, whether it's macOS or Linux, a dev container or your local machine.

## One command to run everything

Devbox brings another capability: running processes, integrated through [process-compose](https://github.com/F1bonacc1/process-compose). In `process-compose.yaml` I have a PostgreSQL database and a health check configured, so running:

```bash
devbox services up
```

brings up every process defined in the file. That's a great way to build a uniform interface: on any project, I just type `devbox services up` and I don't need to care how to start it — everything comes up as defined for that project. You get a terminal UI where you can navigate to the postgres line, see the database up and the health check running, with logs separated per process. Readiness checks are fully configurable — the command, the intervals, the thresholds — so you can define exactly what "up" means for each service.

## Local, remote, or no containers at all

The same works outside the browser. From the repo's Code menu you can open the Codespace in local VS Code — that's a remote connection from your editor to the dev container, fully supported. And if you don't want to use containers, or can't for any reason, running locally is just as simple: clone the repo, `devbox shell` downloads all the dependencies, and `devbox services up` gives you the same health check, the same PostgreSQL, everything defined just the same.

A few more details you'll find in the template. In my process-compose file I prefer starting services with [Docker Compose](https://docs.docker.com/compose/) — so if you want, you can drop Devbox entirely and run `docker compose` directly against the same [compose.yaml](https://github.com/prodbytes/blank-devbox/blob/main/compose.yaml). And there's an [AGENTS.md](https://agents.md/) with a few directives for agents: if you're using [Claude](https://claude.com/claude-code) or any other agent, it will follow basic notes like reviewing changes before pushing and checking for security issues such as leaking secrets.

With tools like Docker, Devbox, and Dev Containers, we get a modern development environment that anyone on the team can start easily — even a brand-new contributor is just a few seconds away from a working setup.

How does your team onboard a new developer today — a README recipe, a golden laptop image, or one command? Let me know in the comments!
