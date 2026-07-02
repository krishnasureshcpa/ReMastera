# Contributing Guidelines

Thank you for your interest in contributing to ReMastera. This document outlines the process for proposing changes, submitting code, and maintaining the quality standards of this repository.

## Design and Quality Principles

ReMastera adheres to strict product, engineering, and architectural rules. Please review these rules before opening a pull request:

1. Apple Native Design: All interface modifications must respect Apple Human Interface Guidelines. Utilize SwiftUI components and standard platform controls.
2. Privacy First: No network calls, telemetry collection, or remote analytical tracking are allowed in any part of this codebase.
3. Media Honesty: Do not introduce mock AI metrics or fake video enhancements.
4. Clean Coding Standards: Write modular, self-contained files. Avoid massive view declarations or monolithic controllers.

## Step-by-Step Contribution Process

Follow these steps to contribute code modifications:

1. Fork this repository and create a feature branch off the main branch.
2. Run the bootstrap setup script to verify dependencies:
   ```bash
   ./scripts/bootstrap.sh
   ```
3. Implement your changes. Ensure you write corresponding tests in the Tests directory.
4. Run the automated test suite to verify code correctness:
   ```bash
   ./scripts/test.sh
   ```
5. Ensure Swift formatting is aligned. Run swiftformat if configured.
6. Commit your changes with clear, descriptive commit messages.
7. Open a pull request against the main branch.

## Pull Request Guidelines

When submitting a pull request, please verify the following:

- The build compiles successfully using both Swift Package Manager and XcodeGen.
- All automated unit tests pass without errors.
- No emojis are used in code comments, commit messages, PR descriptions, or documentation.
- No contractions or em-dashes are used in user-facing documentation.
- The change is local-first and does not introduce remote dependencies or network calls.
