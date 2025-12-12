# Leak checking for Objective-C tests
<!-- Keywords: test, leak, objc -->

> Have you enabled vibecoding with `mulle-sde vibecoding on` ?

Run test with: 

``` bash
mulle-sde -DMULLE_TESTALLOCATOR=3 -DMULLE_OBJC_TRACE_LEAK=YES run <path>/<testname>.m
```
You will see a lot of Objective-C method calls interspersed with memory
allocation traces in the output and logs.

At the end will be the leak addresses. You will easily find the responsible
call in the vibecoding **stderr** log for this test:

``` bash
grep -B3 -A1 <leakaddress> <path>/<testname>.test.stderr | head -4
```

IMPORTANT: The leak addresses will change with each `mulle-sde run`, so do not
memorize them.


## Hints

If you do not notice any leaks anymore, maybe the test is just crashing
instead.
One leak can easily depend on another leak. Find the highest level object
leak first. E.g. UIView before CALayer, UIWindow before UIView, UIApplication
before UIWindow and so forth.

In mulle-objc there is always an implicit NSAutoreleasePool in every thread
even in the main thread. So there is no need for `@autoreleasepool` in the
`main()` function.

Also check out the **testing** HOWTO for **valgrind** information.

Do not assume Apple semantics. For example check, which kinds of @properties
are automatically cleared on `-finalize` and which not. Look for a HOWTO
explaining **memory** management.
