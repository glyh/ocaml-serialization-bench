# Building
## Clone the repo
```
git clone https://github.com/glyh/ocaml-serialization-bench
cd ocaml-serialization-bench
opam switch create . --deps-only --with-test -y 4.14.0
```
## Install development packages in case you need them
```
opam install --switch=. -y ocamlformat ocaml-lsp-server utop
```
