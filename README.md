# leetload

Making this script to automatically set up my local environment when working on leetcode problems.Automate all the bootstrapping so that I can jump into writing code, testing, and debugging.

Currently only building this for my main language, typescript.

## Usage

Make sure you have these dependencies installed:
* `npm`
* `tsc`
* `jq`

To run leetload, download the `leetload.sh` script and run:

```bash
leetload.sh today # fetch today's problem. specifying problems not yet supported
```

It will prompt you for a directory under which it will create a new directory for the specified problem.
