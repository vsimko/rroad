# Contributing

Interested in contributing to **rroad**? We'd love your help.
The package **rroad** is an open source project, built one
contribution at a time by users just like you.

## How to contribute
- Fork, clone, edit, commit, push, create pull request
- Use RStudio
- Unit-testing: press `CTRL+SHIFT+T` in RStudio

## Reporting bugs and other issues
If you encounter a clear bug, please file a minimal reproducible example on github [issue tracker].
If you have a suggestion for improvement or a new feature, create
a [pull request] so it can be discussed and reviewed by the
community and project committers. Even the project committers
submit their code this way.

## How to perform static code analysis and style checks
We use `lintr` which also performs the analysis on Travis-CI.
Configuration for `lintr` is in `.lintr` file.
Lints are treated as warnings, but we strive to be lint-free.

In RStudio, you can run lintr from the console as follows:
```r
> lintr::lint_package()
```

[issue tracker]: https://github.com/vsimko/rroad/issues
