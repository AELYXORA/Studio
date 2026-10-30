# Linux x86-64 Native S0 Bootstrap

**Experimental Assembly lexical preflight, not a JSON parser or graph validator.** It only checks matching braces/brackets (outside strings), string termination and certain control characters; valid JSON grammar, escapes, UTF-8 validity, JSON duplicate keys, schema and Project Graph semantics are **not checked**. It can accept malformed JSON.

## Manual build

Requires Clang supporting GNU assembler Intel syntax and a Linux x86-64 host:

```sh
clang -nostdlib -no-pie -Wl,-e,_start -o json_preflight src/bootstrap/linux-x86_64/json_preflight.S
./json_preflight examples/architecture-sensor/project.auiproj.json
./json_preflight examples/architecture-sensor/component.auipkg.json
```

No libc and no Python needed. The executable uses direct Linux x86-64 syscalls and cannot run on Windows. No implicit platform portability claim.

## Local observations

A local Clang 17 Linux x86-64 build of the equivalent source succeeded. A small balanced-object fixture returned exit code 0; a mismatched-delimiter fixture returned exit code 1. These two checks establish only minimal smoke behavior, not JSON grammar or production safety. No CI.

## Next minimum engineering increment

Replace this scanner with a strict streaming tokenizer and parser with bounded memory, proper string escapes, UTF-8 validation, number grammar, duplicate-key policy, structured errors and actual JSON tree construction. Then implement typed graph validation and persistence. Retain current preflight only while it is useful as a measured bootstrap stage.
