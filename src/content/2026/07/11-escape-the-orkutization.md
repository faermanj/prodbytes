---
title: Escape the Orkutization
slug: escape-the-orkutization
date: '2026-07-11'
summary: How to register your own domain and redirect it to the platform — so if the rules change, your audience moves with you.
---

In this video I'd like to start talking about how to depend less on social media and how to preserve your investment — and your future — on the web. It's a long answer, and let me be clear about the goal: I don't think we can be entirely self-sufficient and not rely on big tech at all. That's not the point. The point is making sure that if the platform changes, you keep your options open — and today we take the first concrete step: registering your own domain and redirecting it to wherever your audience is now, so you can escape the "orkutization" of your platform.

## The orkutization of social media

If you spend time on [LinkedIn](https://www.linkedin.com/) or [YouTube](https://www.youtube.com/), you have probably noticed how the quality of engagement degrades over time. I call it the orkutization of social media: every social network tends to become [Orkut](https://en.wikipedia.org/wiki/Orkut) in the end. You can never know where a platform will go — LinkedIn, for example, used to be a great place for opportunities; now it's mostly noise. You have probably seen creators losing their channels and their audiences overnight when the rules change.

So you may want to preserve your option to leave — or at least to redirect your audience to a new place — instead of losing them and being totally in the hands of the platform.

## The first step: your own domain

The first step to create your own presence on the web is getting your own domain, and it's very simple. I know many of you have done this before, but I'd like to do it from the start, for the people who never have. The idea: if I get my own domain and use that instead of the platform address — in our case, prodbytes.substack.com on [Substack](https://substack.com/) — I can keep the audience and move them somewhere else if things change in the future. The links you share, the address people remember, the brand you build: all of it points at something *you* control.

Since prodbytes.com is already taken, I went looking for an alternative and found `prodbytes.es` available — .es for Spain, where I live and am very grateful for.

## Trying Route 53 first

My first attempt was [Route 53](https://aws.amazon.com/route53/) on [AWS](https://aws.amazon.com/). If you don't have an AWS account yet, I highly recommend you create one — we're going to use AWS a lot in these videos, and there's no cost for having an account. You can sign up on the [free tier](https://aws.amazon.com/free/), and if it's your first account you get a hundred dollars in credits, plus five quests worth twenty dollars each — up to two hundred dollars total, and the quests take about five minutes. Once you're in, search for Route 53 in the console and you'll find the domain registration feature under "Register domains".

I don't know exactly why, but my registration request failed there. No problem — and this is worth knowing anyway: you don't need to register the domain in the same place where you serve your services. The domain can be registered anywhere and you can still point everything through AWS later.

## You don't have to code, either

One more recommendation while we're here, and you'll often see me saying this: you don't need to code, or to use AWS, to get started. For many people, a low-code or no-code tool or a website builder is the better first move — I use [Squarespace](https://www.squarespace.com/) a lot myself, including for the workshop and mentorship programs I run with my friend Isa, for the more human side of career progression. A builder like that can also register domains, though in my case it didn't offer the .es TLD I wanted.

## Registering on GoDaddy

So, third attempt: [GoDaddy](https://www.godaddy.com/), a very popular domain provider. There I could register `prodbytes.es` for about 13 euros a year — which I think is totally worth it for protecting your presence. After confirming the transaction, ta-da: I own this web property.

Then comes the part that makes it useful today: forwarding. In the GoDaddy domain settings I skipped all the free-site and page-builder offers — I just want the domain — and set up a redirect to prodbytes.substack.com. One detail matters here: I chose a *temporary* redirect rather than a permanent one, and that choice deserves its own section below. DNS replication can take up to 48 hours, but once it's done, prodbytes.es is served through our domain and lands on the newsletter.

## Why a temporary redirect: 301 vs 302

A [301 (Moved Permanently)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/301) and a [302 (Found)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/302) both send the visitor to a new URL, but they tell the rest of the web very different things about how seriously to take the move.

A 301 declares "this resource now lives at the new address, forever." Browsers cache it aggressively — often indefinitely — and search engines transfer the page's ranking signals to the destination. That's what you want when you've genuinely moved for good. A 302 says "for now, go over there, but keep treating my URL as the real address": browsers re-check on each visit, and search engines keep the original URL as the one that counts.

For our setup, that difference is the whole game. With a 302 from prodbytes.es to prodbytes.substack.com, my domain remains the canonical address — the day I want to leave Substack, I change one setting at the registrar and every browser picks up the new destination on the next visit. With a 301, I'd be telling browsers and search engines that Substack's URL is the permanent home: a cached 301 is notoriously hard to undo, since you can't push an update to someone's browser cache, and any search authority flows to substack.com instead of accumulating on my own domain.

The trade-off: while running a 302, your domain builds less search-engine standing of its own, since it hosts no content. That's the cost of the flexibility — acceptable here, because the goal isn't ranking today, it's preserving the option to move tomorrow. Once you host your own site on the domain instead of redirecting, the question disappears entirely.

## Preserving the option

To be clear, I have nothing against Substack — I really like the service, for now. But that's exactly it: *for now*. If Substack changes the rules, or YouTube changes the rules, or LinkedIn isn't likeable anymore, you preserve the option to change, to redirect, and to keep your audience with you. Thirteen euros a year is cheap insurance against orkutization.

Where does your audience live today — and do you own the address, or does the platform? Let me know in the comments!
