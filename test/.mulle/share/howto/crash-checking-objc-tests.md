# Crash checking for Objective-C tests
<!-- Keywords: test, crash, objc -->

> Have you enabled vibecoding with `mulle-sde vibecoding on` ?

Run test with: 

``` bash
mulle-sde -DMULLE_TESTALLOCATOR=3 -DMULLE_OBJC_TRACE_ZOMBIE=YES run <path>/<testname>.m
```

You will see a lot of Objective-C method calls interspersed with memory
allocation traces in the output and logs.

When a zombie object gets message you will get an abort. This may already
be helpful enough, when you sift through the log file:

`<leakaddress> <path>/<testname>.test.stderr`

Read the GDB HOWTO how to get a stacktrace.

Also check out the **testing** HOWTO for `valgrind` information.
