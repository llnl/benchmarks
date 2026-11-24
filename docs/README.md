# Sphinx Documentation

This folder contains a skeleton that can be used to create Sphinx
documentation. Some relevant links are provided below.

- [How to build documentation](90_appendix/build_docs.rst)

Use `build_doc.py` rather than invoking `make html` directly from a clean
checkout. The build driver first runs the worker scripts in `wrk/` to regenerate
figures from checked-in Gnuplot and Matplotlib sources, then invokes Sphinx.

## CI/CD

These scripts have been successfully used to generate documentation hosted as
part of GitLab Pages. The GitLab CI/CD YAML excerpts that achieve this are
provided below for reference.

```yaml
pages:
  stage: deploy
  variables:
    GIT_STRATEGY: none
    WORKSPACE: ""
    PYTHONPATH: "${PYTHONPATH}"
  script:
    - module load anaconda3/2021.05
    - export PATH="/path/to/texlive:${PATH}"
    - pushd docs
    - ./build_doc.py --all
    - popd
    - cp -a docs/_build/html public
    - touch .nojekyll
    - touch public/.nojekyll
  artifacts:
    paths:
      - public
  tags:
    - relevantbuildsystem
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
```
