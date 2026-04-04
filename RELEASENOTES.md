### 0.21.3








* **BREAKING** Renamed the loader dependency interface from MulleObjCLoader(...) to MulleObjCDeps(...); consumers relying on the old symbol must update their references.
* Added NSDateComponents debugging helpers (description, mulleDebugContentsDescription) to improve introspection.
* Made NSDateComponents setter safer by adding a default case (abort only in DEBUG), preventing accidental aborts in non-debug builds.
