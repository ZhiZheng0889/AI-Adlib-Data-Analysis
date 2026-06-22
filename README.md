# AI Adlib Data Analysis

Exploratory data analysis and interactive visualizations for comparing human-written adlibs with AI-generated results. The project uses R for data preparation, text analysis, sentiment analysis, topic modeling, clustering, and dashboard development.

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

GitHub may display large interactive HTML files as source. Download or clone the repository and open them locally for the full interactive experience.

## Data

The `data/` directory contains database exports used by the notebooks and the Shiny app. Treat these files as project inputs; rerunning the analysis writes derived artifacts to `viz/` and `reports/`.

## Reproducibility Notes

- Run commands from the repository root so relative paths resolve consistently.
- Some sentiment lexicons may be downloaded by `textdata` on first use.
- Package versions are not currently locked; adding `renv` is the recommended next step for fully reproducible environments.
