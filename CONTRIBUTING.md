# Contributing to MSSQL IO

Thank you for your interest in contributing to MSSQL IO! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help create a welcoming environment for all contributors

## How to Contribute

### Reporting Bugs

When filing a bug report, please include:

1. **Description**: Clear description of the bug
2. **Steps to Reproduce**: Detailed steps to reproduce the issue
3. **Expected Behavior**: What you expected to happen
4. **Actual Behavior**: What actually happened
5. **Environment**:
   - Flutter version (`flutter --version`)
   - Plugin version
   - Platform (Windows/Android/iOS/macOS/Linux)
   - SQL Server version
   - FreeTDS version (if known)
6. **Code Sample**: Minimal reproducible code example
7. **Logs/Screenshots**: Any relevant error messages or screenshots

### Suggesting Features

Feature requests are welcome! Please include:

1. **Use Case**: Describe the problem you're trying to solve
2. **Proposed Solution**: How you envision the feature working
3. **Alternatives**: Other solutions you've considered
4. **Examples**: Code examples or mockups if applicable

### Pull Requests

#### Before You Start

1. **Search existing issues/PRs** to avoid duplicates
2. **Discuss significant changes** in an issue first
3. **Fork the repository** and create a feature branch

#### Development Setup

```bash
# Clone your fork
git clone https://github.com/your-username/mssql_io.git
cd mssql_io

# Install dependencies
flutter pub get

# Run tests
flutter test

# Run analyzer
dart analyze
```

#### Building Native Libraries

**Linux:**
```bash
cd src
mkdir build && cd build
cmake ..
make
```

**macOS:**
```bash
cd src
mkdir build && cd build
cmake ..
make
```

**Windows:**
```bash
cd src
mkdir build && cd build
cmake .. -G "Visual Studio 17 2022"
cmake --build . --config Release
```

#### Code Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Run `dart format .` before committing
- Ensure `dart analyze` passes with no errors
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and small

#### Testing Requirements

All contributions must include tests:

1. **Unit Tests**: For new functionality
   - Place in `test/` directory
   - Mock external dependencies
   - Aim for 90%+ coverage

2. **Integration Tests**: For database operations
   - Place in `example/integration_test/`
   - Test against real SQL Server
   - Clean up resources after tests

```bash
# Run unit tests
flutter test

# Run integration tests
cd example
flutter test integration_test/
```

#### Documentation

- Update README.md if adding user-facing features
- Add dartdoc comments to all public APIs
- Update CHANGELOG.md following [Keep a Changelog](https://keepachangelog.com/)
- Include code examples in doc comments

#### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements

Examples:
```
feat(connection): add auto-reconnect functionality

fix(queries): handle null values in binary columns

docs(readme): update installation instructions for macOS
```

#### Pull Request Process

1. **Create a feature branch**:
   ```bash
   git checkout -b feat/my-new-feature
   ```

2. **Make your changes**:
   - Write code
   - Add tests
   - Update documentation

3. **Verify everything works**:
   ```bash
   dart format .
   dart analyze
   flutter test
   ```

4. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat(scope): description"
   ```

5. **Push to your fork**:
   ```bash
   git push origin feat/my-new-feature
   ```

6. **Create Pull Request**:
   - Provide clear title and description
   - Reference related issues
   - Explain changes and motivation
   - Include screenshots if UI changes
   - Check all CI tests pass

#### PR Review Process

- Maintainers will review within 1-2 weeks
- Address feedback and requested changes
- Keep PR scope focused (split large PRs)
- Be patient and respectful

### Areas for Contribution

We especially welcome contributions in these areas:

1. **Platform Support**:
   - Improve Android native builds
   - Enhance iOS/macOS framework packaging
   - Windows DLL improvements

2. **Features**:
   - Connection pooling
   - Stored procedure support
   - Streaming large result sets
   - Query builder API

3. **Performance**:
   - Optimize bulk operations
   - Reduce memory footprint
   - Benchmark and profiling

4. **Testing**:
   - Increase test coverage
   - Add edge case tests
   - Performance benchmarks

5. **Documentation**:
   - More usage examples
   - Platform-specific guides
   - Video tutorials
   - Translations

6. **Native Code**:
   - Improve FreeTDS integration
   - Better error handling
   - Memory leak prevention

### Development Guidelines

#### Security

- Never commit credentials or secrets
- Use parameterized queries in examples
- Validate all user inputs
- Follow OWASP guidelines
- Report security issues privately to maintainers

#### Performance

- Profile code changes
- Avoid blocking operations on main thread
- Minimize native memory allocations
- Clean up resources properly

#### Compatibility

- Test on multiple platforms
- Maintain backwards compatibility
- Document breaking changes clearly
- Follow semantic versioning

## Getting Help

- **Questions**: Open a [GitHub Discussion](https://github.com/farhansadikgalib/mssql_io/discussions)
- **Bugs**: File an [issue](https://github.com/farhansadikgalib/mssql_io/issues)
- **Email**: farhansadikgalib@gmail.com

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Credited in commit messages

## Maintainer

**Farhan Sadik Galib**  
Sr. Mobile Apps Developer

- Website: [farhansadikgalib.com](https://farhansadikgalib.com/)
- GitHub: [@farhansadikgalib](https://github.com/farhansadikgalib)
- LinkedIn: [in/farhansadikgalib](https://www.linkedin.com/in/farhansadikgalib)

Thank you for contributing! 🎉

