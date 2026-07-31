---
title: 'Delivering Projects on AWS: Budget Alerts'
slug: daws-s00e03-budget-alerts
date: '2026-07-27'
summary: Before creating anything on AWS, set up budget alerts — how much to set, which thresholds actually help, and how SNS lets you automate actions later.
---

Before we start publishing resources on [AWS](https://aws.amazon.com/), let's take a moment to create some security measures so we can operate confidently and safely. The first one is a budget.

If you type "budget" in the console search bar, you should see it as a [Billing and Cost Management](https://aws.amazon.com/aws-cost-management/aws-budgets/) feature. This is how we get notified — and can even take automated action if we want — around what we're spending.

## Creating your first budget

The simplified template is fine to start with. We're going to create a **monthly cost budget**, because that's the most useful one: a fixed amount that we expect to be our maximum per month. You can create other budgets later, but this is a good first one.

How much? That depends on your context. If you're running something like a personal website, $5 to $10 is plenty. A startup, an initial web app, or a small development project may be more like $20 to $50 — and that can grow as your application (and hopefully your income) grows. Also remember that if you created a free account, you'll initially be consuming the [$200 in free tier credits](https://aws.amazon.com/free/) — and setting a budget alarm is one of the challenges that earns you $20 of them, as we saw in the last episode.

## Thresholds that actually help

I called mine "max monthly cost", set it to $50, and pointed it at my email. All AWS services are in scope. The alerts:

- When the **actual** spend reaches 85%
- When the **actual** spend reaches 100%
- When the **forecast** spend reaches 100%

That's it. Now I know that if I forget something running, if there's malicious activity, or for any reason at all my spend gets even near this budget, I'm going to be notified.

And why not create another one? I added a second budget as a warning at $30 — an earlier heads-up to remind myself before things get anywhere near the maximum.

## SNS and automated actions

One interesting detail: these alerts are built on [Amazon SNS](https://aws.amazon.com/sns/), the messaging service. That means you can edit an alert and configure SMS or chatbot notifications, define them however you want — and even take automated action, because SNS is just a messaging service you can subscribe to those topics.

That's perhaps a bit too advanced for now, though. Just being notified by email is fine.

And that's how we do it. Have you set a budget on your account — and what did you set it to? Let me know in the comments — see you in the next one!
