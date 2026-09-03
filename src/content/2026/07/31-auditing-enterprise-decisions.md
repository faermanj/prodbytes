---
title: 'Auditing Enterprise Decisions: Apply Rules to Data Without Changing the App'
slug: auditing-enterprise-decisions
date: '2026-07-31'
summary: How to audit decisions in a legacy app you can't touch — bind a decision model to database events with Debezium and Kafka, and let the model flag what's out of bounds.
---

In this video I want to show you a fun demo I built for auditing enterprise applications. I know "fun" and "audit" usually don't belong in the same phrase when we talk about enterprise apps — and that's usually because legacy is hard to change. When we need some auditing, some new rules regarding our data, it can be tricky to figure out how those apps behave and add listeners in the proper place to give the answer the company wants. And needs: especially now with AI, we may have regulated audit criteria in many industries, and we need to justify decisions. So decision management is the name of the game here.

## The rule we want to audit

Let's start with the same app we've been using, the vehicle insurance hub — the source is in the [insurance-hub](https://github.com/prodbytes/insurance-hub) repository. It's a simple insurance quoting system: I fill a quote with random data and get back a risk rate and the premium, calculated from the estimated value of the car — in this case a 2024 Honda Accord — and a risk rate of 10.72%.

What I want to do is create a rule and audit that decision. My rule is simple, but it could be as complicated as you want: the risk rate can't be too high or too low. If it's above, say, 15% of the value of the car, the policy isn't viable for the customer; if it's below 5%, it may not be viable for the insurance company. That's the criterion I want to set and audit in my data.

And here's the important constraint: I want to do this **without changing the app**. Let's consider it a legacy app that I can't really touch.

## A model that listens

In [Aletyx Decision Control](https://aletyx.ai/decision-control) I created a new model for this. One cool thing is that I can work on it in Decision Control or right in my IDE — support for [VS Code](https://marketplace.visualstudio.com/items?itemName=Aletyx.automation-design) and [IntelliJ](https://plugins.jetbrains.com/plugin/33190-aletyx-automation-design) was just announced, with other IDEs coming.

There's the original quote model, which takes tickets, accidents, age, and mileage, assigns risk, and multiplies by the car's estimated value to produce the premium — we saw how that works in previous videos. The new part is the auditing side: a very simple *audit result* decision. If the risk rate is below 5% or above 12%, it's an **error** — too low or too high. Between 5 and 10 is **OK**. Between 10 and 12 it's a **warning**: perhaps a human should review it, or at least get that information somehow.

The little piece of magic is a text annotation on the model. That annotation is how I bind the event to the model: I wrote a small app that takes my models, looks up the ones annotated with that binding, and uses it to listen for events matching that data. When a message shows up on [Kafka](https://kafka.apache.org/) that matches the binding, it invokes the model and gets the result. That's my little hack.

## From the database to the model

How do the events get to Kafka in the first place? I used [Debezium](https://debezium.io/) to capture the data — a very simple integration with most databases. It reads the replication data from the database and throws it into Kafka; the messages match the model annotation and trigger the model for an audit. That's why the insurance hub needed no changes at all: no audit signal, no code change, nothing — it's all integrated through the database.

In the separate audit app I built, the quote we just made at 10.72% is correctly flagged as a warning. I can see all the messages in the Kafka queue for all the events, and my specific audit event next to them. Get another quote with reasonable values and it shows up as OK. Get one more with everything bad — accidents, tickets, high mileage, old car, the worst case — and the rate goes above the threshold, and the audit app shows an error.

## Managed, tracked, tested, versioned

It's a very simple audit rule, but the cool thing about decision management is that the plumbing just triggers the model. If your viability rules are more complex, if you have more elements in that model, you can ask AI to generate a model with all the rules you want and it will build them for you — and the audit gets the same advantages of decision models that we saw before. The rules are managed, tracked, tested, and versioned: in Decision Control I can see every version of every model, what was published, when, and by who — and change them and have the new version applied live.

So that's enterprise auditing without changing your legacy. How do you handle new audit requirements on systems you can't modify — database triggers, log scraping, or something like this? Let me know in the comments — see you in the next one!
