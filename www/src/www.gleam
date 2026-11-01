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

const logo_svg = "../docs/drawings/waza.svg"

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
  let assert Ok(logo) = read(logo_svg)
  write(out_dir <> "/waza.svg", logo)
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
header { display: flex; flex-direction: column; align-items: center; gap: 0.5rem; padding: 1.5rem 0 1rem; border-bottom: 1px solid var(--line); text-align: center; }
header .logo img { display: block; width: 128px; height: 128px; }
header .repo { font-weight: bold; font-size: 1.2rem; text-decoration: none; color: var(--fg); }
header .actions { display: flex; flex-wrap: wrap; justify-content: center; align-items: flex-start; gap: 0.5rem; width: 100%; }
details.cite[open] { flex-basis: 100%; display: flex; flex-direction: column; align-items: center; }
header .orgs { font-size: 0.85rem; color: var(--muted); }
header .orgs a { color: var(--muted); }
.btn { display: inline-flex; align-items: center; gap: 0.35rem; padding: 0.2rem 0.7rem; border: 1px solid var(--line); border-radius: 0.4rem; background: var(--code); color: var(--fg); font-size: 0.85rem; text-decoration: none; cursor: pointer; list-style: none; }
.btn::-webkit-details-marker { display: none; }
.btn svg { fill: currentColor; }
.btn:hover { border-color: var(--muted); }
#stars:not(:empty) { padding-left: 0.4rem; border-left: 1px solid var(--line); }
.cite-box { margin-top: 0.5rem; text-align: left; width: 100%; }
.cite-box pre { white-space: pre-wrap; overflow-wrap: anywhere; margin: 0.25rem 0 0.75rem; }
.cite-box p { margin: 0; }
.cite-box button { font: inherit; font-size: 0.8rem; margin-left: 0.5rem; cursor: pointer; }
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

/// The citation. CITATION.cff at the repository root has the same data.
const cite_apa =
  "h0ffmann. (2026). skills [Computer software]. https://github.com/h0ffmann/skills"

const cite_bibtex =
  "@software{h0ffmann_skills_2026,
  author = {h0ffmann},
  title = {skills},
  year = {2026},
  url = {https://github.com/h0ffmann/skills},
  license = {MPL-2.0},
  note = {ORCID 0009-0009-1056-7661}
}"

/// Shows the star count from the GitHub API, if it answers, and copies a
/// citation. The page works without it.
const header_script =
  "<script>
(() => {
  fetch('https://api.github.com/repos/h0ffmann/skills')
    .then(r => r.ok ? r.json() : null)
    .then(d => { if (d && typeof d.stargazers_count === 'number') document.getElementById('stars').textContent = d.stargazers_count; })
    .catch(() => {});
  for (const b of document.querySelectorAll('button[data-copy]')) {
    b.addEventListener('click', () => {
      navigator.clipboard.writeText(document.getElementById(b.dataset.copy).textContent)
        .then(() => { b.textContent = 'Copied'; setTimeout(() => { b.textContent = 'Copy'; }, 1500); })
        .catch(() => {});
    });
  }
})();
</script>
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
<a class=\"logo\" href=\"index.html\"><img src=\"waza.svg\" width=\"128\" height=\"128\" alt=\"技 (waza, skill), the logo\"></a>
<a class=\"repo\" href=\"index.html\">h0ffmann/skills</a>
<div class=\"actions\">
<a class=\"btn\" href=\"" <> repo_url <> "\" title=\"Star h0ffmann/skills on GitHub\"><svg aria-hidden=\"true\" viewBox=\"0 0 16 16\" width=\"16\" height=\"16\"><path d=\"M8 0c4.42 0 8 3.58 8 8a8.013 8.013 0 0 1-5.45 7.59c-.4.08-.55-.17-.55-.38 0-.27.01-1.13.01-2.2 0-.75-.25-1.23-.54-1.48 1.78-.2 3.65-.88 3.65-3.95 0-.88-.31-1.59-.82-2.15.08-.2.36-1.02-.08-2.12 0 0-.67-.22-2.2.82-.64-.18-1.32-.27-2-.27-.68 0-1.36.09-2 .27-1.53-1.03-2.2-.82-2.2-.82-.44 1.1-.16 1.92-.08 2.12-.51.56-.82 1.28-.82 2.15 0 3.06 1.86 3.75 3.64 3.95-.23.2-.44.55-.51 1.07-.46.21-1.61.55-2.33-.66-.15-.24-.6-.83-1.23-.82-.67.01-.27.38.01.53.34.19.73.9.82 1.13.16.45.68 1.31 2.69.94 0 .67.01 1.3.01 1.49 0 .21-.15.45-.55.38A7.995 7.995 0 0 1 0 8c0-4.42 3.58-8 8-8Z\"/></svg> <svg aria-hidden=\"true\" viewBox=\"0 0 16 16\" width=\"16\" height=\"16\"><path d=\"M8 .25a.75.75 0 0 1 .673.418l1.882 3.815 4.21.612a.75.75 0 0 1 .416 1.279l-3.046 2.97.719 4.192a.751.751 0 0 1-1.088.791L8 12.347l-3.766 1.98a.75.75 0 0 1-1.088-.79l.72-4.194L.818 6.374a.75.75 0 0 1 .416-1.28l4.21-.611L7.327.668A.75.75 0 0 1 8 .25Zm0 2.445L6.615 5.5a.75.75 0 0 1-.564.41l-3.097.45 2.24 2.184a.75.75 0 0 1 .216.664l-.528 3.084 2.769-1.456a.75.75 0 0 1 .698 0l2.77 1.456-.53-3.084a.75.75 0 0 1 .216-.664l2.24-2.183-3.096-.45a.75.75 0 0 1-.564-.41L8 2.694Z\"/></svg> Star <span id=\"stars\"></span></a>
<details class=\"cite\"><summary class=\"btn\"><svg aria-hidden=\"true\" viewBox=\"0 0 16 16\" width=\"16\" height=\"16\"><path d=\"M1.75 2.5h10.5a.75.75 0 0 1 0 1.5H1.75a.75.75 0 0 1 0-1.5Zm4 5h8.5a.75.75 0 0 1 0 1.5h-8.5a.75.75 0 0 1 0-1.5Zm0 5h8.5a.75.75 0 0 1 0 1.5h-8.5a.75.75 0 0 1 0-1.5ZM2.5 7.75v6a.75.75 0 0 1-1.5 0v-6a.75.75 0 0 1 1.5 0Z\"/></svg> Cite</summary>
<div class=\"cite-box\">
<p><b>APA</b> <button type=\"button\" data-copy=\"apa\">Copy</button></p>
<pre id=\"apa\">" <> escape(cite_apa) <> "</pre>
<p><b>BibTeX</b> <button type=\"button\" data-copy=\"bibtex\">Copy</button></p>
<pre id=\"bibtex\">" <> escape(cite_bibtex) <> "</pre>
<p>Source: <a href=\"" <> repo_url <> "/blob/main/CITATION.cff\">CITATION.cff</a></p>
</div>
</details>
</div>
<nav class=\"orgs\"><a href=\"https://github.com/marola-dev\">marola-dev</a> · <a href=\"https://piabrota.art\">piabrota.art</a> · <a href=\"https://github.com/ouroboric-dev\">ouroboric-dev</a></nav>
</header>
" <> main <> "<footer>
<p>Built with Gleam on Erlang/OTP: plain HTML and CSS, and a small script for the search. GitHub Actions deploys it to GitHub Pages.</p>
<p>Content by <a href=\"https://github.com/h0ffmann\">h0ffmann</a>, MPL-2.0.</p>
</footer>
" <> header_script <> "</body>
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
