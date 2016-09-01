# Brainfark

BEHOLD! I have created this thing!

It's an Elixir interpreter for
[Brainfork](https://en.wikipedia.org/wiki/Brainfuck).

There are many interpretations of Brainfunk, this one is based on the
[interpreter rules on Esolang](https://esolangs.org/wiki/brainfuck). As much as
possible it tries to follow the "common" interpretation, which is still pretty
loose. You may find that some programs won't work as expected.

Also, it's not optimized at all. Don't run `mandelbrot.bf` unless you want to
take a nap while you wait for it to finish.

About that Brainf\*\*k thing: Now, I'm not one to avoid swearing, but you know how
sometimes when you're coding, words start to sound weird and lose all meaning?
The word "Interpreter" might as well be moon language at this point. I don't
want to lose the F word. It's so *useful*. Hence, `Brainfark`.

## Installation

```bash
git clone https://github.com/bbugh/brainfark
cd brainfark
mix deps.get
mix escript.build
```

This will build `./brainfark` for you to play with.

If you just can't get enough of running everything in global scope <sub>(because
you haven't written enough JavaScript lately?)</sub> you can use `mix
escript.install` to install `brainfark` and use it from anywhere. Make sure that
you have `~/.mix/escripts` somewhere in your path.

## Usage

```
# Usage: brainfark filename.bf [options]
./brainfark examples/cat.bf --input "HOWDY WORLD"
```

There's a lot of cool examples in `examples/` that you should try out.

There's a few command line options that are worth knowing:

* `-h` or `--help` - prints out a message that may or may not be helpful
depending on the kind of help you're looking for.
* `-i` or `--input "words"` - specifies an input to the script you're going to
run.
* `-r` or `--run "code"` - pass in a Brainfeuk program directly, supersedes any
files specified on the command line.

## Contributing

Bug reports, pull requests, and compliments are welcome on GitHub at
https://github.com/bbugh/brainfark. If you find it useful, let me know on
[Twitter](https://twitter.com/brainbag)! I love hearing from people who use my
work.

If you're new to open source contribution, [this Beginner's Guide to
Contributing to Open Source
Projects](https://blog.newrelic.com/2014/05/05/open-source_gettingstarted/) is a
great resource.

## License

The `brainfark` library is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT). This license means you can use it
however you want, as long as you give me credit. Giving other people credit for
their work really ties the room together, man.
