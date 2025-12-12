# Testing Howto for mulle-sde
<!-- Keywords: test, run -->

Enable vibecoding, this will get you persistent stdout and stderr logs as `*.test.*`.
Always use `mulle-sde test run` it sets up proper environment, never use
`mulle-test` directly. Always include `.m` or `.c` extension when running a
single test, mulle-sde needs the source file.Check `.test.stdout|stderr` files
for actual output. Exit status 0 = PASS!

## Test Result Files

- `.test.stdout` - actual test output
- `.test.stderr` - runtime errors
- `.test.ccerr` - compiler warnings/errors
- `.exe` - compiled executable (don't run directly)


## DO THIS - Proper Testing Commands

### Enable vibecoding

```
mulle-sde vibecoding
```

### Learn how tests work

```bash
# See all auxiliary file options (including .CFLAGS):
mulle-sde test run --help
```

### Run all tests

```bash
mulle-sde test run
```

### Run a specific test
```bash
mulle-sde test run path/to/filename.extension
```

### Check test output
```bash
# Output is in .test.stdout file and stderr
cat path/to/filename.test.stdout
cat path/to/filename.test.stderr
```

### Build and test cycle

With vibecoding enabled, just run the test, mulle-sde test will rebuild:
```bash
mulle-sde test run path/to/filename.extension
```

## DON'T DO THIS - Wrong Approaches

### ❌ Never run mulle-test directly
**Problem**: Missing environment variables, wrong paths, confusing errors you can't figure out

### ❌ Do not run executables directly
**Problem**: There is a huge danger of running stale tests, which give old results. This invariably leads to bad mental state and subsequent catastrophic decisions.

### ❌ Never run a single test without the proper file extension
```bash
# WRONG - mulle-sde needs the source file
mulle-sde test run test-compiler-runtime/cache/preload-all-methods
```

