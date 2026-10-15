### 0.21.6



* document that date decomposition adds the timezone's GMT offset to the UTC reference interval, while composition subtracts it again
* replace the single MulleObjCOSFoundation requirement with MulleObjCOSBaseFoundation plus the Posix, BSD, Darwin, Linux and Windows foundation layers




* `-components:fromDate:` now applies the timezone offset in the correct direction, returning local wall-clock components instead of a shifted time
* `-dateFromComponents:` now converts local wall-clock components back to the correct UTC instant
* added a zone offset regression test covering the round-trip

### 0.21.5




* all source files now carry the BSD-3-Clause license header
* API summary documentation reorganized under asset/dox/api

### 0.21.4

Various small improvements
