# Terraform ondemand minecraft servers using AWS ECS

Fork of [@JKolios](https://github.com/JKolios/minecraft-ondemand-terraform)' terraform implementation of [@doctorray117](https://github.com/doctorray117/minecraft-ondemand) original idea.

My version has some extra bells and whistles that improve on it:
- spin up an arbitrary number of minecraft servers.
- deploy them in whichever AWS region you want (route53 stuff is still bound to `us-east-1` though).
- notifications by email are optional.
- doesn't use the default VPC in the account.
- enable logging for the containers themselves (good to check out issues that may occur or nasty people trying to come in).
- automatic backups.
- management EC2 instance that allows you to manually change the file of a server or apply some other needed hammer (it's turned off by default to minimize the cost).
- arbitrary environment variables for the server to allow for as much customization as one may want.
- server resource dimensioning (CPU/RAM).

You could probably start a company with just this and sell cheap minecraft servers.

This README assumes you have quite some experience with terraform and can look into each module and see for yourself what variables are needed and do what.

The `base` module has about 30 resources and the `server` module has little under 20, so it's not that complex of a terraform setup, but it is may not immediate for a first timer.
Feel free to dig in and suggest improvements, fork, ask questions, whatever really.

## Prerequisites
* An AWS account that you have admin access over.
* A route53 zone configured where the servers can be provisioned.

## Running
`main.tf` is an example of how to instantiate the 2 modules: the base, which should be instantiated once; and the server, which can be instantiated once per server.
