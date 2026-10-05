---
title: 'Your Own Secure Domain'
slug: your-own-secure-domain
date: '2026-09-24'
summary: Delivering on your own domain name with HTTPS — a Route 53 hosted zone, a free ACM certificate, and a CloudFront distribution, wired together with CloudFormation to redirect a domain anywhere you like.
---

In this one, let's start talking about domain names, how they work, and how they map to AWS resources. This is really important to deliver our solutions. We don't want to hand our users an S3 URL, a generated service address, or localhost. We need to deliver something.com, or .dev, or .ai, whatever fits your project. And when users reach that address, we want the little padlock in the browser, meaning the connection is encrypted with a digital certificate.

On AWS, that takes three services working together: [Amazon Route 53](https://aws.amazon.com/route53/) for the domain name service (DNS), [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/) (ACM) for free HTTPS certificates validated by DNS records, and [Amazon CloudFront](https://aws.amazon.com/cloudfront/), the content delivery service we'll use a lot in this series, to actually serve our content with those certificates. Let's see how the three interact.

> This post is part of the ["Delivering Software Projects"](https://prodbytes.substack.com/p/delivering-projects-on-aws?r=c4tlc) series, focused on helping YOU be sucessful in your tech career. Please consider becoming a member. For a small contribution, you'll help us keep the lights on and have full access to our content, events and tools.

## Regions and points of presence

If you look at the [AWS global infrastructure map](https://aws.amazon.com/about-aws/global-infrastructure/), the regions are only a small part of it. There are many more points of presence, the edge locations spread all over the world. For services that are very sensitive to latency, like DNS resolution and content delivery, we want the answer to come from as close as possible to the end user. A user in Colombia can reach an edge location much closer than the regions in São Paulo or Virginia.

That's why Route 53 and CloudFront are global services, not tied to a specific region. The exception is the certificate. Certificates do live in a region, and for CloudFront that region [must be us-east-1](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https-requirements.html), in Virginia. Keep that in mind, it's a common source of confusion.

## Registering a domain and its hosted zone

On the [Route 53 console](https://console.aws.amazon.com/route53/), the first thing to notice is that managing a domain and registering it are two different things. Management happens on **hosted zones**. Registration is a bit below, on **registered domains**, where you can register a new domain or transfer one in. That's where I registered nu01.com. If I wanted another one, the .com is taken, but the .net, .org, and .info were available for somewhere between $16 and $30 a year. Pick the one you want, check out, and it's yours.

Once it's yours, the registered domain lets you change its **name servers**. This is where you tell the domain where to look up its data, which is its hosted zone. That's how this marvelous distributed database, the domain name system, works: each domain points to its name servers, and the name servers tell you which name corresponds to which address.

Note that creating a hosted zone doesn't require owning the domain. I could create a hosted zone for amazon.com, or for anythingatall.com, and it would be created, with its own list of name servers. But nothing would resolve to it until the domain registration points to those name servers, and only the owner can do that. So after creating a zone, copy its name servers to the domain registration, wherever you registered it.

## Certificates and distributions by hand

On the [ACM console](https://console.aws.amazon.com/acm/), you can request a public certificate for your domain, and also for subdomains, even with wildcards. Requesting `*.anythingatall.com` would cover dev, test, www, and whatever else you need. But you have to prove you own the domain. With [DNS validation](https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html), ACM gives you a record to create in the zone, and once that record resolves, the certificate is issued. There's also email validation, where you receive a message and confirm it, but DNS is the one that works well with automation.

Then, on the [CloudFront console](https://console.aws.amazon.com/cloudfront/), you create a distribution for the domain and point it to whoever is serving the content, the **origin**. That could be S3 for static content, a load balancer, or a function, and you can even split by path, say `/static` goes to S3 and `/api` goes to [AWS Lambda](https://aws.amazon.com/lambda/). You can put pretty much anything behind a CloudFront distribution.

However, creating certificates, distributions, and zones like this is not a great idea, mostly because of the mistakes you can make. You need to copy the IDs each one generates into the next: the distribution references the certificate, the certificate references the hosted zone, the zone references the distribution. A much better idea is to do it all as code.

## Owning the redirect

Before the code, a word on why I care about this. Owning the domain lets you own the redirect. Whatever platform you use for your content, Substack in this case, or LinkedIn, or YouTube, if you share your own domain instead of the platform's address, you can move somewhere else in the future. If you're not satisfied with the rules, the algorithm, or whatever else the platform decides to do, you change where the domain points and your links keep working. It's a good idea to own your domain.

So the example here is exactly that: making nu01.com redirect to prodbytes.substack.com, securely.

## Doing it with CloudFormation

The templates live in the [DSP repository](https://github.com/prodbytes/DSP), one for each piece: [samples/route53-zone](https://github.com/prodbytes/DSP/tree/main/samples/route53-zone) for the hosted zone, [samples/acm-cert](https://github.com/prodbytes/DSP/tree/main/samples/acm-cert) for the certificate, and [samples/s3-redirect-https](https://github.com/prodbytes/DSP/tree/main/samples/s3-redirect-https) for the redirect. If you missed how templates work, the [CloudFormation episode](https://prodbytes.substack.com/p/automation-with-aws-cloudformation) covers the basics.

The zone is not a lot of code. It takes a tenant ID and the domain name, creates the hosted zone, and exports its ID, name, and name servers:

```yaml
Resources:
  HostedZone:
    Type: AWS::Route53::HostedZone
    Properties:
      Name: !Ref DomainName

Outputs:
  HostedZoneId:
    Value: !Ref HostedZone
    Export:
      Name: !Sub ${TenantId}-HostedZoneId
  NameServers:
    Value: !Join [",", !GetAtt HostedZone.NameServers]
    Export:
      Name: !Sub ${TenantId}-NameServers
```

The tenant ID is just a practice of mine, not something you're forced to do. I use a simple ID to identify the usage, here `nu01`, without the .com, because the same name could have .ai, .app, or .net variants. It's useful mostly because the [exports](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-stack-exports.html) are named after it, so every stack for that tenant finds the right values. Some people use an environment ID, a cost center, whatever helps classify their resources.

The certificate imports those values and asks for DNS validation, naming the hosted zone:

```yaml
  Certificate:
    Type: AWS::CertificateManager::Certificate
    Properties:
      DomainName:
        Fn::ImportValue: !Sub "${TenantId}-HostedZoneName"
      ValidationMethod: DNS
      DomainValidationOptions:
        - DomainName:
            Fn::ImportValue: !Sub "${TenantId}-HostedZoneName"
          HostedZoneId:
            Fn::ImportValue: !Sub "${TenantId}-HostedZoneId"
```

Because the zone is named, CloudFormation creates the validation record itself, with no manual DNS step. There's a catch, though: the stack waits until the certificate is validated, so the domain must already be delegated to this zone's name servers, or it just hangs.

Finally, the redirect. It creates an S3 bucket with no objects at all, only a [website configuration](https://docs.aws.amazon.com/AmazonS3/latest/userguide/how-to-page-redirect.html) that redirects every request to the target host:

```yaml
  RedirectBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName:
        Fn::ImportValue: !Sub "${TenantId}-CertificateDomainName"
      WebsiteConfiguration:
        RedirectAllRequestsTo:
          HostName: !Ref TargetHostName
          Protocol: https
```

An empty bucket is about as cheap as it gets just to redirect a URL. In front of it goes a CloudFront distribution, using the certificate we just created through a cross-stack reference, and a Route 53 alias record pointing the domain to the distribution. The [full template](https://github.com/prodbytes/DSP/blob/main/samples/s3-redirect-https/s3-redirect-https.cform.yaml) has comments on the less obvious choices, like why caching is disabled for a redirect.

To deploy everything in order, [gitops/nu01/nu01-deploy.sh](https://github.com/prodbytes/DSP/blob/main/gitops/nu01/nu01-deploy.sh) sets the tenant, the domain, and the target:

```bash
export TENANT_ID="nu01"
export DOMAIN_NAME="nu01.com"
export TARGET_HOST_NAME="prodbytes.substack.com"
```

Then it deploys the zone, updates the registered domain's name servers if they don't match the zone (since nu01.com is registered with Route 53 in the same account), and deploys the certificate and the redirect. Run it, and on the [CloudFormation console](https://console.aws.amazon.com/cloudformation/) you can watch the stacks being created, starting with the Route 53 zone, until everything is create complete.

## Checking how it all connects

On the zone stack's resources, there's the hosted zone, and the most important information in it is the name servers. Do check that they match the ones configured in your domain registration. Nothing works until they do. In the zone you'll also find the CNAME record that validated the certificate, and once that record resolves, ACM issues the certificate and the distribution can use it.

The distribution has a single origin, the S3 static website endpoint of that empty bucket. On the bucket, under properties, at the very end, static website hosting is enabled and redirects all requests to prodbytes.substack.com.

So in the end, this is a long explanation and setup to make sure nu01.com resolves to prodbytes.substack.com. To see it happen, open your browser's developer tools, like [Chrome DevTools](https://developer.chrome.com/docs/devtools), on the network tab, and type the domain. The first request returns a `301 Moved Permanently`, sent from S3, and its location header points to the target. Everything secure and working.

## Why CloudFront in the middle

It may look like a lot of services for a redirect, but CloudFront is not optional here. The S3 static website endpoint [doesn't support HTTPS](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteEndpoints.html), so CloudFront is the service that holds our certificate and actually delivers the content securely. Here it's a simple redirect, but it could be an entire app.

And that's where we're going with it. With caching in front of both static and dynamic content, CloudFront helps with latency, serving from the edge. It helps with cost, because cached content means fewer requests to your origins. And it's safer, because an attacker has to get through the whole CloudFront network first, and that is a lot less likely to succeed than going straight at your resources. There's more, like [AWS WAF](https://aws.amazon.com/waf/), the web application firewall, that we'll use when we deliver entire apps.

For now, the things to remember: the Route 53 hosted zone decides which names resolve to which destination, here an alias record pointing the domain to the distribution. The ACM certificate, issued and validated through DNS at no additional cost, makes HTTPS work. And CloudFront delivers it all, in front of whatever origin you choose, even an empty bucket.

That's how to set up domain names, hosted zones, certificates, and CloudFront. Do you own the domains your links point to, or do they belong to a platform? Let me know in the comments, and see you in the next one!
