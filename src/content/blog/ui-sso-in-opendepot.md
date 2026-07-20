---
title: Introducing Registry Explorer and SSO via Dex in OpenDepot
description: Introducing the latest features to OpenDepot, which includes a new user interface called the Registry Explorer, OIDC integration with Dex, which allows SSO and fine-grained access to providers and modules, and revamped branding.
pubDate: 2026-07-19
tags:
  - OpenDepot
  - Kubernetes
  - OpenTofu
  - Terraform
  - Cloud Native
---

[View on GitHub](https://github.com/tonedefdev/opendepot)

It has been a couple of months since I last provided an update on here about OpenDepot. During that time, I have been working hard to bring new features and quality of life improvements to the project. One of the features I am most excited to share is the Registry Explorer, which is a user interface to view all the resources under management, download and usage stats, and a visual diagram about the relationship between Depots and the resources they manage.

> The shiny things are always the most fun to talk about!

Another game changing feature was the addition of Dex, an open-source OIDC identity broker, for SSO. Now, you can associate group claims in a user's JWT `(JSON Web Token)` with access controls for `Provider` and `Module` resources using the new `GroupBinding` resource. With this feature added, Kubernetes RBAC or API permissions are no longer solely required to fetch modules and providers. Regular users who may not need direct Kubernetes access can still fetch these types of resources without administrators worrying about how to lock down this boundary.

> Shout out to the [r/Terraform](https://reddit.com/r/Terraform) community for this feedback as it helped shape the future of this project!

These features are now out as part of the `v0.8.0` release, so let's dig into them!

## Registry Explorer

In the beginning, I had envisioned OpenDepot as a flexible solution that would allow Platform Engineers the ability to integrate the data points from OpenDepot into their own IDP `(Internal Developer Portal)` with little effort. However, in working with OpenDepot over the past six months, I realized there's tremendous value in providing out-of-the-box visualization of resources under its management. Not only does this make development easier, but it rounds out the offering so that teams who may not have the capacity to run their own IDP can still utilize similar features.

![Registry Explorer Dark Mode](../../img/registry_explorer_dark_collapsed.png)

> Each resource's visibility is scoped to the user's group claims returned by `Dex`, which we'll get into later.

From the landing page, you will find all modules and providers that are currently under management for this instance of OpenDepot. The cards will surface the namespace where the resource is stored, the sync status, the latest version, as well as any vulnerabilities discovered in the latest version's scan.

### Resource Details

Clicking on any card takes you to the version details page where you can drill down into specifics about the module or provider such as an overview, how to use the resource, storage configuration, GitHub configuration, versions table, and vulnerability scans table. 

If the resource is a `Module`, the backend controller will try to pull the README from either GitHub or the release archive. If discovered, OpenDepot will store the document in the cluster. A new status field for the `Version` resource was introduced that helps OpenDepot keep track of this new information. This ensures that when a specific `Version` is removed, the associated README is also garbage collected, ensuring no orphaned resources remain in the cluster.

![Registry Explorer Module Details](../../img/registry_explorer_module_details.png)
> When the README is rendered by Registry Explorer, any HTML, including `terraform-docs` specific HTML elements, is sanitized to ensure no arbitrary code could potentially be executed in the browser. Additionally, if the README contains examples where a `source = <SOME_SOURCE>` is provided, OpenDepot automatically replaces it with the server's correct `source` field so that users can copy/paste the author's examples without modification.

![Registry Explorer Module Details](../../img/registry_explorer_module_details_2.png)

### Vulnerability Scans
OpenDepot can optionally scan modules and providers for vulnerabilities using `trivy`, an open-source scanner. If there are any vulnerabilities detected, the Registry Explorer will display a table of all findings. The tables are split between source and binary scans. There are numerous filters and search capabilities so that you can find the information that's pivotal in helping you resolve issues.

![Source Scan Findings](../../img/source_scan_findings.png)

When `trivy` scans a provider, the binary itself is also scanned. Those findings are displayed under the Binary Scan Findings table.

![Binary Scan Findings](../../img/binary_scan_findings.png)

### Depot

The Depot page helps visualize the relationships between the Depot and its child resources like Modules and Providers. The page allows a user without direct cluster access to watch how their Depots are spinning up new module and provider resources.

![Depot View](../../img/depots.png)

### Statistics
The Statistics page provides a number of different data points about the resources under management. Users can use this page to view current storage usage, which types of storage are being used across the stack, download stats, sync health, and more. The `GroupBinding` resource defines which stats are displayed so that any user of OpenDepot is empowered to understand their impact on resource consumption.

![Statistics](../../img/statistics.png)

## Dex OIDC SSO
I had first shared this project with a small audience on [dev.to](https://dev.to) and [r/Terraform](https://reddit.com/r/Terraform) to help gain initial feedback. Ultimately, my goal is to make OpenDepot a solution that people in the community want to adopt, so listening to feedback is of great importance to me. One user provided a use-case that I was blind to because it had been a couple of years since I had managed Kubernetes in the way they had described.

### The Problem Statement
In environments where Kubernetes clusters are decentralized, it is a common pattern to have what's called a `Control Plane Cluster`. This type of cluster is used to manage or offer centralized services to dependent clusters. There are many tools out there that provide configurations that help with this style of cluster management. The moment they mentioned it, I immediately recognized the gap. In these scenarios, a system like OpenDepot would ideally be installed as part of the `Control Plane Cluster`. Since OpenDepot only supported Kubernetes RBAC, this meant that users would need to be given some level of access to the `Control Plane Cluster` simply to download modules and providers.

> Yea, that's not ideal. I wouldn't install this myself if my current architecture was set up like that! I admit -- I totally had blinders on, but this is why being open to feedback and criticism can lead to building something even better!

I quickly realized how to solve this since I had implemented many solutions that leveraged SSO to provide access to their systems. That's when I turned to the awesome [CNCF](https://www.cncf.io/projects/dex/) (Cloud Native Computing Foundation) project Dex.

[Dex](https://dexidp.io/) is an open-source identity broker that allows you to set up your IdP `(Identity Provider)` of choice like `Microsoft Entra ID`, `Ping`, `Okta`, `Keycloak`, or any other OIDC (OpenID Connect) supported provider to authenticate users and then issue OAuth2 tokens to access applications.

You can configure Dex to emit group claims, which are the primary attributes OpenDepot needed to authorize the resources users would be permitted to access. The additional benefit of adding SSO? Native authentication using either `tofu` or `terraform`. We'll touch base on that later though!

### The Solution
Integrating Dex alongside OpenDepot was the easy part. The difficult part was wiring everything together so that administrators had the flexibility they needed without making authorization a complicated burden.

I had previously implemented Argo Workflows, the amazing open-source workflow engine, and remembered how it had approached this same problem. They used [Expr](https://expr-lang.org/) expressions that were annotated on Kubernetes Service Accounts to decide whether a specific user was authorized. I decided to implement something similar. However, instead of using Service Account annotations, I approached it by creating a dedicated Custom Resource.

### The GroupBinding Resource
The `GroupBinding` resource allows administrators of OpenDepot to decide which modules and providers users can access. When the server enables `Dex` integration, the `GroupBinding` resources are evaluated in alphabetical order. The first `GroupBinding` resource that allows access to the module or provider being evaluated wins.

Here's an example of a `GroupBinding` resource that allows the `AWS Developers` group access to any module that the glob pattern `terraform-aws-*` matches. This group may only access the single `aws` provider:

```yaml
apiVersion: opendepot.defdev.io/v1alpha1
kind: GroupBinding
metadata:
  name: 02-developer-access
  namespace: opendepot-system
spec:
  expression: '"AWS Developers" in groups'
  moduleResources:
  - terraform-aws-*
  providerResources:
  - aws
```
> The `providerResources` does NOT support globbing except for a solo `*` to indicate *ALL* providers. Most providers have unique names and seldom share similar naming conventions that would make globbing useful.

Here's an example of a `GroupBinding` for administrators that gives access to all resources in OpenDepot:

```yaml
apiVersion: opendepot.defdev.io/v1alpha1
kind: GroupBinding
metadata:
  name: 01-admin-access
  namespace: opendepot-system
spec:
  expression: '"Cloud Administrators" in groups'
  moduleResources:
  - '*'
  providerResources:
  - '*'
```

The primary reason for not using Kubernetes RBAC resources like `Roles` or `ClusterRoles` is that the `resourceNames` field doesn't support extended pattern matching. With `Roles` and `ClusterRoles`, every module would need to be explicitly listed.

Imagine this!

```yaml
  rules:
  - apiGroups:
    - opendepot.defdev.io
    resources:
    - modules
    resourceNames:
    - terraform-aws-key-pair
    - terraform-aws-eks
    - terraform-aws-opensearch
    - terraform-aws-elasticache
    - terraform-aws-secretsmanager
    verbs:
    - get
```

By adding `glob` support to OpenDepot's `GroupBindings`, we've made it extremely easy to give access to a breadth of similarly named modules.

### The SSO Bonus
I wasn't necessarily trying to solve for it, but adding `Dex` to fix the `Control Plane Cluster` challenge came with a hidden gem: `tofu` and `terraform` could use native authentication to gain access to OpenDepot. Now, a team who has installed `Dex` and configured an IdP can have any user easily fetch an access token from OpenDepot by simply using the built-in `tofu login` command. This was made possible by adding the necessary `login.v1` metadata endpoints to the `.well-known/terraform.json` configuration in OpenDepot's server. 

To configure the client to access this endpoint, a user needs to add the following to their `.tofurc` or `.terraformrc` file:

```hcl
  "login.v1" = {
    client      = "opendepot"
    grant_types = ["authz_code"]
    authz       = "http://localhost:5556/dex/auth"
    token       = "http://localhost:5556/dex/token"
    scopes      = ["openid", "email", "profile", "groups", "offline_access"]
    ports       = [10000, 10010]
  }
```

Once the relevant configuration file has been added, a user only needs to run `tofu login <OPENDEPOT_SERVER_URL>` to handle the sign-in flow.

For example, if you use the project's `make ui-oidc-setup` command to install OpenDepot on a local [Kind](https://kind.sigs.k8s.io/) cluster, you can run the following command to authenticate with `Dex`:

```sh
tofu login opendepot.localtest.me:8080
```

This will initiate the authentication challenge to retrieve an access token scoped to the permissions provided by the `GroupBinding` resource:

```txt
OpenTofu will request an API token for opendepot.localtest.me:8080 using OAuth.

This will work only if you are able to use a web browser on this computer to
complete a login process. If not, you must obtain an API token by another
means and configure it in the CLI configuration manually.

If login is successful, OpenTofu will store the token in plain text in
the following file for use by subsequent commands:
    /Users/tonedefdev/.terraform.d/credentials.tfrc.json

Do you want to proceed?
  Only 'yes' will be accepted to confirm.

  Enter a value: yes

OpenTofu must now open a web browser to the login page for opendepot.localtest.me:8080.

If a browser does not open this automatically, open the following URL to proceed:
    http://localhost:5556/dex/auth?client_id=opendepot&code_challenge=rVCmnR2j-Mm80hjPZ7qR__a7PA7lk-bT0UzELyLec8k&code_challenge_method=S256&redirect_uri=http%3A%2F%2Flocalhost%3A10004%2Flogin&response_type=code&scope=openid+email+profile+groups+offline_access&state=5bd4b9f2-34e9-34a3-a64f-475b8f3197b5
```
> If you do not like the idea of storing access tokens in plain text on a filesystem, you can use my other project [Terracreds](https://github.com/tonedefdev/terracreds) to store these credentials in the operating system's credential vault, or in a cloud provider vault like AWS Secrets Manager or HashiCorp Vault.

Once successfully authenticated, you're ready to start fetching modules and providers from OpenDepot!

```txt
Success! OpenTofu has obtained and saved an API token.

The new API token will be used for any future OpenTofu command that must make
authenticated requests to opendepot.localtest.me:8080.
```

## Conclusion
This concludes the overview of the new features that have been added to OpenDepot since I last wrote about it two months ago. I'm excited to share these new additions, and I continue to look for valuable feedback from users and the community at large.

If you have any questions, comments, feedback, or new feature ideas, I'd love to hear from you! Please feel free to leave comments on this thread!

---

- [Registry Explorer Guide](https://tonedefdev.github.io/opendepot/guides/registry-explorer/) - A guide to walk through the architecture and specific configuration details for the Registry Explorer.
- [OIDC Authentication (Dex)](https://tonedefdev.github.io/opendepot/configuration/oidc/) - A detailed guide on how to configure Dex for use with OpenDepot.
- [Full Documentation](https://tonedefdev.github.io/opendepot/) - Everything you need to get set up, configured, and running your own registry.