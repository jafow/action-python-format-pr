# action-python-format-pr
Run a code formatter on all python files in a pull request.
If any formatting errors occur, the action opens a new pull request containing any fixes.

## inputs
### pr-base-branch
**required: false**
the pull request base branch; defaults to the base branch the PR is opened against.

## outputs
### fileslist
a list of files that were formatted in the `pr-base-branch` given.

# example usage

```yaml
format:
  runs-on: ubuntu-latest
  name: format .py files
  steps:
    # first checkout the code
    - name: Checkout pr
      uses: actions/checkout@v2
      with:
        ref: ${{ github.event.pull_request.head.sha }}
    # next run this action to format any modified python files  in the PR
    - name: format the python files
      id: format
      uses: jafow/action-python-format-pr@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        pr-base-branch: ${{ github.event.pull_request.base.sha }}
    # Optional: Use the output from the `format` step to echo out all the
    # formatted files
    - name: Get the list of files to be changed
      run: echo "The time was ${{ steps.format.outputs.fileslist }}"
```

# License
Apache 2.0
