# Security Policy

This document outlines the security posture of the ReMastera repository, the auditing guidelines we implement, and the process for reporting security vulnerabilities.

## Hardened Project Configurations

ReMastera implements strict security compile-time configurations to reduce runtime risks. The following build settings are enforced in the compiler configurations:

- Return Type Warnings: `GCC_WARN_ABOUT_RETURN_TYPE` is set to `YES_ERROR` to treat missing return values as compilation failures.
- Uninitialized Variables: `GCC_WARN_UNINITIALIZED_AUTOS` is configured to `YES_AGGRESSIVE` to catch uninitialized memory issues.
- Implicit Fallthroughs: `CLANG_WARN_IMPLICIT_FALLTHROUGH` is enabled to audit switch statement logic.
- Integer Conversions: `GCC_WARN_64_TO_32_BIT_CONVERSION` is set to `YES` to prevent buffer truncation bugs.
- Static Analyzer Hardening: Floating loop counters, insecure random generation, and unsafe string copies are evaluated by the static analyzer during the compilation phase.

## Reporting a Vulnerability

If you discover a security vulnerability in ReMastera, please do not open a public issue. Send your report directly to the repository maintainer. 

When submitting a report, please include:

- A detailed description of the vulnerability and its potential impact.
- Step-by-step instructions to reproduce the issue locally.
- Details of the environment (macOS version, Xcode version, dependency versions) on which the issue was discovered.
