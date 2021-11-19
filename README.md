# dlmopen namespacing example

We showcase here how to create a wrapper library that uses `dlmopen()` to load a subtree of dependencies within a new dynamic library namespace, allowing for loading of multiple versions of a library with the same SONAME and filename at the same time.
