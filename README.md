# crystal-diff

Crystal sequence differencing implementation.

Based on the algorithm proposed in ["An O(NP) Sequence Comparision Algorithm" (Wu, 1989)](https://publications.mpi-cbg.de/Wu_1990_6334.pdf)

[![Build Status](https://img.shields.io/travis/MakeNowJust/crystal-diff.svg?style=flat-square)](https://travis-ci.org/MakeNowJust/crystal-diff)
[![Document](https://img.shields.io/badge/docrystal-ref-866BA6.svg?style=flat-square)](http://docrystal.org/github.com/MakeNowJust/crystal-diff)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  diff:
    github: MakeNowJust/crystal-diff
```


## Usage

```crystal
require "diff"
require "colorize"

Diff.diff("hello world", "hello good-bye").each do |chunk|
  print chunk.data.colorize(
    chunk.append? ? :green :
    chunk.delete? ? :red   : :dark_gray)
end
```

![result](example/diff-char.png)


## Development

```console
$ crystal spec
```


## Contributing

1. Fork it ( https://github.com/MakeNowJust/crystal-diff/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request


## Contributors

- [MakeNowJust](https://github.com/MakeNowJust) TSUYUSATO Kitsune - creator, maintainer
