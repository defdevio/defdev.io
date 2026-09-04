---
title: The Interface Module Pattern
description: A discussion on how I helped implement what I call an Interface Module that helped make self-service, Infrastructure as Code (IaC) a fully declarative and easier to consume approach to automated systems delivery.
pubDate: 2026-09-01
tags:
  - IaC
  - terraform
  - opentofu
  - modules
  - hashicorp
  - CNCF
  - platform engineering
---

I was on Reddit recently when I came across the following post:

<blockquote class="reddit-embed-bq" style="height:316px" data-embed-height="316">
<a href="https://www.reddit.com/r/devops/comments/1w42bxs/anyone_else_seeing_ai_make_devopsinfra_the/">Anyone else seeing AI make DevOps/infra the bottleneck?</a><br> by
<a href="https://www.reddit.com/user/FaithlessnessEqual44/">u/FaithlessnessEqual44</a> in
<a href="https://www.reddit.com/r/devops/">devops</a>
</blockquote><script async="" src="https://embed.reddit.com/widgets.js" charset="UTF-8"></script>

The post describes a problem that many platform teams may recognize: AI-assisted development had made application developers dramatically more productive, but it had also increased the volume of infrastructure changes arriving for review.

The issue was not that the generated Terraform was obviously broken. Much of it looked plausible in isolation. The problem was that the developers, and often the LLMs assisting them, did not have enough context about the larger environment to understand how a seemingly reasonable change might interact with EKS, IAM, networking, security, CI/CD, and the organization’s existing platform conventions.

The result was an infrastructure bottleneck. Instead of reducing the platform team’s workload, AI shifted more of it toward reviewing generated changes, explaining the surrounding architecture, correcting misunderstandings, and helping developers through multiple iterations.

> We are in an age where we can create content far faster than we can consume it

I joined the discussion because I had encountered a similar problem before LLMs became part of the development workflow. My approach was to create what I call the Interface Module pattern: a narrow, opinionated infrastructure API that gives consumers a declarative way to request platform capabilities without requiring them to understand every underlying implementation detail. The result was self-service infrastructure that developers could deploy independently, while the platform team retained control over security, standards, and operational behavior.

## What is an Interface Module?
An Interface Module is an IaC module that provides a minimal consumer API for orchestrating lower-level modules in an opinionated fashion without exposing users to the underlying system's complexity. The term Interface Module is not a formal `terraform` or `opentofu` term. I use `interface` deliberately because the module’s primary purpose is to define the supported consumer contract, not merely to bundle resources.

A normal `terraform` module packages reusable infrastructure. An Interface Module packages an opinionated way of consuming a platform's capabilities.

An Interface Module should:
- Expose a deliberately small consumer API. The underlying modules may support significantly more capabilities, but the Interface Module exposes only the subset users need.
- Define a specification that is completely declarative.
- Hide low-level platform and system complexity through abstraction layers.
- Establish secure and opinionated defaults.
- Separate the consumer contract from the implementation details.
- Be released, tested, documented, and operated like a product.
- Allow the platform team to evolve the internals without forcing every consumer to understand them.

## Consumer API Contracts
Let’s start by discussing what a consumer API contract means in the context of an Interface Module. To make a self-service module easier to use we need to design our inputs with the utmost care. In the `opentofu` and `terraform` world, `variables` become our input contracts, and `outputs` define the output contracts. For consumer-facing interfaces in an Interface Module, well-designed variables are critical.

Interface Modules should typically use `for_each` to create resources from their variables. The contracts should be modeled as `map(object)` types. Use the key of the `map` to form resource names. This provides early collision detection since `terraform` and `tofu` require `maps` to have unique keys. This can also serve as a reference selector when coordinating lower-level modules. Use `object` types to define complex input contracts for multiple resources, in addition to providing a mechanism for optional configurations and sane defaults.

Here's a small example of a `lambda` contract that would be exposed from an Interface Module to orchestrate building any number of `lambda` resources:

```hcl
# variables.tf
variable "lambda_functions" {
  default     = {}
  description = "A map of Lambda Functions specs to deploy."

  type = map(object({
    spec = object({
      concurrent_executions = optional(number, -1)
      description           = string
      environment_variables = optional(map(string), {})
      timeout               = optional(number, 5)

      ecr = object({
        image_tag = string
      })
    })
  }))
}
```

This `lambda_functions` variable could then be called by a user to orchestrate the `lambda` module:

```hcl
# dev.tfvars
lambda_functions = {
  orders = {
    spec = {
      description = "Processes order events"
      
      ecr = {
        image_tag = "2026.09.1"
      }

      environment_variables = {
        NODE_ENV = "dev"
      }
    }
  }
}
```

The lower-level `lambda` module is then wired up to build any lambda function it receives from the `map`:

```hcl
# lambda.tf
module "lambda_functions" {
  for_each = var.lambda_functions
  source   = "github.com/defdevio/terraform-aws-lambda?ref=v1.1.1"

  concurrent_executions = each.value.spec.concurrent_executions
  description           = each.value.spec.description
  environment_variables = each.value.spec.environment_variables
  function_name         = replace(each.key, "_", "-")
  iam_role_arn          = module.iam.role_arns[each.key]
  image_uri             = "${module.ecr[each.key].repo_url}:${each.value.spec.ecr.image_tag}"
  timeout               = each.value.spec.timeout
}
```

## Hide Complexity
From the previous example we can see that two contractual inputs are already decided for the user. The `iam_role_arn` is provided to the lower-level `lambda` module through the output from `module.iam.role_arns[each.key]`. The Elastic Container Registry (ecr) module also uses its `repo_url` output to generate the URL for the `image_uri` while also concatenating the string with the user's supplied `image_tag` value.

Here's what is happening under the hood of the interface module:

```hcl
# iam.tf
module "iam" {
  source = "github.com/defdevio/terraform-aws-iam?ref=v1.2.0"

  account_id = "123456789012"

  roles = {
    for key, function in var.lambda_functions : key => {
      name = "lambda-execution-${replace(key, "_", "-")}"
    }
  }
}

# ecr.tf
data "aws_iam_policy_document" "lambda_ecr_pull" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:SourceARN"

      values = [
        for key, _ in var.lambda_functions :
        "arn:aws:lambda:${local.aws_region}:${local.aws_account_id}:function:${replace(key, "_", "-")}"
      ]
    }
  }
}

module "ecr" {
  for_each = var.lambda_functions
  source   = "github.com/defdevio/terraform-aws-ecr?ref=v1.0.0"

  name                 = "defdevio/lambda-${replace(each.key, "_", "-")}"
  is_immutable         = var.environment != "dev"
  repo_policy_document = data.aws_iam_policy_document.lambda_ecr_pull.json
}
```

There's a significant amount of complexity that is now completely transparent to the user. With minimal inputs, a user produces a result that is secure and ready for deployment without having to cobble the pieces together on their own. 

The `IAM` module takes care of the heavy lifting based on its own inherent design. It sets up the Lambda's execution role, and ensures it has a condition that only allows the source account's Lambda to assume it. 

On the other hand, the Interface Module ensures it uses a standardized naming convention that is based on the `var.lambda_functions` key name where each function is provided its own dedicated role, and automatically orchestrates the output contracts by wiring them into the relevant input fields.

The Interface Module also sets up the ECR with a policy that only allows the Lambda Functions to perform the necessary actions to pull the image it will use when executed. It also standardizes the repository name and ensures that it follows the organization's naming conventions to keep things consistent across environments. The Interface Module decides which environments can have mutable images. 

In the example's case, if the environment is `dev`, it will allow an image to be mutable to aid in faster development feedback loops. However, once we promote it to a higher-level environment like `test` or `prod` the image is always immutable. This helps to enforce CI/CD promotion practices. We should be continuously integrating changes in our pipelines, not pushing manual changes to images we haven't sent through the pipeline.

## Be Opinionated About Security and Non-Functional Requirements
The previous example also demonstrates how an Interface Module can enforce security and non-functional requirements on behalf of its consumers. The ECR repositories are created with policies that grant image-pull access only to the Lambda functions declared in `var.lambda_functions`. The policy is generated automatically from the consumer’s input, applying least-privilege access without requiring the consumer to write IAM policy documents.

The policy also restricts access by the Lambda function’s source ARN. This helps protect against the AWS confused deputy problem by ensuring that another Lambda function, even within the same account, cannot use the repository simply because it runs under the same AWS service principal. These safeguards are part of the Interface Module’s implementation rather than optional configuration that each consumer must understand and reproduce.

## Design for Personas, Not Use Cases
Interface Modules should be designed around the behaviors and needs of specific personas within an organization. They should be opinionated enough to streamline development operations and increase delivery velocity, while the lower-level modules remain flexible enough to support platform teams and unusual integrations.

Platform teams often need bespoke configurations for third-party integrations. If those requirements were enforced directly in a lower-level module, the module could become cluttered with exceptions and feature flags. Instead, the Interface Module provides the appropriate contract for each consumer group. Teams with less infrastructure experience get a focused interface with sensible safeguards, while platform teams can use the lower-level modules directly when they need capabilities outside that contract.

This also means lower-level modules do not need to be fractured into separate variants for every persona. An Interface Module can expose only the capabilities appropriate for its consumers while the underlying module continues to support a broader set of use cases.

For example, the lower-level `terraform-aws-iam` module shown earlier does not validate whether `custom_iam_policy_statements.resources` contains a wildcard value such as `*`. A wildcard may be legitimate for some platform integrations, such as account-wide monitoring. Adding that validation to the lower-level module would either prevent those use cases or require a feature flag that could be easy to overlook.

Let’s return to the Lambda contract from earlier with this new context in mind. We can extend it with custom IAM policy statements for cases where application specific permissions are needed. The lower-level IAM module supports this capability, but the Interface Module can apply stricter rules for application developers.

Developers commonly reach for `*` when they are trying to get an application working quickly. The Interface Module can prevent that shortcut by rejecting wildcard values in both `actions` and `resources` before the configuration produces a valid plan.

The relevant addition to the original contract looks like this:

```hcl
# Added inside `var.lambda_functions.spec`
custom_iam_policy_statements = optional(list(object({
  actions   = set(string)
  effect    = optional(string, "Allow")
  resources = set(string)
  sid       = optional(string)

  conditions = optional(list(object({
    test     = string
    values   = set(string)
    variable = string
  })), [])
})), [])
```

We can then prevent users from passing wildcard values in the `resources` or `actions` fields by validating the input like this:

```hcl
validation {
  condition = alltrue(flatten([
    for _, function in var.lambda_functions : [
      for _, statement in function.spec.custom_iam_policy_statements : !contains(statement.resources, "*") && !contains(statement.actions, "*")
    ]]
  ))
  error_message = <<-EOM
    All Lambda functions must not use wildcard (*) in their custom IAM policy statement resources or actions.
  EOM
}
```

Finally, we pass the validated statements through the IAM orchestration we saw earlier:

```hcl
roles = {
  for key, function in var.lambda_functions : key => {
    name                         = "lambda-execution-${replace(key, "_", "-")}"
    custom_iam_policy_statements = function.spec.custom_iam_policy_statements
  }
}
```

## Wire in Dependencies Automatically
Let’s take this one step further by showing how an Interface Module can help developers consume the opinionated services it creates. We’ll add an `s3_buckets` contract and use it to provision the lower-level `terraform-aws-s3` module. Then we’ll use the resulting bucket ARN as a Lambda environment variable, allowing the application to access the bucket without requiring the developer to assemble or pass those resource details manually.

First, we’ll define the consumer contract and wire it to the lower-level S3 module:

```hcl
# variables.tf
variable "s3_buckets" {
  default     = {}
  description = "S3 bucket specifications, optionally associated with a Lambda function key."

  type = map(object({
    spec = object({
      resource_key_ref    = optional(string, null)
      source_file_path    = optional(string, null)
      source_file_pattern = optional(string, null)
    })
  }))

  validation {
    condition = alltrue([
      for _, bucket in var.s3_buckets :
      bucket.spec.resource_key_ref == null ? true : contains(keys(var.lambda_functions), bucket.spec.resource_key_ref)
    ])
    error_message = "Each non-null S3 resource_key_ref must match a key in lambda_functions."
  }
}
```

```hcl
# s3.tf
module "s3" {
  for_each = var.s3_buckets
  source   = "github.com/defdevio/terraform-aws-s3?ref=v1.2.0"

  resource_key_ref    = each.value.spec.resource_key_ref
  source_file_path    = each.value.spec.source_file_path
  source_file_pattern = each.value.spec.source_file_pattern

  bucket_name = replace(
    substr(
      "${var.account_id}-${replace(each.key, "_", "-")}-${var.aws_region}", 0, 63
    ), "-", ""
  )

  iam_role_arn = each.value.spec.resource_key_ref != null ? format(
    "arn:aws:iam::%s:role/lambda-execution-%s",
    var.account_id,
    replace(each.value.spec.resource_key_ref, "_", "-")
  ) : null
}
```

The optional `resource_key_ref` lets a bucket declare which Lambda function should receive access. The Interface Module resolves that reference against the roles it created for `var.lambda_functions` and passes the resulting role ARN to the lower-level S3 module.

This keeps the relationship expressed as a logical function key instead of forcing developers to manually look up or pass IAM role ARNs. The same value is also passed through to the lower-level module so it can associate each bucket with the correct Lambda function.

We also added a validation block to ensure that a non-null `resource_key_ref` matches one of the keys in the `var.lambda_functions` map. This gives developers early feedback before planning succeeds with an invalid relationship.

The Interface Module derives the bucket name from the account ID, resource key, and AWS Region. It also constructs the expected `iam_role_arn` so the dependency can be resolved during planning, even when the related resources use `count` or `for_each` and are not known until apply time. 

This avoids collisions between environments while enforcing the platform’s naming convention. The Interface Module also ensures that the bucket name is no longer than 63 characters to comply with Amazon S3 bucket naming requirements.

Next, we’ll make the resulting bucket ARN available to the Lambda function that references the bucket.

```hcl
# lambda.tf
locals {
  lambda_environment_variables = {
    for function_key, _ in var.lambda_functions : function_key => {
      "DEFDEVIO_BUCKET_ARNS" = length(var.s3_buckets) > 0 ? join(",", [
        for _, s3 in module.s3 : s3.bucket_arn 
        if s3.resource_key_ref == function_key
      ]) : ""
    }
  }
}

module "lambda_functions" {
  for_each = var.lambda_functions
  source   = "github.com/defdevio/terraform-aws-lambda?ref=v1.1.1"

  concurrent_executions = each.value.spec.concurrent_executions
  description           = each.value.spec.description
  function_name         = replace(each.key, "_", "-")
  iam_role_arn          = module.iam.role_arns[each.key]
  image_uri             = "${module.ecr[each.key].repo_url}:${each.value.spec.ecr.image_tag}"
  timeout               = each.value.spec.timeout

  environment_variables = merge(
    each.value.spec.environment_variables, 
    local.lambda_environment_variables[each.key]
  )
}
```

This is another example of how the Interface Module hides complexity. We generate environment variable maps from `var.lambda_functions` and can extend them later as the module adds support for more resource types. 

In this example, we create a `DEFDEVIO_BUCKET_ARNS` environment variable containing a comma-separated list of bucket ARNs. The list includes only the buckets whose `resource_key_ref` matches the current Lambda function’s key. 

The application can then discover its associated buckets without needing to look up or construct those ARNs itself. This pattern becomes especially useful for resources that generate unique names or endpoints. RDS clusters, ElastiCache clusters, and AWS Secrets Manager secrets may include generated characters to ensure uniqueness within a Region or tenant.

## Test, Test, and Test Some More!
The key differentiator between a simple abstraction layer and an enterprise platform product is testability. IaC testing is often overlooked, but moving from treating IaC as a script to treating it as a product means automated testing must be part of the service offering. Just as software teams use unit and integration tests to build confidence in a release, the Interface Module and its lower-level modules need tests that provide the same kind of assurance.

The lower-level modules define their own unit-test contracts. You can use the built-in testing frameworks in `tofu` or `terraform` to mock providers, or use a full testing suite such as `terratest`. 

I personally recommend `terratest` because it is written in Go and can validate behavior after apply, rather than only checking mocked plan-time behavior. Go also gives you access to the `testify` package, which provides useful `assert` and `require` helpers for writing readable tests. 

For post-apply verification, you can use Gruntwork's AWS helpers or call the AWS SDK for Go directly to inspect the resulting infrastructure and assert its actual state. In my experience, many of the most important complications appear at apply time, which is where `terratest` shines.

Here is an excerpt from the `terratest` suite for the lower-level `terraform-aws-iam` module:

```go
// main.go
func TestCustomIAMPolicyStatements(t *testing.T) {
    defer terraform.DestroyContext(t, ctx, options)
    plan := terraform.InitAndPlanAndShowWithStructContext(t, ctx, options)

    role := requireResource(t, plan.ResourceChangesMap,
        `module.iam.aws_iam_role.this["application"]`)

    assertTrustPolicyUsesSourceAccount(t, role)
    assertCustomPolicyContainsExpectedStatements(t, plan)

    terraform.InitAndApplyAndIdempotentContext(t, ctx, options)
}
```

The test provisions the module with a preset fixture and converts the resulting plan into a Go struct. This lets us inspect the planned resources and verify that the expected trust policies and custom IAM policy statements are present. We then apply the module and run `InitAndApplyAndIdempotent`, which verifies that a subsequent apply produces no changes. That gives us confidence that the module is both correctly configured and idempotent.

> The full suite performs additional assertions, but this excerpt focuses on the core testing workflow.

Next, the Interface Module tests validate the orchestration layer:

```go
// main.go
func TestInterfaceModule(t *testing.T) {
    defer terraform.DestroyContext(t, ctx, options)
    plan := terraform.InitAndPlanAndShowWithStructContext(t, ctx, options)

    requireResource(t, plan.ResourceChangesMap,
        `module.iam.aws_iam_role.this["orders"]`)
    requireResource(t, plan.ResourceChangesMap,
        `module.ecr["orders"].aws_ecr_repository.this`)

    terraform.InitAndApplyAndIdempotentContext(t, ctx, options)

	repository := aws.GetECRRepoContext(t, ctx, "us-west-2", ecrName)
	require.Equal(t, ecrName, *repository.RepositoryName)
	require.Equal(t, "IMMUTABLE", string(repository.ImageTagMutability))
}
```

This test is very similar to the previous lower-level module test, except that it focuses more on apply-time behavior. The suite runs the plan and returns it as a Go struct, then validates that the expected resources are present based on the test fixture inputs. It runs `InitAndApplyAndIdempotent` to verify that the module applies successfully and that a subsequent apply is a no-op. 

The harness then checks the resulting resource state against the actual API to ensure that the orchestration layer produces resources that follow our naming conventions, security standards, and other requirements for self-service consumption.

The `terratest` suite should run on every pull request as a required check. In GitHub Actions, this can be implemented with an `on.pull_request` workflow and a repository ruleset that requires the check to pass before the pull request can be merged. The pull request also requires two approvals from platform team members listed as `CODEOWNERS`. Once the pull request is merged, a separate workflow releases the module to a hosted module registry.

## Delivering a Production Self-Service Solution
The Interface Module I mentioned in my Reddit comment was much broader in production than the simplified examples in this article. It provides a catalog of the infrastructure capabilities that application teams commonly needed:

- Argo CD application deployment through a consumer-facing interface, backed by a centralized and opinionated Helm chart. The chart provided platform services such as Litmus Chaos, Cilium Network Policies, Argo Events, Rollouts, Workflows, and External Secrets. Developers could also receive connection details for resources such as RDS clusters, RDS Global Clusters, and ElastiCache clusters as container environment variables, without wiring those dependencies together themselves.
- IAM roles backed by IAM Roles for Service Accounts (IRSA), including the appropriate OIDC federation endpoints for the relevant EKS clusters.
- Aurora Serverless v2 PostgreSQL clusters and Global Clusters, with options to create a new cluster or connect to a shared cluster in the same account. An `application_tier` setting controlled whether a Global Cluster was created and defined the replication level provided by the Interface Module.
- AgentCore Runtime
- ACM Certificates
- CloudWatch Log Groups
- ElastiCache
- Entra ID App Registrations
- EventBridge
- EC2
- ELB
- ALB
- KMS
- Lambda functions
- OpenSearch
- PingOne Applications
- S3
- Secrets Manager
- Security Groups
- SNS
- SQS

> All the modules that support IAM policies receive the relevant resource ARNs from the Interface Module so they can apply least-privilege policies. Where possible, we prefer resource-based policies over identity-based policies because this helps us avoid running into limits on the number of policies attached to an IAM role. We apply the same principle to KMS keys: we create a single KMS key for each module call and use it to encrypt any resources that support KMS encryption.

The important point is not the number of services in the catalog, but the fact that those capabilities can be composed through a single, application-oriented specification. A team can define its application, the resources it needed, and the relationships between those resources without manually passing generated names, ARNs, endpoints, or IAM configuration between separate modules. This was especially helpful when platform teams needed to troubleshoot. They could look at the Interface Module configuration and quickly understand the infrastructure involved.

For application teams, this meant they could provision large infrastructure stacks without having to worry about all the usual complexity involved. The security, encryption, naming conventions, and cross-resource wiring were already figured out for them. Once teams started using it en masse, I received a significant amount of feedback from developers across the organization about how much they loved it. Many told me they “no longer had to think about infrastructure,” which was exactly the goal I had set out to achieve.

Today, the Interface Module is a widely discussed product within our technology department. Almost everyone uses it because it makes infrastructure fast and easy to provision, which has made it especially useful for prototyping. Teams have even used it to deliver prototypes during hackathons! It became popular enough that, at one point, our CFO was encouraging people in town halls to use it: “If you’re not using it, you should be!”

For platform teams, this meant that a significant burden was taken off our shoulders. Development teams were building their own infrastructure, so our support could focus on adding new features, fixing bugs, and taking the module through the usual software development life cycle.

With the platform team no longer spending as much time answering the same infrastructure questions, we have additional capacity to focus on creating and using agents to make the Interface Module easier to understand and use. We document the API specifications and product functionality in Confluence, then connect an OpenSearch Knowledge Base to index the relevant pages. By giving an agent access to that knowledge base as its source of truth, we can help developers build new patterns and troubleshoot problems with the Interface Module by providing another self-service offering.

## Conclusion
Many readers coming from Reddit may have expected me to talk about Backstage, Port, or another internal developer portal. Those are all useful tools, but they carry real platform overhead. The point here is simpler: `terraform` and `opentofu` already give us enough building blocks to create self-service infrastructure without forcing teams into a heavier UI or TypeScript-driven platform layer. If this pattern helps you design better developer experiences for your teams, that is the outcome I hoped to illustrate!

In the comments section, I’d love to hear about your experiences creating self-service infrastructure, and any feedback about the Interface Module pattern! I’m also open to answering any questions folks out there might have about this topic, or anything related to building and delivering software in the cloud!

For readers who want to go deeper, I put together two concrete examples that show the pattern in practice:

1. The Interface Module we started building together, shown here as a complete working example with some Terratest validations. You can review and run it by opening a pull request: [interface-module-example](https://github.com/defdevio/interface-module-example)
2. A stack that calls the Interface Module so you can see firsthand the developer experience it is designed to emulate: [interface-module-stack-example](https://github.com/defdevio/interface-module-stack-example/blob/main/main.tf)
