(lang dune 3.17)

(name ocaml_serialization_bench)

(generate_opam_files true)

(source
 (github glyh/ocaml-serialization-bench))

(authors "Yihang \"Corvo\" Liu<corvo@o1labs.org>")

(maintainers "Yihang \"Corvo\" Liu<corvo@o1labs.org>")

(license MIT)

(documentation https://url/to/documentation)

(package
 (name ocaml_serialization_bench)
 (synopsis "A benchmark for ocaml serialization formats")
 (description "A benchmark for ocaml serialization formats")
 (depends 
   (ocaml (= 4.14.0))
   (core (= v0.16.2))

   (bin_prot (= v0.16.0))
   (ppx_bin_prot (= v0.16.0))

   (capnp (= 3.6.0)))
 (tags
  (serialization benchmark)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
