# AI Adlib Data Analysis

R-based exploratory analysis of classic adlibs and AI-generated adlib prompts and results. The repository includes CSV exports, a SQLite database, an analysis notebook, two Shiny dashboards, and saved reports and visualizations.

## Repository contents

| Path | Contents and purpose |
| --- | --- |
| `Madlib.Rmd` | Main analysis: data summaries, prompt/result word frequencies, word clouds, bigrams, sentiment and emotions, TF-IDF, correlations, outliers, PCA, k-means clustering, and LDA topic modeling. Exports charts to `viz/`. |
| `Madlib.html`, `Madlib.nb.html` | Saved HTML report and notebook output for browsing the analysis without running R. |
| `Madlib-Dashboard.Rmd` | Shiny text-mining dashboard with source filters, overview statistics, word analysis, sentiment, length analysis, and a data explorer with CSV download. Reads three CSV files. |
| `Madlib-Dashboard.nb.html` | Saved notebook output; use the R Markdown source for a live dashboard. |
| `adlibs_dashboard/app.R` | Separate SQLite-backed Shiny app showing record totals, results over time, categories, tones, feature toggles, and an adlib browser filtered by flags and tone. |
| `adlibs.db` | Included SQLite database used by `adlibs_dashboard/app.R`. |
| `*.csv` | Nine source-data exports, described below. |
| `viz/` | Exported PNG charts, interactive HTML widgets, and accompanying `*_files/` assets. |

## View the saved results

Download or clone the repository, then open `Madlib.html` in a web browser. Individual HTML visualizations in `viz/` can also be opened locally; keep their accompanying asset directories with them. No R installation is needed to view these saved outputs. GitHub file links display the HTML source rather than running the interactive page.

The live dashboards require R; opening a saved notebook HTML file does not start a Shiny server.

## Run the SQLite dashboard

Use R 4.1 or newer (the app uses the native `|>` pipe), preferably through RStudio. Run the following in an R console with the repository root as the working directory:

```r
install.packages(c(
  "shiny", "bslib", "bsicons", "DBI", "RSQLite", "dplyr", "ggplot2", "DT"
))
```

Edit the hard-coded `db_path` in `adlibs_dashboard/app.R` to point to the included database. For the launch command below, use:

```r
db_path <- "../adlibs.db"
```

Shiny runs the app with `adlibs_dashboard/` as its working directory, so this path resolves to the database in the repository root. An absolute path to your copy of `adlibs.db` also works.

From the repository root, launch:

```r
shiny::runApp("adlibs_dashboard")
```

Use the Overview, Categories, Tones, and Browse Adlibs tabs to explore the database. Stop the app with the R console's Stop button or Escape/Ctrl+C, depending on your environment. The app reads the existing database; it does not import the CSV files.

## Run the text-mining dashboard

Install its dependencies in R:

```r
install.packages(c(
  "rmarkdown", "knitr", "shiny", "shinydashboard", "tidyverse", "tidytext",
  "wordcloud", "RColorBrewer", "plotly", "DT", "textdata", "readr", "janitor"
))
```

R Markdown also requires Pandoc, which is bundled with RStudio. Replace the `DATA_PATHS` block in `Madlib-Dashboard.Rmd` with paths to your checkout. When running from the repository root, use:

```r
DATA_PATHS <- list(
  adlibs = "adlib_rows.csv",
  ai_adlibs = "ai_adlibs_adlibs_rows (1).csv",
  results = "ai_adlibs_adlib_results_rows.csv"
)
```

Launch the document from the repository root:

```r
rmarkdown::run("Madlib-Dashboard.Rmd")
```

Alternatively, open the file in RStudio and select **Run Document**. Use the dashboard's source and minimum-frequency controls to explore the text, and the data explorer to download filtered data.

## Reproduce the analysis and visualization exports

Install the packages used by `Madlib.Rmd`:

```r
install.packages(c(
  "rmarkdown", "knitr", "tidyverse", "janitor", "gridExtra", "skimr",
  "tidytext", "plotly", "DT", "highcharter", "wordcloud2", "corrr",
  "igraph", "ggraph", "widyr", "networkD3", "textdata", "corrplot",
  "irlba", "topicmodels", "wordcloud", "RColorBrewer", "htmlwidgets"
))
```

In `Madlib.Rmd`, replace the hard-coded Downloads directory with:

```r
data_dir <- "./"
```

Keep the trailing slash: the loader concatenates this value with each CSV filename. Keep all nine CSVs at the repository root, including the exact filename `ai_adlibs_adlibs_rows (1).csv`.

Before running either text-analysis workflow for the first time, load the sentiment lexicons interactively so any download prompts can be handled:

```r
tidytext::get_sentiments("bing")
tidytext::get_sentiments("nrc")
```

Uncached lexicons may require internet access and acceptance of their download terms. Then, from the repository root, render the analysis:

```r
rmarkdown::render("Madlib.Rmd", output_format = "html_document")
```

You can also run the chunks in order in RStudio. Rendering executes the analysis, writes `Madlib.html`, and regenerates the HTML and PNG exports in `viz/`, overwriting existing outputs with the same names. Pandoc is needed for the HTML report and self-contained widget exports.

The main notebook joins AI adlibs to generated results using `id` and `adlib_id`, removes missing/empty prompt-result pairs, and retains results between 50 and 10,000 characters. Its text-analysis counts therefore describe a filtered subset rather than all database records.

## Data files

| CSV export | Contents |
| --- | --- |
| `adlib_rows.csv` | Classic adlibs: titles, prompts, text, flags, generation settings, and timestamps. |
| `category_rows.csv` | Classic category IDs and names. |
| `adlib_categories_category_rows.csv` | Classic adlib-to-category links (`adlibId`, `categoryId`). |
| `ai_adlibs_adlibs_rows (1).csv` | AI adlibs: prompts, text, flags, generation settings, tone IDs, and timestamps. |
| `ai_adlibs_adlib_results_rows.csv` | Generated result text linked to adlibs by `adlib_id`. |
| `ai_adlibs_adlib_categories_rows.csv` | AI adlib-to-category links. |
| `ai_adlibs_categories_rows.csv` | AI category IDs, names, and timestamps. |
| `ai_adlibs_adlib_tones_rows.csv` | Tone styles, prompts, characters, availability, and levels. |
| `ai_adlibs_feature_toggles_rows.csv` | Feature names, categories, and enabled flags. |

The SQLite app queries `adlibs`, `ai_adlibs`, `adlib_results`, `ai_categories`, `ai_adlib_cats`, `adlib_tones`, and `feature_toggles`. There is no CSV-to-SQLite import script in this repository; changing a CSV does not update the database.

## Reproducibility notes

The source files currently contain author-specific Windows paths; make the edits above before running them. No package lockfile or automated test suite is included, so package versions are not pinned. The committed HTML files provide saved results if you only want to explore the analysis without setting up its R dependencies.

## Highlights

- Compare vocabulary, phrase patterns, and response lengths across human and AI adlibs.
- Explore sentiment and NRC emotion distributions.
- Analyze TF-IDF terms, principal components, clusters, and LDA topics.
- Browse exported static and interactive visualizations.
- Run a Shiny dashboard backed by the included SQLite database.

## Repository Structure

```text
.
├── data/                    # CSV exports and SQLite database
├── adlibs_dashboard/        # Standalone Shiny application
├── reports/                 # Rendered R Markdown reports
├── viz/                     # Exported charts and HTML widgets
├── Madlib.Rmd               # Main exploratory analysis
├── Madlib-Dashboard.Rmd     # Interactive notebook dashboard
└── README.md
```

Generated HTML widget dependency folders are stored alongside their corresponding files in `viz/`.

## Getting Started

### Prerequisites

Install [R](https://www.r-project.org/) and an R Markdown-capable editor such as [RStudio](https://posit.co/download/rstudio-desktop/). The analysis uses packages from the tidyverse and text-analysis ecosystem, including `tidyverse`, `tidytext`, `plotly`, `DT`, `textdata`, `topicmodels`, and `wordcloud2`.

The standalone Shiny app requires `shiny`, `bslib`, `DBI`, `RSQLite`, `dplyr`, `ggplot2`, and `DT`.

### Run the Analysis

Open `Madlib.Rmd` in RStudio and select **Knit**, or run:

```r
rmarkdown::render("Madlib.Rmd", output_dir = "reports")
```

The notebook reads repository-relative files from `data/` and exports visualizations to `viz/`.

### Run the Dashboard

From the repository root, run:

```r
shiny::runApp("adlibs_dashboard")
```

The app reads `data/adlibs.db`; no machine-specific path configuration is required.

## Visualization Gallery

### Static Visualizations

| Analysis | Preview |
| --- | --- |
| Unique word usage | ![Unique words comparison](viz/unique_words.png) |
| Bigram comparison | ![Bigram comparison](viz/bigrams.png) |
| NRC emotion distribution | ![NRC emotions](viz/nrc_emotions.png) |
| Correlation matrix | ![Correlation matrix](viz/correlation_matrix.png) |
| Outlier boxplots | ![Outlier boxplots](viz/boxplots.png) |
| Top TF-IDF words | ![Top TF-IDF words](viz/tfidf_top_words.png) |

### Interactive Visualizations

- [Prompt Word Cloud](viz/prompt_wordcloud.html)
- [Result Word Cloud](viz/result_wordcloud.html)
- [Top Prompt Words](viz/top_prompt_words.html)
- [Top Result Words](viz/top_result_words.html)
- [Length Distributions](viz/length_distributions.html)
- [Sentiment Comparison](viz/sentiment_comparison.html)
- [TF-IDF Heatmap](viz/tfidf_heatmap.html)
- [Pairwise Plot Matrix](viz/pairs_plot.html)
- [PCA Scatter Plot](viz/pca_scatter.html)
- [K-Means Clusters](viz/kmeans_clusters.html)
- [LDA Top Terms](viz/lda_top_terms.html)
- [Word Statistics Table](viz/word_stats_table.html)
- [Dashboard Gauges](viz/dashboard_gauges.html)
