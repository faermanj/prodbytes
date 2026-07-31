---
title: 'Testing Decision Models: Checks the AI Cannot Vibe Away'
slug: testing-decision-models
date: '2026-07-16'
summary: How to test decision models — scenarios and expected values in the authoring tool, threshold assertions that survive change, and JUnit sweeps over real data.
---

In this video, let's continue our journey into enterprise software development and decision making in those applications. If you're familiar with rules engines like [Drools](https://aletyx.ai/docs/drools/overview) or [Apache KIE](https://aletyx.ai/docs/components/overview), that's exactly the kind of thing we're talking about here — and if not, don't worry, I'll show everything step by step. Today the subject is testing: how to make sure your application works as expected when the business logic lives in a decision model. This is especially important now with AI, because most of us don't really know what's going on inside the AI's little brain — so having an external check on the outcome is more valuable than ever.

## The vehicle insurance broker app

The app I'm building to demonstrate these concepts is a vehicle insurance broker, and all the source code is in the [insurance-hub](https://github.com/prodbytes/insurance-hub) repository on GitHub. I'm trying to use the same kind of software you'd probably find in an enterprise scenario: a [Java](https://dev.java/) app with [Vaadin](https://vaadin.com/) as the web framework — though of course you can use any framework you like.

In the demo I fill a quote with random values and get a 2024 Ford Explorer, with accidents and traffic tickets in the driver's past. The quote comes back at $2,112 a year, calculated from a vehicle value estimated at $33,000 and a rate estimated at 6.4%.

So how was that calculated? Not by my code. The pricing is managed by an external decision management service — in my case [Aletyx Decision Control](https://aletyx.ai/decision-control), which I recommend taking a look at. Under the hood it's Drools and the other [Apache KIE](https://aletyx.ai/docs/components/overview) projects we know and love from the open-source world, with the enterprise features that matter on top: security, observability, tracking, and so on.

## Models are just code

To show how the model gets there, I delete my quote model and import it again — just select the folder with the model files, straight from the app's source code, and upload it. You can also download models from Decision Control back into your repository, or more simply ask AI to do it. Because a decision model, under the hood, is just code in a text format, your preferred assistant — [Claude](https://claude.com/claude-code), [Copilot](https://github.com/features/copilot), whichever — can read and write it like any other language. Aletyx also offers an AI assistant integrated directly into Decision Control, so you can ask whatever you want out of your model right there.

The quote is built from two decisions. The first is the estimated value of the car, mapped as a simple decision table: given the make, model, and year, decide what it's worth. Our 2024 Ford Explorer lands at $33,000.

## Scenarios and expected values

Now, the testing. In the authoring tool I can run the model directly: say I have a Ford Explorer 2024 and, not surprisingly, it computes the estimated value. I can view the scenario as a form or as a table, and the table view is where it gets useful — I can add as many input cases as I want.

The interesting part is *pinning expected values*. If I pin the estimated value at 33, the tool will ensure the model keeps producing 33 for that input. To demonstrate, I change the expectation to 32: the scenario immediately shows red, and if I try to publish anyway, the tool refuses — the test failed, you shouldn't publish. Fix the expectation back to 33, everything passes, and the model can be published and used in other decisions.

That's the decision-model equivalent of a failing build blocking a merge: the model cannot reach production while its scenarios disagree with it.

## Assertions that survive change

The second model calculates the insurance premium. It takes the car's estimated value, the driver's age, tickets, mileage, and accidents; assigns each a risk factor; and combines them into a risk rate — this time with a formula instead of a table. You can mix and match expressions, tables, and other forms of calculation in the same model.

Running a scenario for that $33,000 car with 500,000 kilometers, a driving history of fourteen years, plus accidents and tickets, the premium comes out higher, with a risk rate of 0.082.

Here's the thing, though: pinning *exactly* 0.082 would be a brittle test. As the rules evolve — maybe I give a little more weight to age, or to accidents — that number is going to float, and that's fine. What I actually care about is that it never crosses a viability threshold: if the yearly premium is 20% of the car's value, nobody is going to accept the policy. So instead of an exact expectation, I set the expected result as a constraint — the risk rate must stay at or below 15% — and save it. Every run now validates the rule and shows the expected condition next to the actual value from the evaluation.

Exact pins for decisions that must not change; range and threshold assertions for values that are allowed to float. Both have their place.

## Unit tests is also an option

Scenario testing in the authoring tool is great, but some kinds of tests are awkward to express there — and that's normal. We need different testing tools for different needs, the same way we have end-to-end tests, UI tests, and performance tests. The more correctness we can ensure, the better.

So alongside the app code I also have unit tests with [JUnit](https://junit.org/). Some just stimulate the model with fixed inputs, but the interesting ones query the database and assert whatever I like across the data. One test picks every maker in a range of years, every model by those makers, calculates the premium for each one automatically, and verifies that none of them surpasses the viability threshold — 15% by default. I can run it straight from the testing perspective in the IDE, and if any decision weight is wrong — if for any reason a single vehicle ends up with an unviable premium — we'll know before anyone gets that quote.

Right now, all tests are passing. Life is good.

How do you test the business logic in your applications — scenarios next to the model, code-level sweeps over real data, or hoping the AI got it right? Let me know in the comments!
