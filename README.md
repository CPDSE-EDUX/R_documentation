# Basic R for Pharmacy

An interactive R function reference for pharmaceutical sciences, produced by the
**Center for Pharmaceutical Data Science Education (CPDSE)**.

🌐 **Website: <https://cpdse-edux.github.io/R_documentation/>**

The site explains basic R functions (`read_csv()`, `mutate()`, `round()`, and
more) with pharmacy-focused examples. Every example is runnable **directly in the
browser** — readers can edit the code and see the result without installing
anything, thanks to [webR](https://webr.r-wasm.org).

---

## For contributors: how to edit the content

You do **not** need to be a programmer to help. The content lives in plain text
files that you can edit right in your web browser. This guide assumes you have
never used GitHub or Git before.

### A few words on how this works

- The website is **generated automatically** from the text files in this
  repository. You edit a file, and the website updates itself a few minutes
  later — you never touch the website directly.
- Each page you see on the site corresponds to one `.qmd` file here. A `.qmd`
  file is just a text file that mixes normal writing with bits of R code.
- When you save a change (this is called a **commit**), a robot rebuilds the
  whole website and publishes it. You don't have to do anything to trigger it.

### Where the content lives

| Folder | What's in it |
|---|---|
| `functions/` | One page per R function (e.g. `round.qmd`, `mutate.qmd`) |
| `topics/` | Broader topic pages: getting started, data handling, statistics, visualization |
| `index.qmd` | The home page |
| `glossary.qmd`, `coding-conventions.qmd` | Standalone pages |
| `_quarto.yml` | Site settings and the navigation menus |
| `assets/` | Images and example data files |

If you just want to fix a typo or improve wording, you almost certainly want a
file in `functions/` or `topics/`.

### How to edit the content

**Almost all of the content lives in the `.qmd` files** (Quarto files) in this
repository — the pages under `functions/` and `topics/`, plus `index.qmd`,
`glossary.qmd`, and `coding-conventions.qmd`. A `.qmd` file is a plain-text file
that mixes ordinary writing with bits of R code. You do **not** edit the website
(the HTML) directly: when a change is pushed to the repository, the `.qmd` files
are automatically **rendered into HTML** and published to the live site.

You can edit the content in two ways.

**Option A — edit in your browser (no software to install)**

1. Go to the repository: <https://github.com/CPDSE-EDUX/R_documentation>
2. Open the `.qmd` file you want to change (e.g. click `functions`, then
   `round.qmd`).
3. Click the **pencil icon** (✏️ "Edit this file") near the top right.
4. Make your changes in the text box (see the formatting tips below).
5. Scroll down, write a short note describing your change (e.g. *"Fix typo in
   round example"*), and click the green **Commit changes** button.

**Option B — edit and preview locally (e.g. in RStudio)**

If you'd like to see exactly how your change looks *before* it goes online, you
can edit the files on your own computer and render a preview. RStudio opens
`.qmd` files directly and has a **Render** button that shows the page in a
preview pane. See [For developers: building the site locally](#for-developers-building-the-site-locally)
below for the setup and the `quarto preview` command, which live-reloads the
site in your browser as you type.

### Getting your changes online (commit, push, deploy)

Editing a file is not enough on its own — you have to **save it back to the
repository**. This is a two-step idea from Git:

1. **Commit** — record your change with a short message describing it.
2. **Push** — upload your commit to GitHub. (If you edit in the browser with
   Option A, committing already does this for you; the "push" only applies when
   you edit locally with Option B.)

Once your change reaches the `main` branch, the site **rebuilds and deploys
automatically**. This usually takes a few minutes. You can watch the progress
(and see whether it succeeded) on the Actions page:

**<https://github.com/CPDSE-EDUX/R_documentation/actions>**

A green checkmark means your change is live; a red ✗ means the build failed and
the previous version is still online.

### How the text is formatted

The files use **Markdown**, a simple way to format text with plain symbols:

```markdown
## A heading

Normal text. Make words **bold** or *italic*.

- A bullet point
- Another one

`some_code()` in the middle of a sentence uses single backticks.
```

R code comes in two kinds of block. A block labelled `webr-r` is **runnable** —
readers can run and edit it live in the browser:

````markdown
```{webr-r}
round(3.14159, 2)   # this will be runnable on the website
```
````

A block labelled plain `r` is **not runnable** — it's shown for reference only.
Use it for install commands, `library()` calls, or snippets you don't want
executed:

````markdown
```r
install.packages("tidyverse")   # shown, but not runnable on the site
```
````

The safest way to learn the format is to **copy the style of an existing page**.
Open `functions/round.qmd` alongside the page you're editing and mirror its
structure.

### Formatting reference

Beyond plain Markdown, the pages use a handful of standard building blocks.
Here are the ones you'll reach for most often.

#### Callout boxes

Callouts are the coloured, boxed notes used throughout the site. Five styles are
available, each with its own colour and icon:

| Syntax | Use it for |
|---|---|
| `::: {.callout-note}` | General information worth highlighting |
| `::: {.callout-tip}` | Advice, best practice, a rule of thumb |
| `::: {.callout-warning}` | Something the reader should be careful about |
| `::: {.callout-important}` | A key rule that must not be missed |
| `::: {.callout-caution}` | A milder "watch out" than warning |

Write a callout with three colons to open and three colons to close. The line
starting with `##` becomes its title (the title is optional):

```markdown
::: {.callout-tip}
## Rule of thumb
Store values at full precision and only round when printing.
:::
```

**Making a callout collapsed (folded away by default).** Add
`collapse="true"` so the box starts closed and the reader clicks the title to
expand it — handy for optional detail:

```markdown
::: {.callout-note collapse="true"}
## Why two different functions?
This extra explanation is hidden until the reader clicks to open it.
:::
```

Use `collapse="false"` to show a box that *can* be collapsed but starts open.

#### Collapsible cards (`<details>`)

For longer content the pages use plain HTML `<details>` blocks, which render as a
clickable heading that expands. Add the word `open` to the opening tag to have it
start expanded. The site styles three named variants:

- `topic-card` — the large expandable sections on topic pages
- `arg-item` — one function argument in the "Argument Overview" list
- `example-item` — one worked example in the "Examples" list

```html
<details class="topic-card" open>
<summary>Section heading shown on the clickable bar</summary>
<div class="topic-card-body">

Normal Markdown content goes here.

</div>
</details>
```

> 💡 Leave a **blank line** after the opening `<div ...>` and before the closing
> `</div>` — without it, the Markdown inside won't render.

#### Other reusable pieces

- **External source link** (the "Original Documentation ↗" button at the top of
  each function page):

  ```html
  <div class="source-links">
  <a class="source-link" href="https://rdrr.io/r/base/Round.html" target="_blank" rel="noopener">Original Documentation ↗</a>
  </div>
  ```

- **Tables** use standard Markdown pipes (`| col | col |`) — see any function
  page for examples.
- **Images** live in `assets/images/`. From a page inside `functions/` or
  `topics/`, link them with a `../` prefix: `![Alt text](../assets/images/file.png)`.

When in doubt, open an existing page that already has the element you want and
copy its exact structure.

### Adding a brand-new function page

1. Copy an existing file in `functions/` (e.g. `round.qmd`) and give it a new
   name like `mean.qmd`.
2. Edit the content for your new function.
3. Add it to the menus so people can find it: open `_quarto.yml` and add a line
   pointing to your new file under both the `navbar` **Functions** menu and the
   `sidebar`. Copy how `round.qmd` is listed there.

The same applies to a new **topic page** — put the file in the `topics/` folder
instead (e.g. copy `topics/data-handling.qmd`), and register it under the
`navbar` **Topics covered** menu in `_quarto.yml`.

### Will my change break the website?

Don't worry — a mistake won't take the live site down:

- If a file has an error that stops the site from building, the build simply
  fails (a red ✗ on the [Actions page](https://github.com/CPDSE-EDUX/R_documentation/actions))
  and the **old working version stays online** until the problem is fixed.
- Previewing locally first (Option B above) lets you catch most mistakes before
  they ever reach GitHub.

---

## For developers: building the site locally

If you want to preview changes on your own computer before pushing:

**Prerequisites:** [Quarto](https://quarto.org/docs/get-started/),
[R](https://www.r-project.org/) (4.4+), and the R packages `knitr`,
`rmarkdown`, `dplyr`, `ggplot2`, `readr`, `tibble`.

```bash
# Clone the repository
git clone https://github.com/CPDSE-EDUX/R_documentation.git
cd R_documentation

# Add the webR extension (first time only)
quarto add coatless/quarto-webr --no-prompt

# Live preview with auto-reload
quarto preview

# Or build the static site into _site/
quarto render
```

The rendered site is written to `_site/` (which is not committed to Git).

## Deployment

Deployment is fully automatic. Every push to the `main` branch triggers the
GitHub Actions workflow in [`.github/workflows/publish.yml`](.github/workflows/publish.yml),
which renders the Quarto project and publishes it to GitHub Pages at
<https://cpdse-edux.github.io/R_documentation/>. A build takes a few minutes;
you can watch its progress on the **Actions** tab of the repository.

## License & credits

Built with [Quarto](https://quarto.org) and [webR](https://webr.r-wasm.org) by
the [Center for Pharmaceutical Data Science Education](https://cpdse.dk).
