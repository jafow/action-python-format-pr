# action python formatter
run formatter on all python files in a pull request.
If any lint errors occur, open a PR with their fixes

## inputs
### target-file-path
**required** a path to the files to format. Probably the repo root.

## outputs
### fileslist
a list of files that were formatted in the `target-file-path` given.

# example usage

```yaml
uses: jafow/action-python-format-pr
with:
    target-file-path: "packages"
```
