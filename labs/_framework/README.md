# Lab framework

Each folder under `labs/` with a `lab.yaml` is one lab. A lab is a sequence of modules, each a self-contained guide with its own steps, checkpoint and troubleshooting. The framework validates structure, frontmatter and links, and generates `labs.json` for the site. The module format follows the [Build LAB520 lab](https://github.com/microsoft/Build26-LAB520-get-started-with-models-in-microsoft-foundry-to-build-ai-apps/tree/main/docs): objective, numbered steps, expected output, checkpoint, takeaway.

## Layout

```
labs/<NN>-<slug>/
  lab.yaml                  id (= folder), title, summary, accent, order, prefix
  README.md                 overview, module table with durations, requirements
  challenges/NN-slug.md     one module per file
  resources/                reference implementation, infra and sample apps
```

The `challenges/` folder name is historical; the content calls each file a module.

## Module format

Frontmatter: `title`, `summary`, `phase`, `group` (required), `tags`, `highlight`.

Body, in this order:

| Section | Rule |
|---|---|
| `# Module NN: Title` | Required; `NN` matches the file number |
| `> **Duration:** ~N minutes \| **Phase:** Name` | Required |
| `## Objective` | Required; the outcome in one to three sentences |
| `## Prerequisites` | Optional for early modules; list earlier modules and tools |
| `## Step N: Action` | One per action; show commands and `text` expected output |
| `## Checkpoint` | Required; `- [ ]` items you can verify with a command, output or screenshot |
| `## Reflect` | Optional; two or three questions to answer after the checkpoint |
| `## What You Learned` | Skills as things you can now do |
| `## Key Takeaway` | One blockquote sentence |
| `## Learn more` | Links |
| `## Troubleshooting` | Symptom and fix table |
| `**Next:** [Module NN](file.md)` | Last line, except for the final module |

Do not use the word "challenge" in content. Use `<details>` only for optional extras such as long reference output.

## Add a lab or module

1. Name the lab folder `NN-slug` (for example `06-my-lab`). Copy `_template/` to `labs/<lab-id>/` and edit `lab.yaml`. Or add `challenges/NN-slug.md` to an existing lab.
2. Name module files `NN-slug.md`: a two-digit number, then a kebab-case slug of the title (`03-containerize-and-deploy.md`). Numbers run `00..NN` with no gaps.
3. Run `labs/_framework/labs.py validate`.

## Commands

```
labs/_framework/labs.py validate        check structure, frontmatter, sections and links
labs/_framework/labs.py index -o FILE   write labs.json
```

`make test` runs `validate`.
