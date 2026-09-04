# Crash checking for Objective-C tests
<!-- Keywords: test, testing, crash, abort, objc, objective-c -->

> Have you enabled vibecoding with `mulle-sde vibecoding on` ?

## First try

Run test with: 

``` bash
mulle-sde -DMULLE_TESTALLOCATOR=3 -DMULLE_OBJC_TRACE_ZOMBIE=YES run <path>/<testname>.m
```

You will see a lot of Objective-C method calls interspersed with memory
allocation traces in the output and logs.

When a zombie object gets message you will get an abort. This may already
be helpful enough, when you sift through the log file:

`<leakaddress> <path>/<testname>.tmp.stderr`

Read the GDB HOWTO how to get a stacktrace.

Also check out the **testing** HOWTO for `valgrind` information.


## Finding wrong -autorelease calls

This will only work `reliably` in single threaded situations, but you can give
it a try in multi-thread situations anyway, though results are not reliable
there.


``` bash
mulle-sde -DMULLE_OBJC_SINGLE_THREAD_AUTORELEASE_CHECKER_ENABLED=YES run crasher.m
```

For example this line of code:

``` c
item = [[cd createInstanceWithEditingContext:ec globalID:nil zone:NULL] autorelease];
```

will then raise an exception `uncaught exception: NSInternalInconsistencyException: object ... would be autoreleased too often`
on this line, due to the erroneous extra -autorelease call.


## Tracing -retain/-release/-autorelease problems

``` bash
mulle-sde -DMULLE_OBJC_TRACE_BORING_METHOD_CALL=YES \
          -DMULLE_OBJC_TRACE_AUTORELEASEPOOL=YES \
          run crasher.m
```


## Examining zombie contents

Usually the zombification of an object will result in its contents being
shredded to induce crashes on access attempts. If you want to deduce the
object involved by the contents (say strings f.e.) you can set
`MULLE_OBJC_PRESERVE_ZOMBIE` to sidestep shredding.





