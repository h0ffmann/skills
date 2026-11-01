//// Writes a plain HTML view of the skills: one index page and one page for
//// each skill. Run it from `www/` with `gleam run` (or `just site`).

import gleam/io
import gleam/list
import gleam/string

const skills_dir = "../skills"

const out_dir = "../docs/site"

@external(erlang, "www_ffi", "read")
fn read(path: String) -> Result(String, Nil)

@external(erlang, "www_ffi", "write")
fn write(path: String, text: String) -> Nil

@external(erlang, "www_ffi", "list_dir")
fn list_dir(path: String) -> List(String)

@external(erlang, "www_ffi", "is_dir")
fn is_dir(path: String) -> Bool

@external(erlang, "www_ffi", "make_dir")
fn make_dir(path: String) -> Nil

pub type Skill {
  Skill(
    category: String,
    name: String,
    description: String,
    manual: Bool,
    body: String,
  )
}

pub fn main() -> Nil {
  let skills = load_skills()
  make_dir(out_dir)
  write(out_dir <> "/index.html", index_page(skills))
  list.each(skills, fn(s) {
    write(out_dir <> "/" <> s.name <> ".html", skill_page(s))
  })
  io.println(
    "Wrote "
    <> string.inspect(list.length(skills) + 1)
    <> " pages to docs/site/",
  )
}

fn load_skills() -> List(Skill) {
  sorted_dirs(skills_dir)
  |> list.flat_map(fn(category) {
    sorted_dirs(skills_dir <> "/" <> category)
    |> list.filter_map(fn(name) {
      let path = skills_dir <> "/" <> category <> "/" <> name <> "/SKILL.md"
      case read(path) {
        Ok(text) -> Ok(parse(category, name, text))
        Error(_) -> Error(Nil)
      }
    })
  })
}

fn sorted_dirs(path: String) -> List(String) {
  list_dir(path)
  |> list.filter(fn(e) { is_dir(path <> "/" <> e) })
  |> list.sort(string.compare)
}

/// Splits the front matter from the body. A field can continue on an
/// indented line, as `scripts/check.py` reads it.
pub fn parse(category: String, name: String, text: String) -> Skill {
  let #(front, body) = case string.split_once(text, "---\n") {
    Ok(#("", rest)) ->
      case string.split_once(rest, "\n---\n") {
        Ok(parts) -> parts
        Error(_) -> #("", text)
      }
    _ -> #("", text)
  }
  let fields = fields(string.split(front, "\n"), [])
  Skill(
    category: category,
    name: name,
    description: field(fields, "description"),
    manual: field(fields, "disable-model-invocation") == "true",
    body: string.trim(body),
  )
}

fn fields(
  lines: List(String),
  acc: List(#(String, String)),
) -> List(#(String, String)) {
  case lines, acc {
    [], _ -> acc
    [line, ..rest], [#(key, value), ..done] ->
      case string.starts_with(line, " ") {
        True ->
          fields(rest, [#(key, value <> " " <> string.trim(line)), ..done])
        False -> fields(rest, new_field(line, acc))
      }
    [line, ..rest], [] -> fields(rest, new_field(line, acc))
  }
}

fn new_field(
  line: String,
  acc: List(#(String, String)),
) -> List(#(String, String)) {
  case string.split_once(line, ":") {
    Ok(#(key, value)) -> [#(key, string.trim(value)), ..acc]
    Error(_) -> acc
  }
}

fn field(fields: List(#(String, String)), key: String) -> String {
  case list.key_find(fields, key) {
    Ok(value) -> unquote(value)
    Error(_) -> ""
  }
}

fn unquote(value: String) -> String {
  case string.starts_with(value, "\"") && string.ends_with(value, "\"") {
    True ->
      value
      |> string.drop_start(1)
      |> string.drop_end(1)
      |> string.replace("\\\"", "\"")
    False -> value
  }
}

pub fn escape(text: String) -> String {
  text
  |> string.replace("&", "&amp;")
  |> string.replace("<", "&lt;")
  |> string.replace(">", "&gt;")
  |> string.replace("\"", "&quot;")
}

fn page(title: String, main: String) -> String {
  "<!doctype html>
<html lang=\"en\">
<head>
<meta charset=\"utf-8\">
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
<title>" <> escape(title) <> "</title>
<style>
body { max-width: 50rem; margin: 2rem auto; padding: 0 1rem; font: 1rem/1.5 system-ui, sans-serif; }
table { border-collapse: collapse; width: 100%; }
th, td { text-align: left; vertical-align: top; padding: 0.25rem 0.5rem; border-bottom: 1px solid #ccc; }
pre { overflow-x: auto; font-size: 0.85rem; background: #f4f4f4; padding: 1rem; }
@media (prefers-color-scheme: dark) {
  body { background: #111; color: #ddd; } a { color: #8bf; } pre { background: #222; }
}
</style>
</head>
<body>
" <> main <> "</body>
</html>
"
}

fn index_page(skills: List(Skill)) -> String {
  let sections =
    skills
    |> list.chunk(fn(s) { s.category })
    |> list.map(fn(group) {
      let assert [first, ..] = group
      "<h2>" <> escape(first.category) <> "</h2>
<table>
<tr><th>Skill</th><th>What it does</th></tr>
" <> string.concat(list.map(group, row)) <> "</table>
"
    })
  page("skills", "<h1>skills</h1>
<p>" <> string.inspect(list.length(skills)) <> " agent skills. A skill is one folder with a <code>SKILL.md</code> file.
A ⏸ skill runs only when you call it by name.</p>
" <> string.concat(sections))
}

fn row(s: Skill) -> String {
  "<tr><td><a href=\""
  <> s.name
  <> ".html\">"
  <> escape(s.name)
  <> "</a>"
  <> case s.manual {
    True -> " ⏸"
    False -> ""
  }
  <> "</td><td>"
  <> escape(s.description)
  <> "</td></tr>\n"
}

fn skill_page(s: Skill) -> String {
  page(
    s.name <> " · skills",
    "<p><a href=\"index.html\">skills</a> / " <> escape(s.category) <> "</p>
<h1>" <> escape(s.name) <> "</h1>
<p>" <> escape(s.description) <> "</p>
<pre>" <> escape(s.body) <> "</pre>
",
  )
}
