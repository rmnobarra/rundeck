terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "4.19.2"
    }
  }
}


provider "github" {
  owner = var.owner
  token = var.github_token
}

resource "github_repository" "gitops" {
  name        = "gitops"
  description = "Um repositório sobre gitops bem maneriro"
  visibility  = "public"
}

output "public_repository" {
  description = "Example repository JSON blob"
  value       = github_repository.gitops
}