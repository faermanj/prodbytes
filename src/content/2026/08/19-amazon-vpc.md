---
title: 'Networking with Amazon VPC'
slug: networking-with-amazon-vpc
date: '2026-08-19'
summary: The networking essentials you need before creating databases — CIDR blocks without the mystery, public and private subnets, and a three-AZ VPC deployed from a template.
---

Previously on this series, we saw how to host [websites](https://prodbytes.substack.com/p/static-websites-on-amazon-s3), files, and even [functions](https://prodbytes.substack.com/p/functions-with-the-aws-sam). Now we need to add something very important to this mix: databases. But to talk about databases, we need to take a step back and think about security and, in particular, networking. In most companies, networking will be restricted for databases; they will not be accessible from the internet, for good reasons. So it's important to understand the very basics. If you're new to the area, or more on the coding side and in need of a refresher on how networking works on AWS, this one is for you. [Amazon VPC](https://aws.amazon.com/vpc/), Virtual Private Cloud, is the fundamental service. Let's see how it works.

> This post is part of the ["Delivering Software Projects"](https://prodbytes.substack.com/p/delivering-projects-on-aws?r=c4tlc) series, focused on helping YOU be sucessful in your tech career. Please consider becoming a member. For a small contribution, you'll help us keep the lights on and have full access to our content, events and tools.

## What it costs

As usual, the product page at [aws.amazon.com/vpc](https://aws.amazon.com/vpc/) has the pricing and features. The features we're going to use today don't have a cost directly associated with the resources, just the networking costs in general on AWS. The relevant numbers actually live on the [EC2 pricing page](https://aws.amazon.com/ec2/pricing/on-demand/), under data transfer. You don't pay for data in, everything that comes into AWS is free of charge, but to get data out there's a charge of about nine cents per gigabyte. That's the basic internet charge, if you will.

## The default VPC

In the [VPC console](https://console.aws.amazon.com/vpc/), even on a brand new account, you'll see one VPC already there. That's a special one called the [default VPC](https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html), created for you and tagged as such. This matters because otherwise you would have to create a network, and know about networking, before creating any instances, servers, or databases. It's in everybody's best interest to have a reasonably configured network you can use without worrying too much.

One property worth understanding on any VPC is the IPv4 CIDR block. [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing), Classless Inter-Domain Routing, is just a big name for a way to group octets, groups of eight binary digits. Take the default VPC's block, `172.31.0.0/16`. Each of those four numbers is eight binary digits, and the mask after the slash says how many of those bits identify the network and how many identify the host within that network. Like a name and a surname: the address of the network, then the address of the host. With `/16`, the first sixteen bits, the first two numbers, are the network, and the rest addresses hosts inside it.

```
172.31.0.0/16 (default VPC)

                      172        31         0          0
                 +----------+----------+----------+----------+
  address        | 10101100 | 00011111 | 00000000 | 00000000 |
  mask (/16)     | 11111111 | 11111111 | 00000000 | 00000000 |
                 +----------+----------+----------+----------+
                      255        255        0          0
                                       |
                                       +-- prefix ends after bit 16
                   <-- network: 16 -->  <-- host: 16 bits -->

172.31.0.0 / 20 (subnet us-east-1a)

                      172        31         0          0
                 +----------+----------+----------+----------+
  address        | 10101100 | 00011111 | 00000000 | 00000000 |
  mask (/20)     | 11111111 | 11111111 | 11110000 | 00000000 |
                 +----------+----------+----------+----------+
                      255        255       240         0
                                             |
                                             +-- prefix ends after bit 20
                    <--- network: 20 bits ---><-- host: 12 -->

172.31.0.42 / 32 (instance)
```

Subnets carve up that space with longer masks. In the default VPC the subnets are `/20`, so the first twenty bits identify the subnet and the last twelve identify the host, and every subnet has to fit within the VPC's block. You don't really need to think about this a lot, because the console suggests sensible values, but it stops being mysterious once you see it as a simple split. Everything you already know about networking, private IP ranges and so on, is still valid here. It even supports [IPv6](https://en.wikipedia.org/wiki/IPv6), which expands the address space beyond the 32 bits of IPv4, if you care, which very few people seem to do.

## Creating one with the wizard

In the console, "Create VPC" with the "VPC and more" option generates a full setup. It's always good to be as specific as possible on resource names, something like `dev` and `test`, and the wizard already suggests a `/16` CIDR block.

Then comes tenancy, where the default, shared, is what you want. And the number of [Availability Zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html), which are the sets of data centers within a region. Everything here is inside the region set in the console, Northern Virginia in my case, which has six availability zones. The wizard lets me select up to three, and in each of them I'll get a public and a private subnet.

Public and private is about whether resources are reachable from the internet. If you have a public web server or a load balancer, you need it to be public, and being public means basically two things: having a public IP address and having a route to the [internet gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html), a resource of the VPC that the wizard creates as well, wired up through the route table. In the private subnets, addresses are not publicly visible and resources are not reachable from the internet.

[NAT gateways](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html) allow connections *from inside* the private subnets out to the internet, which is useful for updates and some operations. But they have an extra cost, and it's not a low one, so I would recommend not using them if possible. If you need a NAT gateway later, you add a NAT gateway later. For now, let's start without one, not to waste any resources. Same for [VPC endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/concepts.html): when we need them and talk about internal routing, we'll cover them, but for now, none.

Finally, [DNS](https://en.wikipedia.org/wiki/Domain_Name_System), the domain name system, is what lets us refer to services and resources by name instead of weird addresses. That's probably a good thing, so enable both DNS options.

Before creating, the wizard shows a preview of how the infrastructure looks: one private and one public subnet in each AZ, identified as 1a, 1b, and 1c within us-east-1, always located within that geographic boundary. The public route table routes to the internet gateway, which provides internet connectivity, while the private one stays private. Create it, and in a moment it's done.

## The same thing, as code

The diagram above and a template to do the same as code live in the [DSP repository](https://github.com/prodbytes/DSP), under [samples/vpc-3ha](https://github.com/prodbytes/DSP/tree/main/samples/vpc-3ha). It's a [CloudFormation](https://aws.amazon.com/cloudformation/) template with exactly what we just built: three public and three private subnets, each with its own address range and tags, and the commands to create it are right there.

```yaml
# aws cloudformation deploy --stack-name vpc-3ha --template-file samples/vpc-3ha/vpc-3ha.cform.yaml
# aws cloudformation delete-stack --stack-name vpc-3ha
Description: VPC with 3 public subnets and 3 isolated private subnets.

Parameters:
  EnvId:
    Type: String
    Default: Project

  VpcCidr:
    Type: String
    Default: 10.0.0.0/16

  PublicSubnet1Cidr:
    Type: String
    Default: 10.0.1.0/24
  
  PublicSubnet2Cidr:
    Type: String
    Default: 10.0.3.0/24
  
  PublicSubnet3Cidr:
    Type: String
    Default: 10.0.5.0/24
  
  IsolatedSubnet1Cidr:
    Type: String
    Default: 10.0.2.0/24
  
  IsolatedSubnet2Cidr:
    Type: String
    Default: 10.0.4.0/24
  
  IsolatedSubnet3Cidr:
    Type: String
    Default: 10.0.6.0/24

Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCidr
      EnableDnsSupport: true
      EnableDnsHostnames: true
      Tags:
        - Key: Name
          Value: !Sub ${EnvId}-vpc

  InternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: !Sub ${EnvId}-igw

  VPCGatewayAttachment:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref VPC
      InternetGatewayId: !Ref InternetGateway

  PublicRouteTable:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC
      Tags:
        - Key: Name
          Value: !Sub ${EnvId}-public-rt

  PublicDefaultRoute:
    Type: AWS::EC2::Route
    DependsOn: VPCGatewayAttachment
    Properties:
      RouteTableId: !Ref PublicRouteTable
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref InternetGateway

  IsolatedRouteTable:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC
      Tags:
        - Key: Name
          Value: !Sub ${EnvId}-isolated-rt
        - Key: Isolation
          Value: isolated

  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: !Ref PublicSubnet1Cidr
      AvailabilityZone: !Select [0, !GetAZs ""]
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub ${EnvId}-public-a
        - Key: Tier
          Value: public

  PublicSubnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: !Ref PublicSubnet2Cidr
      AvailabilityZone: !Select [1, !GetAZs ""]
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub ${EnvId}-public-b
        - Key: Tier
          Value: public

  PublicSubnet3:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: !Ref PublicSubnet3Cidr
      AvailabilityZone: !Select [2, !GetAZs ""]
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub ${EnvId}-public-c
        - Key: Tier
          Value: public

  IsolatedSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: !Ref IsolatedSubnet1Cidr
      AvailabilityZone: !Select [0, !GetAZs ""]
      MapPublicIpOnLaunch: false
      Tags:
        - Key: Name
          Value: !Sub ${EnvId}-isolated-a

  IsolatedSubnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: !Ref IsolatedSubnet2Cidr
      AvailabilityZone: !Select [1, !GetAZs ""]
      MapPublicIpOnLaunch: false
      Tags:
        - Key: Name
          Value: !Sub ${EnvId}-isolated-b

  IsolatedSubnet3:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: !Ref IsolatedSubnet3Cidr
      AvailabilityZone: !Select [2, !GetAZs ""]
      MapPublicIpOnLaunch: false
      Tags:
        - Key: Name
          Value: !Sub ${EnvId}-isolated-c

  AssocPublicSubnet1:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref PublicSubnet1
      RouteTableId: !Ref PublicRouteTable
  AssocPublicSubnet2:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref PublicSubnet2
      RouteTableId: !Ref PublicRouteTable
  AssocPublicSubnet3:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref PublicSubnet3
      RouteTableId: !Ref PublicRouteTable

  AssocIsolatedSubnet1:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref IsolatedSubnet1
      RouteTableId: !Ref IsolatedRouteTable
  AssocIsolatedSubnet2:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref IsolatedSubnet2
      RouteTableId: !Ref IsolatedRouteTable
  AssocIsolatedSubnet3:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref IsolatedSubnet3
      RouteTableId: !Ref IsolatedRouteTable

Outputs:
  VpcId:
    Value: !Ref VPC
    Export:
      Name: !Sub ${EnvId}-VpcId

  InternetGatewayId:
    Value: !Ref InternetGateway
    Export:
      Name: !Sub ${EnvId}-InternetGatewayId

  PublicRouteTableId:
    Value: !Ref PublicRouteTable
    Export:
      Name: !Sub ${EnvId}-PublicRouteTableId

  IsolatedRouteTableId:
    Value: !Ref IsolatedRouteTable
    Export:
      Name: !Sub ${EnvId}-IsolatedRouteTableId

  PublicSubnetIds:
    Value:
      !Join [",", [!Ref PublicSubnet1, !Ref PublicSubnet2, !Ref PublicSubnet3]]
    Export:
      Name: !Sub ${EnvId}-PublicSubnetIds

  IsolatedSubnetIds:
    Value:
      !Join [
        ",",
        [!Ref IsolatedSubnet1, !Ref IsolatedSubnet2, !Ref IsolatedSubnet3],
      ]
    Export:
      Name: !Sub ${EnvId}-IsolatedSubnetIds

  PublicSubnet1Id:
    Value: !Ref PublicSubnet1
    Export:
      Name: !Sub ${EnvId}-PublicSubnet1Id
  PublicSubnet2Id:
    Value: !Ref PublicSubnet2
    Export:
      Name: !Sub ${EnvId}-PublicSubnet2Id
  PublicSubnet3Id:
    Value: !Ref PublicSubnet3
    Export:
      Name: !Sub ${EnvId}-PublicSubnet3Id

  IsolatedSubnet1Id:
    Value: !Ref IsolatedSubnet1
    Export:
      Name: !Sub ${EnvId}-IsolatedSubnet1Id
  IsolatedSubnet2Id:
    Value: !Ref IsolatedSubnet2
    Export:
      Name: !Sub ${EnvId}-IsolatedSubnet2Id
  IsolatedSubnet3Id:
    Value: !Ref IsolatedSubnet3
    Export:
      Name: !Sub ${EnvId}-IsolatedSubnet3Id
```

Before creating resources, I always recommend checking with [`aws sts get-caller-identity`](https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html) that you are using the account you expect to be using. Then `aws cloudformation deploy` deploys the template, and on the [CloudFormation console](https://console.aws.amazon.com/cloudformation/) you can watch the stack creation going on. In a minute, the VPC console shows three VPCs: the default one, the dev/test one we created from the wizard, and the one created by CloudFormation.

That last one is named after the `EnvId` parameter, which defaults to `Project`. I always like to add one, two, perhaps three parameters to identify the environment, the ownership, some metadata to classify environments properly and know what's what later.

And when you're done, never forget to delete the resources. You can do it on the console or with the delete command provided in the repository.

That's it for the networking basics. With a VPC in place, we're ready to talk about databases. Have you ever had to debug why something in a private subnet couldn't reach the internet? Let me know in the comments, and see you in the next one!
