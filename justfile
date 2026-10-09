python := env_var_or_default("PYTHON", "python3")

default: check

check:
    {{python}} -m unittest discover -s scripts -p '*test.py'
    actionlint

build project version ref="":
    {{python}} scripts/release.py build '{{project}}' '{{version}}' {{if ref == "" { "" } else { "--ref '" + ref + "'" }}}

prepare project version:
    {{python}} scripts/release.py prepare '{{project}}' '{{version}}'

publish project version:
    {{python}} scripts/release.py publish '{{project}}' '{{version}}'

ci:
    gh workflow run test.yml --repo kristalalfred/homebrew-tap
