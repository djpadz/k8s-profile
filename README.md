k8s.sh: A set of Bash aliases and functions for Kubernetes
===

Installation
---

Add the following line to your .bash_profile:

```bash
source /path/to/k8s.sh
```

(Adjust the path to taste.)

What it does
---

This adds five commands to your `bash` session:

* `k` - An alias for `kubectl`
* `kcc` - Display, or set the current kubernetes context.  Also supports
  context selection from a menu.  Use `kc -h` for a usage message.
* `kaf` - Apply a set of YAML files, without having to specify `-f` before each
  one.  Handy for applying files via wildcards.<br/>
  Equivalent to `kubectl apply -f <file1.yaml> -f <file2.yaml> ...`
* `kdf` - Like `kaf`, except that it _deletes_ configurations.<br/>
  Equivalent to `kubectl delete -f <file1.yaml> -f <file2.yaml> ...`
* `kdaf` - Apply a set of configurations, but delete them (in reverse order)
  first.

As a bonus, `kcc` will also autocomplete, based on the available contexts.
