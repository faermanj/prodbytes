---
title: 'Accountable AI: Editing Decision Models with the Aletyx AI Assistant'
slug: aletyx-ai-assistant
date: '2026-07-22'
summary: Using the Aletyx AI Assistant to explain, change, and test decision models — getting AI productivity without giving up decisions that are traceable, auditable, and safe to trust.
---

In this video, I want to dive deeper into the accountable AI subject: creating solutions that use AI so we are more productive and helped by AI agents, without losing accountability — making decisions that are traceable, auditable, and that you can safely trust.

The tool for today is the [Aletyx AI Assistant](https://aletyx.ai/ai-assistant). You can learn more about it on that page and sign in for a free trial, so if you want to give this a try, you can without any cost. There is also a [dedicated section in the docs](https://aletyx.ai/docs/ai-assistant/overview), which is what we are going to follow here.

## Starting in the Playground

If you already have your own instance of [Aletyx Decision Control](https://aletyx.ai/decision-control) set up, you can use that. For today, though, I want to demonstrate everything on the [Aletyx Playground](https://playground.aletyx.ai/), so it is easier and everybody can follow along.

I create a new decision process from a sample: loan prequalification, deciding whether a given applicant is acceptable for a loan. On the right side of the editor sits the AI assistant — you can see what it is doing and ask anything you want.

## Explain the model

The first thing I ask is simply to *explain this model*. If you're not familiar with the boxes, the types of arrows, and what they all mean, this is a good place to get started. The assistant tells you what the process is and how it works — including what the front end ratio means (housing costs as a share of income) and the back end ratio (total obligations as a percentage of income), and how those drive the loan decision in this example.

## Change a rule in plain language

Explaining is nice, but I can also change the model. The [docs have a page of prompts](https://aletyx.ai/docs/ai-assistant/prompts) you can try on the sample, and I take one that changes a business rule: the lender acceptable DTI, the percentage of the applicant's gross monthly income relative to all monthly debt obligations, currently set at 36%.

The point of the exercise is that I describe the change in layman's terms — "change to 42% the percentage of the applicant's gross monthly income relative to all monthly debt obligations that qualifies the applicant for a loan" — deliberately not using the model's own jargon, to see whether the AI truly understands it. It does: the *Lender Acceptable DTI* node is highlighted, I can see it was changed from 36% to 42%, and I accept the change.

Same thing with the credit scoring table, where a score over 750 is excellent, then good, fair, poor, and so on. I ask it to reduce each category by 10% so it is easier to get a loan, and every layer of the credit score decision comes back reduced as asked. I can accept all changes — or, if I don't like the result, revert and try again.

That accept-or-revert step matters. The AI never silently rewrites your business logic; it proposes a reviewable edit, and a human signs off.

## Generate and pin tests

Another thing worth showing is testing. On the Run tab I can fill in the form or see it as a table — and instead of typing all those values by hand, I ask the assistant to do it on my behalf: generate a positive application with excellent applicant data. It fills in a case with an excellent credit score and offers to run it right away, and the result comes back sufficient. In the same way I ask for a negative case, and for another one with insufficient data, each generated with different details, and add them to my test set.

Then comes the part I covered in the [previous post on testing decision models](../testing-decision-models/): pinning expected values. If I want to make sure this loan prequalification is *not qualified*, I pin that as the expected outcome — and if it ever changes for some reason, the test fails. That is how you prevent your model from being improperly published: the checks live outside the AI, so no amount of confident generation gets past them.

## Changes to the model, not interpretations

You can also upload images and text — your policy documents, your data — and ask the assistant to create a decision model for you. And this is the part I care most about: what you get out of it is not an interpretation every time someone asks, but a change to the model. You can see the versions, run the tests, and make the decision available to your application in a way that is accountable — not subject to hallucinations, variations, or different interpretations on each call, just reviewed changes to your decision model.

That, to me, is what accountable AI looks like in practice: the AI does the busywork, the model stays the single source of truth, and the tests have the final word.

How are you keeping AI-assisted changes to your business logic accountable — reviewable edits and pinned tests, or trusting the output? Let me know in the comments!
