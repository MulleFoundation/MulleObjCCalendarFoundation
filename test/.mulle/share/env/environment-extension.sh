#
# For more aggressive leak testing, it is good if singletons cleanup
# in the NSAutoreleasePool. These ephemerals aren't thread safe singletons.
#
export MULLE_OBJC_EPHEMERAL_SINGLETON="YES"


