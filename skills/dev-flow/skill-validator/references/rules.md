# Rules for a skill

## Contents

- Loading
- Frontmatter
- Descriptions
- Body
- Anti-patterns
- Composition
- Client differences
- Security of a third-party skill

## Loading

An agent loads a skill in three steps.

| Step | What loads | When | Advised size |
|---|---|---|---|
| Discovery | `name` and `description` | Each session | About 100 tokens |
| Activation | The `SKILL.md` body | When a request matches | Under 5,000 tokens |
| Execution | A reference or the output of a script | When the body calls it | Keep it small |

A script can run without its source in the context.

## Frontmatter

- Do not use `<` or `>` in frontmatter, because a client can put the text in a system prompt.
- Invalid YAML can stop the load without an error message.
- Put a value with a colon and a space in quotes. A strict parser rejects it as a nested mapping,
  and a lenient parser accepts it.

## Descriptions

- Write one or two short sentences. The limit of 1,024 characters is a ceiling, not a target.
- Put the main use and the important terms first, because a client can cut a long description.
- Name the tasks, inputs and file types that users mention. Match the intent, not only keywords.
- Keep workflow steps in the body. Do not use vague claims, catchalls or lists of synonyms.

| Quality | Example |
|---|---|
| Bad | A helpful skill for documents |
| Good | Fill PDF form fields, extract form data and flatten completed PDFs. Use for fillable PDF forms |

## Body

- **Commands first.** Prefer a command with a short comment to a long paragraph.
- **Deterministic work goes in code.** If a variation is a bug, write a script. Use text only for
  work that needs judgment.
- **Match strictness to risk.**
  - Many approaches are valid: give loose guidance, and say why it matters.
  - A preferred pattern exists: give a template or pseudocode.
  - A wrong move is costly: give an exact script and a strict step list.
- **Validation loop.** State a verify, fix and verify again loop. Examples: a document gets a visual
  check, code gets tests and type checks, data gets a schema check.
- **Check the state first.** Do not assume that a tool is ready. Check it, then branch to the setup
  steps.
- **Load at the correct time.** Say when to read each file. Example: "For a non-200 status, read
  `references/api-errors.md`." Do not write "see references/ for details".
- **One level deep.** `SKILL.md` names each reference directly. A chain of references causes partial
  reads. A reference with more than 100 lines has a table of contents.
- **Output format.** Show a structured example if another tool or skill reads the output.
- **Defer to `--help`.** Show the common commands. The tool gives the rest.
- **Name the method.** Name an established method, such as TDD, so that a reader can verify it.
- **Durable context.** A skill can keep context for later sessions in repository files, such as ADRs
  or a decision log.

## Anti-patterns

| Do not | Do this |
|---|---|
| Teach what the model knows | Give only what the agent would get wrong without the text |
| Add human docs to the folder | Put the README, changelog and install guide outside the skill |
| Write "Then deploy it" | Write the command, and the signal of success |
| Bundle library code | Install the library, and pin its version |
| Write one skill for design, build, test and deploy | Write focused skills that compose |
| Write a skill that changes only the tone | Use a user preference or a system prompt |
| Ignore failure | For each fallible step, say how to see the failure and what to do |
| Write facts that a date makes false | Fetch the data with a script, or omit it |
| Use absolute paths | Use relative paths with forward slashes |

## Composition

- One skill has one concern.
- If skill A makes a file that skill B reads, state the form of the file.
- Use repository files, such as `AGENTS.md`, to coordinate skills without explicit handoffs.
- Join skills in a chain, such as align, spec, build, verify and refactor.

## Client differences

The folder and the `SKILL.md` format are portable. Some controls are not.

- `disable-model-invocation: true` is not in the specification. Claude Code and VS Code Copilot
  read it, and they then start the skill only on an explicit call.
- OpenAI Codex uses `agents/openai.yaml` in the skill folder for the same control:

  ```yaml
  policy:
    allow_implicit_invocation: false
  ```

- Do not assume that a client field works in all clients. Read the documents of each client, then
  test the skill in each runtime.

## Security of a third-party skill

Skills can run code, change the behaviour of an agent and leak data. Before you install one:

1. Read each file in the folder.
2. Audit `scripts/` for network calls, file access outside the expected scope and command execution.
3. Search the references for prompt injection, such as "ignore previous instructions".
4. Make sure that the name does not imitate a popular skill.
5. Run the skill in a sandbox first.
6. Pin a commit or a version. Do not use `latest`.
