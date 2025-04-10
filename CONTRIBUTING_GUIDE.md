# Contributing to Ruby Pomodoro CLI

Thank you for considering contributing to Ruby Pomodoro CLI! This document outlines the process for contributing to this project and helps ensure a smooth collaboration experience.

## Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to [your-email@example.com].

## How Can I Contribute?

### Reporting Bugs

Bugs are tracked as GitHub issues. When you create a bug report, please include as many details as possible:

1. Use the bug report template provided.
2. Use a clear, descriptive title.
3. Describe the exact steps to reproduce the problem.
4. Include your environment details (OS, Ruby version, etc.).
5. Explain the behavior you observed and what you expected to see.
6. Include screenshots if applicable.

### Suggesting Features

Feature suggestions are also tracked as GitHub issues:

1. Use the feature request template provided.
2. Use a clear, descriptive title.
3. Provide a detailed description of the proposed feature.
4. Explain why this feature would be useful to most users.
5. List some possible implementation approaches if you have ideas.

### Pull Requests

Good pull requests are a fantastic help. They should remain focused in scope and avoid containing unrelated commits.

Please follow these steps for your contributions:

1. Fork the repository and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes (`bundle exec rake spec`).
5. Make sure your code follows the style guidelines (`bundle exec rake rubocop`).
6. Create a pull request using the provided template.

## Development Workflow

### Setting Up Development Environment

1. Fork and clone the repository
2. Run `bundle install` to install dependencies
3. Run `bundle exec rake chmod` to ensure scripts are executable
4. Run `bundle exec rake devsetup` to set up development symlinks

### Testing

We use RSpec for testing. Please ensure all your code is tested:

```bash
# Run the entire test suite
bundle exec rake spec

# Run specific tests
bundle exec rspec spec/lib/pomodoro_timer_spec.rb
```

### Style Guidelines

We follow the Ruby style guide and use Rubocop for style enforcement:

```bash
# Check code style
bundle exec rake rubocop

# Auto-correct certain issues
bundle exec rubocop -a
```

## Git Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Do not use contractions in commit messages
* Reference issues and pull requests liberally after the first line
* Consider starting the commit message with an applicable emoji:
  * ✨ `:sparkles:` when adding a new feature
  * 🐛 `:bug:` when fixing a bug
  * 📚 `:books:` when adding or updating documentation
  * ♻️ `:recycle:` when refactoring code
  * 🧪 `:test_tube:` when adding tests

## Documentation

* Keep README.md and other documentation up to date with changes
* Document all public methods, classes, and modules
* Include examples in documentation when possible

## Release Process

1. Update version number in `.version` file
2. Update CHANGELOG.md with changes since last release
3. Create a new GitHub release with a tag matching the version
4. Publish the release

## Questions?

Feel free to reach out if you have any questions about contributing. We appreciate your interest in improving Ruby Pomodoro CLI!
