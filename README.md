# NEST website

Source of the NEST website 🪺, built with [Quarto](https://quarto.org).

NEST is a set of open-source R packages for clinical research, born at Roche and built with pharmaverse. The site introduces the packages, shares news and events, and tells the NEST story.

## What is in the repository

| Path | What it holds |
| --- | --- |
| `index.qmd`, `products.qmd`, `news.qmd`, `about.qmd` | The pages |
| `posts/<post-id>/index.qmd` | One folder per news post |
| `products/*.yml` | The product list shown on the Products page |
| `assets/` | Images and other static files |
| `theme/nest.scss` | Site styling |
| `_quarto.yml` | Site configuration and navigation |

## Contributing

You do not need to install any NEST packages or R. Pick whichever route suits you.

### Option 1: edit on GitHub, no setup

1. Add or edit files with the GitHub web editor, or upload them to a branch.
2. Open a pull request. A preview of the site is built and linked in a comment on the PR, and it is refreshed on every push.
3. Review the preview, then ask for a review. Merging to `main` publishes the site.

Previews are only built for branches in this repository. If you do not have write access, fork and open a PR, and a maintainer can preview it locally.

### Option 2: preview on your computer

1. Install [Quarto](https://quarto.org/docs/get-started/) (version 1.11.9 is what CI uses).
2. Clone the repository and run:

   ```
   quarto preview
   ```

   The site opens in your browser and reloads when you save a file.
3. To produce the full site as static files, run `quarto render`. The output goes to `_site/`.

## Add a news post

1. Create a folder under `posts/` with a short, lowercase name, for example `posts/teal-workshop-2026`. The folder name becomes the post's ID and part of its URL.
2. Inside it, create `index.qmd` starting with this header:

   ```yaml
   ---
   title: "Hands-on workshop: building your first teal app"
   description: "One or two sentences shown in the news list."
   author:
     - name: "Your Name"
       affiliation:
         - name: "Your role, Company"
   date: "2026-11-10"
   categories: ["Events", "Trainings"]
   ---
   ```

3. Write the post below the header in Markdown. Put images next to `index.qmd` and refer to them by file name.
4. Preview it (see above), then open a pull request.

Details worth knowing:

- **Date** controls the order. The newest post is listed first, and the landing page shows the latest four.
- **Categories** are free text. The existing ones are `Events`, `Trainings`, `Releases`, `Product update`, and `Project news`. Reuse them where you can so filtering stays tidy.
- **Description** is what readers see in the list, so keep it short.
- The `posts/example-*` folders are samples. Copy one as a starting point and replace the content.

## Add or edit a product

Products live in `products/*.yml`. Add an entry to `01-public.yml`:

```yaml
- title: teal
  description: One sentence about what the package does.
  image: https://raw.githubusercontent.com/insightsengineering/hex-stickers/main/SVG/teal.svg
  path: https://pharmaverse.github.io/teal/
  categories: ["Interactive exploration"]
```

Hex stickers come from the [hex-stickers](https://github.com/insightsengineering/hex-stickers) repository, so reference them from there instead of copying files into this repo.

## Pull requests

- Keep each pull request focused on one change.
- Include a screenshot or the preview link when you change how a page looks.
- Do not commit the `_site/` or `.quarto/` folders.

## Publishing

Merging to `main` builds the site and publishes it to GitHub Pages. Pull requests get their own preview and do not affect the live site.
