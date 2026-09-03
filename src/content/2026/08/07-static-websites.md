---
title: 'Static Websites on Amazon S3'
slug: static-websites-on-s3
date: '2026-08-07'
summary: Getting started with web development and publishing with static websites — a page in plain HTML, CSS, and JavaScript, served from an S3 bucket for pennies.
---

In this one, let's start talking about static websites and how to host them on [Amazon S3](https://aws.amazon.com/s3/). By static, I mean sites that don't need to be computed with a programming language on a server. You can just serve the HTML, CSS, JavaScript, and images as they are.

This matters first for cost. We saw in the [low-code episode](../low-code-with-squarespace/) that web hosting tools usually charge around $20 a month for a website. With static websites, you can do it for two or three dollars a month. They are also more secure, more reliable, and genuinely useful. They can go a long way, as we'll see at the end.

> This post is part of the ["Delivering Software Projects"](https://prodbytes.substack.com/p/delivering-projects-on-aws?r=c4tlc) series, focused on helping YOU be sucessful in your tech career. Please consider becoming a member. For a small contribution, you'll help us keep the lights on and have full access to our content, events and tools.

## The simplest possible website

I encourage you to build your own repository and your own code, but if you'd like to follow this example, it lives in the [DSP repository](https://github.com/prodbytes/DSP) (for Delivering Software Projects), where all the samples of this series are hosted. This one is under [samples/static-website-simple](https://github.com/prodbytes/DSP/tree/main/samples/static-website-simple).

The site is just an `index.html` file, which is the usual convention for the first page served when you type an address, plus a few resources, like a cute cat picture to display on the page. If you're unfamiliar with the languages, don't worry. This is [HTML](https://developer.mozilla.org/en-US/docs/Web/HTML), [CSS](https://developer.mozilla.org/en-US/docs/Web/CSS), and [JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript), the basics of the web. All the web is built upon these three.

HTML declares the structure of the page with tags: the tag name in angle brackets, closing with a slash. An `<h1>` is a heading, then a paragraph, styled with a small piece of CSS that just sets the font weight to bold. Of course, styles could live in a separate file and get way more complicated; I just want to show the basics here.

Then comes something special: a click counter inside a `<span>` with an ID, so we can reference it from our JavaScript. There's a link pointing to the [origin of the meme](https://knowyourmeme.com/memes/i-can-has-cheezburger), targeted at `_blank` so it opens in a new tab, and inside it the image of the cat with a description and an `onclick` function that says what happens when the element is clicked. The function gets the span by its ID, which is how you work with the [DOM](https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model), the Document Object Model, and sets its text content to the current value plus one, using `parseInt` to turn the string into a number first. Not the greatest JavaScript, to be honest, but you can write your own.

And this is how they interact: HTML defines the structure of the page, CSS defines how it looks, and JavaScript defines the behavior. Every website you see out there is a variation and a deepening of these three basic languages. Nobody knows all the tags, all the functions, all the CSS. Ask AI for examples and learn it little by little.

To see it working, you don't even need hosting. Just open the file from your file explorer and the browser renders it: the hello, the cat, and the counter going up with each click. Exactly what we expected from our page.

## Creating the bucket

Now, to serve it on AWS, I'll go to Amazon S3, create a bucket, and configure it to host our static website. I named mine "can I have cheeseburger" and went with the defaults, changing only two things: enabling ACLs, which we'll use in a moment to make the objects public, and removing the block on public access.

That acknowledgement about public objects deserves a pause. When you publish a website, it uses resources, network among them, and somebody has to pay for it. When you're the one serving, you're usually the one paying, and there's no control over who requests your objects. So there is a slight risk that some evil person downloads your website many, many times just to make a hit on your wallet. That may sound scary, but it's actually not much: it's probably more expensive for them to do it than for you to serve it on S3. We'll see in future episodes how to detect and mitigate this. For now, I want the simplest possible publish.

Once the bucket is created, upload the files, the `index.html` and the cat picture. Under permissions, you set who can access them, because by default everything you put in a bucket is visible only to you. Since I want to serve this to the world, I grant public read access, with the same caveat as above.

Then, in the bucket properties, at the very end, there's **static website hosting**. Edit it, enable it, and say the page you want to serve is `index.html`. You can also set an error document and redirection rules if you want; I'll keep it simple. With that saved, the website configuration shows an endpoint, and clicking it opens our page, now hosted on an S3 URL, working exactly the same as it did locally, counter and all.

## What it actually costs

If we check [S3 pricing](https://aws.amazon.com/s3/pricing/), storage is around two cents per gigabyte per month, and our files are not even a few kilobytes, so that's a fraction of a penny. Then there are the requests and the data transfer out, each another fraction of a cent. The cost is really pennies to serve this, and as requests accumulate it may get to a few dollars. In my case, my static websites on S3 usually stay under $5 a month, but of course that varies for everybody.

## How far static goes

You can go a long way with static websites. One that I built is a memorial site for my father, [Marcos Faerman](https://marcosfaerman.com.br). He was a journalist, and the site lists his publications and serves the actual files, so you can open each one and read the content. All of that without a single server; everything you see is delivered statically.

Another resource worth knowing is [HTML5 UP](https://html5up.net/), which provides very nice templates you can just download. Take the [Massively](https://html5up.net/massively) template, for example, or [Multiverse](https://html5up.net/multiverse): good styling, and the download gives you the HTML, CSS, JavaScript, and everything else you need. Change the images, change the text, and publish to your S3 bucket. There's also a paid version by the same author, [Pixelarity](https://pixelarity.com/), with more templates that are also very fine.

And of course, you can ask AI to code similar things for you. But always take a look at the code and try to learn what's going on.

That's how you publish static websites on S3. Have you published one, or do you have a page you'd like to put online? Let me know in the comments, and see you in the next one!
