# Basic R for Pharmacy

An interactive R function reference for pharmaceutical sciences, produced by the
**Center for Pharmaceutical Data Science Education (CPDSE)**.

🌐 **Live website: <https://cpdse-edux.github.io/R_documentation/>**

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

### Editing a page (the easy way — in your browser)

1. Go to the repository on GitHub:
   <https://github.com/CPDSE-EDUX/R_documentation>
2. Open the file you want to change. For example, click `functions`, then
   `round.qmd`.
3. Click the **pencil icon** (✏️ "Edit this file") near the top right.
   - The first time, GitHub may ask you to make your own copy (a "fork"). Click
     the green button to confirm — this is normal and safe.
4. Make your changes in the text box. See the formatting tips below.
5. Scroll down to the **"Commit changes"** box:
   - Write a short note describing what you changed (e.g. *"Fix typo in round
     example"*). This note is called a **commit message**.
   - Leave the option to create a **pull request** selected if it's offered.
6. Click the green **Commit changes** button.

A **pull request** is simply a request to add your changes to the main site. A
maintainer reviews it and clicks "merge." Once merged, the website rebuilds
automatically and your change goes live in a few minutes.

> 💡 If you have permission to edit the repository directly, your change may go
> live without a pull request. Either way, the steps above are the same.

### How the text is formatted

The files use **Markdown**, a simple way to format text with plain symbols:

```markdown
## A heading

Normal text. Make words **bold** or *italic*.

- A bullet point
- Another one

`some_code()` in the middle of a sentence uses single backticks.
```

R code that readers can run appears in a special block labelled `webr-r`:

````markdown
```{webr-r}
round(3.14159, 2)   # this will be runnable on the website
```
````

The safest way to learn the format is to **copy the style of an existing page**.
Open `functions/round.qmd` alongside the page you're editing and mirror its
structure.

### Adding a brand-new function page

1. Copy an existing file in `functions/` (e.g. `round.qmd`) and give it a new
   name like `mean.qmd`.
2. Edit the content for your new function.
3. Add it to the menus so people can find it: open `_quarto.yml` and add a line
   pointing to your new file under both the `navbar` **Functions** menu and the
   `sidebar`. Copy how `round.qmd` is listed there.

### Will my change break the website?

Don't worry — you can't break the live site by mistake:

- Changes are reviewed before they go live (via the pull request).
- If a file has a mistake that stops the site from building, the **old working
  version stays online** until the problem is fixed. Nothing goes down.

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
