# Vault Management CI/CD Workflow


Vault is an open source secrets management solution, more information can be found here <Link to Vaultproject.io>

This repository is inspired by this blog post ["Codifying Vault Policies and Configuration"][post], where Seth Vargo suggests an approach for codifying Vault resources. Our aim for this repository is to take his idea one step further and provide an example implementation of how Vault configuration can be managed as part of a CI/CD workflow by members of a security team. 

This repository uses curl to communicate with Vault, and CircleCI as the suggested CI/CD tool, however it can easily be adapted to one of the other supported API Libraries <link here> or other CI/CD providers.

## Assumptions
- You have a Vault server running and unsealed
- You have a Postgres database running
- There are firewall rules in place to allow Circle CI to communicate with Vault and Postgres
- This reference is meant as an example. In a production setting you should restrict access to Vault and to your DB by running the CI/CD from your hosted infrastructure.

## About environment variables
- Set sensitive information as env vars
- Assumes they will be set in CircleCI
- For local development, update and rename env.local.example as env.local

## Workflow

       +-----------+     +-----------+
       |           |     |           |
       | Provision |     |   Test    |
  +--> |           +---> |           +----+
  |    |           |     |           |    |
  |    +-----------+     +-----------+    |
  |                                       |
  |          +--------------+             |
  |          |              |             |
  |          |   Update     |             |
  +----------+   Vault      | <-----------+
             |   Resources  |
             |              |
             +--------------+


## Provision
- Follows Vault path hierarchy
- Check API docs for instructions on adding new paths <Link here>

## Test
- Validates provisioning has been successful by querying rest API
- 1-to-1 relationship with provisioning resources for complete code coverage
- Serves as documentation and validation
- Idempotent (can be executed multiple times without impacting already existing resources)

## Update Vault Resources
Working with different teams:
- Create secret paths, associated policies and tie these to users
- Distribute the user credentials, teams are responsible for seeding Vault and managing their secrets


[post]: https://www.hashicorp.com/blog/codifying-vault-policies-and-configuration.html
