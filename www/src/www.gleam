//// Writes a plain HTML view of the skills: one index page, one page for each
//// skill and one page for `docs/awesome-skills.md`. Run it from `www/` with `gleam run` (or `just site`).

import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

const skills_dir = "../skills"

const out_dir = "../docs/site"

const awesome_md = "../docs/awesome-skills.md"

const tags_txt = "tags.txt"

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
    tags: List(String),
    body: String,
  )
}

pub fn main() -> Nil {
  let skills = add_tags(load_skills(), read_tags())
  make_dir(out_dir)
  write(out_dir <> "/index.html", index_page(skills))
  write(out_dir <> "/awesome-skills.html", awesome_page())
  let prevs = [Error(Nil), ..list.map(skills, Ok)]
  let nexts = list.append(list.drop(list.map(skills, Ok), 1), [Error(Nil)])
  list.zip(skills, list.zip(prevs, nexts))
  |> list.each(fn(item) {
    let #(s, #(prev, next)) = item
    write(out_dir <> "/" <> s.name <> ".html", skill_page(s, prev, next))
  })
  io.println(
    "Wrote "
    <> string.inspect(list.length(skills) + 2)
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

/// Reads `tags.txt`: one line `name: tag tag` for each skill.
fn read_tags() -> List(#(String, List(String))) {
  let assert Ok(text) = read(tags_txt)
  text
  |> string.split("\n")
  |> list.filter_map(fn(line) {
    case string.starts_with(line, "#") {
      True -> Error(Nil)
      False -> {
        use #(name, tags) <- result.try(string.split_once(line, ":"))
        Ok(#(string.trim(name), string.split(string.trim(tags), " ")))
      }
    }
  })
}

/// Gives each skill its category, its tags from `tags.txt` and `manual` for a
/// ⏸ skill. A skill with no line in `tags.txt` stops the build.
fn add_tags(
  skills: List(Skill),
  tags: List(#(String, List(String))),
) -> List(Skill) {
  list.map(skills, fn(s) {
    let listed = case list.key_find(tags, s.name) {
      Ok(t) -> t
      Error(_) -> panic as { "www/tags.txt has no line for " <> s.name }
    }
    let manual = case s.manual {
      True -> ["manual"]
      False -> []
    }
    Skill(..s, tags: list.unique(list.flatten([[s.category], listed, manual])))
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
    tags: [],
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

const repo_url = "https://github.com/h0ffmann/skills"

const style =
  "
:root { --fg: #111; --bg: #fff; --muted: #666; --line: #ccc; --code: #f4f4f4; --link: #05c; }
@media (prefers-color-scheme: dark) {
  :root { --fg: #ddd; --bg: #111; --muted: #999; --line: #444; --code: #222; --link: #8bf; }
}
body { max-width: 52rem; margin: 0 auto; padding: 0 1rem; font: 1rem/1.5 system-ui, sans-serif; color: var(--fg); background: var(--bg); }
a { color: var(--link); }
header { display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 0.5rem; padding: 1rem 0; border-bottom: 1px solid var(--line); }
header .repo { font-weight: bold; font-size: 1.2rem; text-decoration: none; color: var(--fg); }
header img { display: block; height: 20px; }
nav.crumbs { margin: 1rem 0 0; color: var(--muted); }
nav.pager { display: flex; justify-content: space-between; gap: 1rem; margin: 1.5rem 0; }
.scroll { overflow-x: auto; }
table { border-collapse: collapse; width: 100%; }
td { overflow-wrap: anywhere; }
th, td { text-align: left; vertical-align: top; padding: 0.25rem 0.5rem; border-bottom: 1px solid var(--line); }
pre { overflow-x: auto; font-size: 0.85rem; background: var(--code); padding: 1rem; }
.tag { display: inline-block; margin: 0 0.25rem 0.25rem 0; padding: 0 0.4rem; border: 1px solid var(--line); border-radius: 0.6rem; font-size: 0.85rem; text-decoration: none; }
.tag.on { background: var(--link); color: var(--bg); }
input[type=search] { width: 100%; box-sizing: border-box; padding: 0.4rem; font: inherit; }
footer { margin: 3rem 0 1rem; padding-top: 1rem; border-top: 1px solid var(--line); color: var(--muted); font-size: 0.9rem; }
"

fn page(title: String, main: String) -> String {
  "<!doctype html>
<html lang=\"en\">
<head>
<meta charset=\"utf-8\">
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
<title>" <> escape(title) <> "</title>
<style>" <> style <> "</style>
</head>
<body>
<header>
<a class=\"repo\" href=\"index.html\">h0ffmann/skills</a>
<a href=\"" <> repo_url <> "\" title=\"Star h0ffmann/skills on GitHub\"><img alt=\"★ Star on GitHub\" src=\"https://img.shields.io/github/stars/h0ffmann/skills?style=social\"></a>
</header>
" <> main <> "<footer>
<p>Built with Gleam on Erlang/OTP: plain HTML and CSS, and a small script for the search. GitHub Actions deploys it to GitHub Pages.</p>
<p><a href=\"https://github.com/h0ffmann\">h0ffmann</a> ·
<a href=\"https://piabrota.art\">piabrota.art</a> ·
<a href=\"https://github.com/ouroboric-dev\">ouroboric-dev</a> ·
<a href=\"https://github.com/marola-dev\">marola-dev</a></p>
</footer>
</body>
</html>
"
}

fn tag_link(tag: String) -> String {
  "<a class=\"tag\" href=\"index.html?tag="
  <> escape(tag)
  <> "\">"
  <> escape(tag)
  <> "</a>"
}

fn index_page(skills: List(Skill)) -> String {
  let groups = list.chunk(skills, fn(s) { s.category })
  let contents =
    list.map(groups, fn(group) {
      let assert [first, ..] = group
      "<a href=\"#"
      <> first.category
      <> "\">"
      <> escape(first.category)
      <> "</a> ("
      <> int.to_string(list.length(group))
      <> ")"
    })
  let tag_counts =
    skills
    |> list.flat_map(fn(s) { s.tags })
    |> list.sort(string.compare)
    |> list.chunk(fn(t) { t })
    |> list.map(fn(same) {
      let assert [tag, ..] = same
      "<a class=\"tag\" data-tag=\""
      <> escape(tag)
      <> "\" href=\"?tag="
      <> escape(tag)
      <> "\">"
      <> escape(tag)
      <> " "
      <> int.to_string(list.length(same))
      <> "</a>"
    })
  let sections =
    list.map(groups, fn(group) {
      let assert [first, ..] = group
      "<section id=\"" <> first.category <> "\">
<h2>" <> escape(first.category) <> "</h2>
<div class=\"scroll\"><table>
<tr><th>Skill</th><th>What it does</th><th>Tags</th></tr>
" <> string.concat(list.map(group, row)) <> "</table></div>
</section>
"
    })
  page("skills", "<h1>The skills</h1>
<p>" <> int.to_string(list.length(skills)) <> " agent skills. A skill is one folder with a <code>SKILL.md</code> file.
A ⏸ skill runs only when you call it by name (tag <code>manual</code>).
<a href=\"awesome-skills.html\">awesome-skills</a> lists other skill collections.</p>
<p><b>Categories:</b> " <> string.join(contents, " · ") <> "</p>
<p><input id=\"q\" type=\"search\" placeholder=\"Search by name, text or tag\" aria-label=\"Search the skills\"></p>
<p id=\"tags\">" <> string.join(tag_counts, "\n") <> "</p>
<p id=\"count\" aria-live=\"polite\"></p>
" <> string.concat(sections) <> search_script)
}

/// Filters the rows: each word of the search must occur in the name, the
/// text or the tags, and a selected tag must be one of the tags.
const search_script =
  "<script>
(() => {
  const q = document.getElementById('q');
  const count = document.getElementById('count');
  let tag = new URLSearchParams(location.search).get('tag') || '';
  const rows = [...document.querySelectorAll('tr[data-tags]')];
  function run() {
    const words = q.value.toLowerCase().split(/\\s+/).filter(Boolean);
    let shown = 0;
    for (const r of rows) {
      const tags = r.dataset.tags.split(' ');
      const text = r.textContent.toLowerCase();
      const ok = (!tag || tags.includes(tag)) && words.every(w => text.includes(w));
      r.hidden = !ok;
      if (ok) shown++;
    }
    for (const s of document.querySelectorAll('section')) {
      s.hidden = !s.querySelector('tr[data-tags]:not([hidden])');
    }
    for (const a of document.querySelectorAll('#tags .tag')) {
      a.classList.toggle('on', a.dataset.tag === tag);
    }
    count.textContent = (tag || words.length) ? shown + ' of ' + rows.length + ' skills' + (tag ? ' with tag ' + tag : '') : '';
  }
  for (const a of document.querySelectorAll('#tags .tag')) {
    a.addEventListener('click', e => {
      e.preventDefault();
      tag = tag === a.dataset.tag ? '' : a.dataset.tag;
      history.replaceState(null, '', tag ? '?tag=' + encodeURIComponent(tag) : location.pathname);
      run();
    });
  }
  q.addEventListener('input', run);
  run();
})();
</script>
"

fn row(s: Skill) -> String {
  "<tr data-tags=\""
  <> escape(string.join(s.tags, " "))
  <> "\"><td><a href=\""
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
  <> "</td><td>"
  <> string.concat(list.map(s.tags, tag_link))
  <> "</td></tr>\n"
}

fn skill_page(
  s: Skill,
  prev: Result(Skill, Nil),
  next: Result(Skill, Nil),
) -> String {
  let pager =
    "<nav class=\"pager\"><span>"
    <> case prev {
      Ok(p) ->
        "<a href=\"" <> p.name <> ".html\">← " <> escape(p.name) <> "</a>"
      Error(_) -> ""
    }
    <> "</span><span>"
    <> case next {
      Ok(n) ->
        "<a href=\"" <> n.name <> ".html\">" <> escape(n.name) <> " →</a>"
      Error(_) -> ""
    }
    <> "</span></nav>
"
  page(
    s.name <> " · skills",
    "<nav class=\"crumbs\"><a href=\"index.html\">skills</a> / <a href=\"index.html#"
      <> s.category
      <> "\">"
      <> escape(s.category)
      <> "</a> / "
      <> escape(s.name)
      <> "</nav>
<h1>"
      <> escape(s.name)
      <> case s.manual {
      True -> " ⏸"
      False -> ""
    }
      <> "</h1>
<p>"
      <> escape(s.description)
      <> "</p>
<p>"
      <> string.concat(list.map(s.tags, tag_link))
      <> "</p>
<p><a href=\"index.html#"
      <> s.category
      <> "\">← Back to all skills</a> · <a href=\""
      <> repo_url
      <> "/blob/main/skills/"
      <> s.category
      <> "/"
      <> s.name
      <> "/SKILL.md\">SKILL.md on GitHub</a></p>
<pre>"
      <> escape(s.body)
      <> "</pre>
"
      <> pager,
  )
}

/// Writes the table of `docs/awesome-skills.md` as HTML. A row is
/// `| n | [owner/repo](url) | stars | text |`.
fn awesome_page() -> String {
  let assert Ok(text) = read(awesome_md)
  let intro = case string.split_once(text, "\n\n") {
    Ok(#(_, rest)) ->
      case string.split_once(rest, "\n\n") {
        Ok(#(intro, _)) -> intro
        Error(_) -> ""
      }
    Error(_) -> ""
  }
  let rows =
    text
    |> string.split("\n")
    |> list.filter_map(awesome_row)
  page(
    "awesome-skills · skills",
    "<nav class=\"crumbs\"><a href=\"index.html\">skills</a> / awesome-skills</nav>
<h1>awesome-skills</h1>
<p>"
      <> escape(intro)
      <> "</p>
<div class=\"scroll\"><table>
<tr><th>#</th><th>Repository</th><th>Stars</th><th>What it is</th></tr>
"
      <> string.concat(rows)
      <> "</table></div>
<p><a href=\"index.html\">← Back to all skills</a></p>
",
  )
}

fn awesome_row(line: String) -> Result(String, Nil) {
  case string.split(line, " | ") {
    ["| " <> n, repo, stars, what] -> {
      use _ <- result.try(int.parse(n))
      use #(name, url) <- result.try(string.split_once(repo, "]("))
      let name = string.drop_start(name, 1)
      let url = string.drop_end(url, 1)
      let what = what |> string.drop_end(2) |> string.replace("`", "")
      Ok(
        "<tr><td>"
        <> n
        <> "</td><td><a href=\""
        <> escape(url)
        <> "\">"
        <> escape(name)
        <> "</a></td><td>"
        <> escape(stars)
        <> "</td><td>"
        <> escape(what)
        <> "</td></tr>\n",
      )
    }
    _ -> Error(Nil)
  }
}
