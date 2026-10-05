---
title: 'Users and Permissions with Amazon Cognito'
slug: users-and-permissions-with-amazon-cognito
date: '2026-09-28'
summary: Knowing who your users are and what they can do with Amazon Cognito, using user pools for sign-in with OpenID Connect and identity pools to trade that sign-in for temporary AWS credentials.
---

In most software projects, we need to know who the users are and what they can do on the system. The first part is authentication, the second is authorization. For both, we're going to use [Amazon Cognito](https://aws.amazon.com/cognito/), the AWS service to manage authentication and authorization for our own apps.

We've already been using [IAM](https://aws.amazon.com/iam/), which also does authentication and authorization, but for operations on AWS services themselves: who can create a bucket, deploy a stack, or connect to a database. Cognito is aimed at our app and the people using it. It has two features, user pools and identity pools, so let's see what each one does.

> This post is part of the ["Delivering Software Projects"](https://prodbytes.substack.com/p/delivering-projects-on-aws?r=c4tlc) series, focused on helping YOU be sucessful in your tech career. Please consider becoming a member. For a small contribution, you'll help us keep the lights on and have full access to our content, events and tools.

## User pools, a user database done right

[User pools](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools.html), as the name says, are like user databases. They're a bit different from a traditional database, but you can think of one as a user database with everything implemented correctly. And that's the point. Password storage, password management, rotation, and validation are not trivial to build, and getting any of them slightly wrong can have serious security consequences. So we avoid building them ourselves, and rely on Cognito and the web standards for authenticating users.

You've probably seen those standards at work. When you log in with Google, for example, the app redirects you to Google, shows a consent screen where you agree to share your data, and then Google sends you back to the app with your credentials and information. That's [OAuth 2.0](https://oauth.net/2/), and [OpenID Connect](https://openid.net/developers/how-connect-works/) (OIDC) is the identity layer built on top of it. The specifications define flows for different kinds of clients: a traditional web app, where the browser is redirected between pages; a single page app, like a [React](https://react.dev/) app that stays on one page and swaps components; a native mobile app; or no human at all, when it's one app calling another.

## Creating a user pool

On the [Cognito console](https://console.aws.amazon.com/cognito/), creating a user pool starts with picking the application type, and I went with the traditional web app. Then you choose how users identify themselves, email, phone number, or username, and whether to add social and federated login right after.

Here's the first real decision: do you want your own user registry on Cognito at all? For most web apps I've been building these days, I don't need one. Users can log in with Google, Facebook, LinkedIn, or whatever they already have. But in some corporate scenarios, keeping your own registry is important, and that's possible here too. You also decide whether users can [sign up by themselves](https://docs.aws.amazon.com/cognito/latest/developerguide/signing-up-users-in-your-app.html) or whether an administrator has to create or approve them.

Once the pool is created, the console shows quick start code to integrate it with popular languages and frameworks. You can also use security libraries you may already know, like [Spring Security](https://spring.io/projects/spring-security) for Java or [Better Auth](https://www.better-auth.com/) for Node. That works because the integration is plain OpenID Connect, an open web standard you can use in any language or framework, not something specific to Cognito.

## Why put Cognito in the middle

You could, of course, use an authentication provider directly and have your app talk to Google on its own. But then each app has to integrate with each provider's specifics, and if you have multiple apps, they do that again and again.

With Cognito in the middle, there's a bit more complexity: your app redirects to Cognito, Cognito redirects to the provider, and the answer comes back through the same chain. But once that's set up, it works for as many apps as you want, without redoing the integration work. That centralization is the main reason I'd consider it.

The app client configuration gives you control over how each app uses the pool. The branding area lets you set a custom domain, colors, and logos for the [managed login pages](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-managed-login.html), so you get a working login page without writing one. Or you can build your own login page and just call the APIs.

Under social and external providers, you add the client ID and secret for each service you want to federate with. Facebook, Google, Amazon, and Apple are built in. There's also [SAML](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-saml-idp.html), which is how you'd connect a corporate directory like Active Directory, and any other [OpenID Connect provider](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-oidc-idp.html).

There are also features that are hard to get right if you're not experienced with security code, like [threat protection](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pool-settings-threat-protection.html) to detect compromised credentials and suspicious sign-ins, with logs you can inspect. Be aware that those come with the higher [feature plans](https://aws.amazon.com/cognito/pricing/), so check the pricing before you turn them on.

That's user pools, the authentication part: getting to know who the users are.

## Identity pools, trading a login for credentials

The second feature is [identity pools](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-identity.html), which is kind of a poor name, because it's not really a pool of identities. It's a way to get temporary AWS credentials based on an identity the user already has. The key idea is that you exchange an authentication token for an IAM role.

When creating one, you choose which users to trust: authenticated users, guest access, or both. That means you can give different permissions to logged in users and to anonymous users, because anonymous users may need to reach some services as well. Then you add the identity sources. I picked the user pool and its app client, but you can also trust social providers directly. They're separate features, and you don't need user pools to use identity pools.

The important part is the role. I created one for authenticated users, and its policy defines what those users are allowed to do on other AWS services. Once a user is authenticated, the identity pool assumes that role for them, and the app receives AWS credentials: an access key, a secret key, and a session token, all temporary.

## Calling AWS directly from the client

What that buys you is calling AWS services straight from the client. Say you're building a picture app and users publish photos. Those pictures should land on [Amazon S3](https://aws.amazon.com/s3/), the object storage we've been using. Without identity pools, the app sends each picture to your backend, and the backend places it in the correct bucket with the correct metadata. Retrieving works the same way in reverse: ask the backend, get the list from the database or from S3, send it back.

With identity pools, the app assumes the role and puts or gets the objects on S3 directly, without necessarily going through your backend. That saves a round trip and a lot of bytes passing through servers you pay for.

Still, it's a design choice, not an upgrade. For some features it's great. For others you want the backend involved, to validate the content, record it in your database, or enforce rules a policy can't express. And if the client talks to AWS directly, the role's policy is your only guard, so scope it tightly. For example, use the [`cognito-identity.amazonaws.com:sub` policy variable](https://docs.aws.amazon.com/cognito/latest/developerguide/iam-roles.html) so each user only reaches their own prefix in the bucket, instead of the whole thing.

## Putting it together

So if you choose Cognito, you use user pools for authentication, to keep your own database of users or to federate with social and corporate ones. And you use identity pools, whether users were authenticated by a user pool or directly by a provider, to trade that token for a role and reach S3 and the other AWS services your app needs.

Neither is mandatory. You can log in with Google directly and keep everything behind your backend. But having Cognito in the middle gives you flexibility, and it saves you from doing the same security work over and over again.

Next, we'll see how to integrate Cognito on the application side, in code. Until then: do you keep your own user database, or do you let Google and friends do it for you? Let me know in the comments, and see you in the next one!
