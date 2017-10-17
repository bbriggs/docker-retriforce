# docker-retriforce
An automated build of cetfor's [Retriforce setup](https://gist.github.com/cetfor/fd44955866f425bacdbe2ba5eff9028c) with a few extra opinionated extensions

## How to use this image

`docker run -d -it -v /path/to/your/target/bins:/tmp --name retriforce bbriggs/retriforce` to start the container and then

`docker exec retriforce bash` to get a shell inside and begin work.

## Things included from Retriforce
- [Capstone](http://www.capstone-engine.org/) (disassembling)
- [Keystone](http://www.keystone-engine.org/) (assembling)
- [Unicorn](https://github.com/unicorn-engine/unicorn) (CPU emulation)

## Things we added

- [Pwntools](https://github.com/Gallopsled/pwntools)
- [Pwngdb](https://github.com/scwuaptx/Pwngdb)
- [gef](https://raw.githubusercontent.com/hugsy/gef/master/gef.py)
- [Peda](https://github.com/longld/peda)

## GDB Error

When debugging with GDB, you'll probably run into the following error:

```
warning: Error disabling address space randomization: Operation not permitted
```

In order to get around that, use the `--privileged` flag during `docker run`.
