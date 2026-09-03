---
title: 'Serverless PostgreSQL Databases'
slug: serverless-postgresql-databases
date: '2026-08-31'
summary: Storing data with Aurora Serverless PostgreSQL — the express configuration, a first taste of SQL, the same database as code, and how cross-stack references wire it into your VPC.
---

Previously on this series, we saw how to deliver files, the actual content of your website or app, [hosted on Amazon S3](https://prodbytes.substack.com/p/static-websites-on-amazon-s3): HTML, CSS, JavaScript, images, videos, whatever is static. Then we saw how to execute code with [Lambda functions](https://prodbytes.substack.com/p/functions-with-aws-sam), and we'll see other ways in the future, such as instances and containers. And last time we covered the [networking basics](https://prodbytes.substack.com/p/networking-with-amazon-vpc) we'd need before this step. Because now we need some place to store our data, and that is most often a database. Let's create one on AWS, and along the way talk about an important CloudFormation feature: cross-stack references.

> This post is part of the ["Delivering Software Projects"](https://prodbytes.substack.com/p/delivering-projects-on-aws?r=c4tlc) series, focused on helping YOU be sucessful in your tech career. Please consider becoming a member. For a small contribution, you'll help us keep the lights on and have full access to our content, events and tools.

## The express configuration

In the console, [Amazon Aurora and RDS](https://aws.amazon.com/rds/) is the service for relational databases, the kind you're most often going to find on the job. There are many ways to create a database there, and the quickest is the express configuration, which promises a database ready in seconds and pretty much delivers.

There are many database products on the market, from many different companies and development groups. This one is based on [PostgreSQL](https://www.postgresql.org/), a very mature and important database. You can use Postgres for most things related to storing, consuming, and propagating data; at this level, our data needs are perfectly covered by it. Amazon has its own implementation of parts of the database engine, called [Aurora PostgreSQL](https://aws.amazon.com/rds/aurora/). It's not exactly the same Postgres you would install on your computer, but it's pretty close: same protocol, a different brand of Postgres, let's say. The express configuration gives you version 17 and a master username, and that's about all there is to decide.

The other important property is that this is a serverless database. Just like we've been using serverless compute with Lambda and serverless content delivery with S3, [Aurora Serverless](https://aws.amazon.com/rds/aurora/serverless/) scales capacity with demand, from zero up to sixteen Aurora capacity units in this configuration. One ACU is roughly one vCPU and two gigabytes of memory, and the [pricing page](https://aws.amazon.com/rds/aurora/pricing/) has the per-ACU-hour numbers. Not knowing how much capacity we're going to need and being able to fluctuate is great for saving money. But consider the trade-off: scaling from zero is great for development, perhaps not for production, because the first query that hits a cold database will have its performance impacted. For some apps that's not a big deal, for others it can be. Test your case. We'll look at provisioned capacity in future videos.

## Connecting, and a bit of SQL

Once the database is up, the console offers code snippets to connect, an option to connect from [CloudShell](https://aws.amazon.com/cloudshell/) (more on that in the future), and the endpoints, so you can use tools like [DBeaver](https://dbeaver.io/), [VS Code](https://code.visualstudio.com/), or whatever programming tool you like. For now, the provided `psql` command is enough. One interesting thing about it: instead of a stored password, it calls [`rds generate-db-auth-token`](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.Connecting.AWSCLI.PostgreSQL.html) to authenticate with [IAM](https://aws.amazon.com/iam/), gets a temporary token, and uses that to connect. Paste it into a terminal and, as simple as that, you're on your database.

From there it's [SQL](https://en.wikipedia.org/wiki/SQL), the structured query language. `SELECT 1 + 1;` will dutifully calculate two, but it's more common to create tables and store data:

```sql
CREATE TABLE todo_item (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title text NOT NULL,
  done boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO todo_item (title) VALUES ('Test the database connection');

SELECT id, title, done, created_at FROM todo_item ORDER BY id;
```

A to-do item with a generated ID as the primary key, a title, whether it's done, and a creation timestamp defaulting to now. Insert a row, select it back, and there it is. I won't go further into SQL for now, but notice it's one language more: we've already talked about HTML, CSS, JavaScript, one programming language for your Lambda, and now SQL. That's five languages we're working with. Don't try to learn everything about each of them in a single go. Level by level: the basics of HTML, the basics of CSS, the basics of SQL, and then progress on each one.

## The same thing, as code

As usual, we don't need to do this on the console. The [DSP repository](https://github.com/prodbytes/DSP) has a template under [samples/rds-pgsql-sls](https://github.com/prodbytes/DSP/tree/main/samples/rds-pgsql-sls) that creates the same serverless Aurora PostgreSQL cluster with [CloudFormation](https://aws.amazon.com/cloudformation/).

But first, the VPC. The express configuration hides networking from you, and that's fine to get started. When we're creating our own databases, we want to place them deliberately. So start by deploying the same three-AZ network from the [previous episode](https://prodbytes.substack.com/p/networking-with-amazon-vpc), now at [samples/vpc-3az](https://github.com/prodbytes/DSP/tree/main/samples/vpc-3az): a VPC on the `10.0.0.0/16` address space, with subnets 1, 3, and 5 public and subnets 2, 4, and 6 isolated. The difference, again, is that resources in public subnets can reach and be reached from the internet, while isolated ones cannot. For databases and other sensitive software, it varies by project and organization, but on enterprises it's very common to see the database on a private or isolated subnet. Using public subnets is not necessarily insecure, there's still encryption and authentication in front of your data, but the private placement is one more level in your security stack, and that's usually a good thing.

With the network in place, the deploy commands are at the top of each template:

```bash
aws cloudformation deploy --stack-name vpc-3az \
  --template-file samples/vpc-3az/vpc-3az.cform.yaml

aws cloudformation deploy --stack-name rds-pgsql-sls \
  --template-file samples/rds-pgsql-sls/rds-pgsql-sls.cform.yaml \
  --capabilities CAPABILITY_NAMED_IAM
```

The database command has a new part: `--capabilities CAPABILITY_NAMED_IAM` (plain `CAPABILITY_IAM` would also do here). It's just a way to acknowledge that the stack creates IAM resources; in this template, a managed policy that allows clients to connect to the database with IAM authentication. Don't forget this little parameter. Inside the template, the security group works like a firewall, saying who can connect and on which port, and the subnet group places the cluster on the isolated subnets. And notice that those values are not hardcoded: they are imported.

## Cross-stack references

My first deploy of the database stack actually rolled back, which is a good thing, because errors are how we learn to troubleshoot. On the [CloudFormation console](https://console.aws.amazon.com/cloudformation/), the events tab showed the cause: an export name was already exported by another stack I had forgotten to delete. Which brings us to the feature itself.

In the VPC template, every resource we might need later is exported in the outputs:

```yaml
Outputs:
  VpcId:
    Value: !Ref VPC
    Export:
      Name: !Sub ${TenantId}-VpcId
```

And in the database template, the subnet group imports them:

```yaml
DbSubnetGroup:
  Type: AWS::RDS::DBSubnetGroup
  Properties:
    SubnetIds:
      - Fn::ImportValue: !Sub "${TenantId}-IsolatedSubnet1Id"
      - Fn::ImportValue: !Sub "${TenantId}-IsolatedSubnet2Id"
      - Fn::ImportValue: !Sub "${TenantId}-IsolatedSubnet3Id"
```

That's what [cross-stack references](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/walkthrough-crossstackref.html) are: you export an output from one stack and import it in another. The catch is that export names are globally unique per region, per account. If you export just `VpcId`, you can never export that name again in the same region, and you get exactly the error I got. The consequence is that your development, testing, user acceptance, and production copies would have to live in different regions or accounts, which is probably not what you want.

So the templates take a `TenantId` parameter, just a generic occupation name prepended to every export, defaulting to `default`. Deploy the VPC with `TenantId=dev` and the database with the same `TenantId`, and the imports line up; deploy another pair with `TenantId=test`, and nothing clashes. One, two, perhaps three parameters to identify environments is a habit that pays off quickly.

After deleting the leftover stack and deploying again, the stack completes: the cluster and the writer instance show up in the resources tab, with deep links to navigate there.

## Private means private

Since this instance is on isolated subnets, I can't connect to it directly from the internet. That's not a bug, it's exactly why we chose this placement. To reach it we'll need something inside AWS: CloudShell in a VPC, an instance, a container, and we'll see one of those in the next video. If you do want a publicly accessible database, the template has a `PubliclyAccessible` parameter and you would point the subnet group at the public subnets instead. I don't recommend it, though. The private placement is better for security, and it gets you used to the enterprise security mechanisms you're going to find in place on the job.

And as always, don't forget resources running. Even if they are serverless, it's better to delete them, and the VPC, when you don't need them anymore.

Where does your team put its databases, and has that placement ever saved you, or bitten you? Let me know in the comments, and see you in the next one!
