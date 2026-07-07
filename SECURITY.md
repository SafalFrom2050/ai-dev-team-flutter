# Security Policy

## Supported Versions

This project is early-stage. Security fixes target the default branch,
currently `main`.

## Reporting A Vulnerability

Please do not open public issues for suspected vulnerabilities.

Preferred reporting path:

1. Use GitHub's private vulnerability reporting or Security Advisories feature
   if it is enabled for this repository.
2. If private reporting is not available, contact the maintainer through the
   repository owner's GitHub profile and share only the minimum safe details
   needed to establish contact.

Include:

- A short description of the issue.
- Affected files, dependencies, or workflows.
- Steps to reproduce, if safe.
- Potential impact.
- Suggested fix, if known.

## Scope

In scope:

- Repository code and workflows.
- Flutter app code under `work/`.
- Documentation or instructions that could cause unsafe handling of secrets,
  user data, or credentials.

Out of scope:

- Social engineering.
- Denial-of-service testing.
- Attacks against third-party services not controlled by this project.
- Reports that require publishing secrets or private data.

## Responsible Disclosure

Please give the maintainer reasonable time to investigate before public
disclosure.
