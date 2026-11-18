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

You do not need to install any NEST packages or R, unless your post runs R code (see [Show R output in a post](#show-r-output-in-a-post)). Pick whichever route suits you.

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

1. Create a folder under `posts/` named with the post's date and a short, lowercase title, for example `posts/2026-11-10-teal-workshop`. The date keeps folders in order and easy to find, and the whole name becomes the post's ID and part of its URL, so choose it carefully and keep it in step with the `date:` in the post.
2. Inside it, create `index.qmd` starting with this header:

   ```yaml
   ---
   title: "Hands-on workshop: building your first teal app"
   description: "One or two sentences shown in the news list."
   author:
     - name: "Your Name (Company)"
   date: "2026-11-10"
   categories: ["Events"]
   ---
   ```

3. Write the post below the header in Markdown. Put images next to `index.qmd` and refer to them by file name.
4. Preview it (see above), then open a pull request.

Details worth knowing:

- **Date** controls the order. The newest post is listed first, and the landing page shows the latest four.
- **Categories** show as tags on the News page and the landing page. Use one, and two at the most, so the list stays easy to scan. The existing ones are `Announcements`, `Events`, `Trainings`, and `Releases`. Reuse them where you can so filtering stays tidy.
- **Description** is what readers see in the list, so keep it short.
- Any existing post under `posts/` makes a good starting point. Copy its folder, rename it, and replace the content.

### Show R output in a post

By default, code in a post is shown in a plain code block (` ```r `) and is not run, so the site builds without R. If a post needs to show real results such as tables or plots:

1. Write the code as `{r}` chunks and add `freeze: true` to the post header.
2. Install R and the packages the code uses, then render the post once on your computer: `quarto render posts/<post-id>/index.qmd`. This runs the code and saves the results in the `_freeze/` folder.
3. Commit the new files in `_freeze/` together with the post, and include them in your pull request.

Render the post first with `quarto render`, then run `quarto preview` to check how it looks. Preview alone only renders a page when you open it, so it can leave `_freeze/` empty. Check that the post has a folder under `_freeze/` before you commit.

The build on GitHub has no R, so it reads the saved results from `_freeze/`. Without those files the build fails. If you change the code or text of such a post later, render it again and commit the updated `_freeze/` files.

## Add or edit a product

The Products page is drawn from `products/*.yml`. Each file is a list of sections, and each section is either a group of cards or a row of pill links. Cards group related packages into a family, with one link per package.

```yaml
- category: Interactive exploration
  description: Tools for interactive clinical data exploration and visualization.
  families:
    - title: teal
      description: One sentence about the family.
      image: https://raw.githubusercontent.com/insightsengineering/hex-stickers/main/SVG/teal.svg
      links:
        - { text: teal, url: "https://pharmaverse.github.io/teal/" }
        - { text: teal.modules.clinical, url: "https://insightsengineering.github.io/teal.modules.clinical/" }
```

- To add a package to an existing family, add one line under its `links`.
- To add a family, add a block under `families`. Keep each section to four cards so the grid stays even, and keep a card to about four links.
- To add a row of pills (for catalogs and examples), use `links:` directly under the section instead of `families:`.
- `image` is optional. A card without one gets a placeholder hexagon with its first letter. Hex stickers come from the [hex-stickers](https://github.com/insightsengineering/hex-stickers) repository, so reference them from there instead of copying files into this repo.
- Check that every link opens before you submit.

## Pull requests

- Keep each pull request focused on one change.
- Include a screenshot or the preview link when you change how a page looks.
- Do not commit the `_site/` or `.quarto/` folders. Do commit the `_freeze/` folder when a post runs R code.

## Publishing

Merging to `main` builds the site and publishes it to GitHub Pages. Pull requests get their own preview and do not affect the live site.
