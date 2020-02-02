# action python formatter
run formatter on all python files in a pull request.
If any lint errors occur, open a PR with their fixes

## inputs
### pr-base-branch
**required: false** the pull request base branch; default `master`

## outputs
### fileslist
a list of files that were formatted in the `pr-base-branch` given.

# example usage

```yaml
uses: jafow/action-python-format-pr
with:
    pr-base-branch: "packages"
```
# action-python-format-pr
