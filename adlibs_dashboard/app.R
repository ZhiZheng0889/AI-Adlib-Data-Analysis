library(shiny)
library(bslib)
library(DBI)
library(RSQLite)
library(dplyr)
library(ggplot2)
library(DT)

# ── Database connection ────────────────────────────────────────────────────────
db_path <- "C:/Users/zhizh/OneDrive/Desktop/adlibs.db"
get_con <- function() dbConnect(SQLite(), db_path)

# ── Pre-load summary data ──────────────────────────────────────────────────────
con <- get_con()

total_ai_adlibs  <- dbGetQuery(con, "SELECT COUNT(*) AS n FROM ai_adlibs WHERE deleted_at IS NULL OR deleted_at = 0")$n
total_results    <- dbGetQuery(con, "SELECT COUNT(*) AS n FROM adlib_results WHERE deleted_at IS NULL OR deleted_at = 0")$n
total_categories <- dbGetQuery(con, "SELECT COUNT(*) AS n FROM ai_categories WHERE deleted_at IS NULL OR deleted_at = 0")$n
total_old_adlibs <- dbGetQuery(con, "SELECT COUNT(*) AS n FROM adlibs")$n

results_over_time <- dbGetQuery(con, "
  SELECT substr(created_at, 1, 7) AS month, COUNT(*) AS n
  FROM adlib_results
  WHERE deleted_at IS NULL OR deleted_at = 0
  GROUP BY month
  ORDER BY month
")

top_categories <- dbGetQuery(con, "
  SELECT c.name, COUNT(*) AS n
  FROM ai_adlib_cats ac
  JOIN ai_categories c ON ac.category_id = c.id
  GROUP BY c.name
  ORDER BY n DESC
  LIMIT 15
")

tone_dist <- dbGetQuery(con, "
  SELECT t.style, t.character, COUNT(a.id) AS n
  FROM ai_adlibs a
  JOIN adlib_tones t ON a.tone_id = t.id
  WHERE a.deleted_at IS NULL OR a.deleted_at = 0
  GROUP BY t.style, t.character
")

adlib_flags <- dbGetQuery(con, "
  SELECT
    SUM(CASE WHEN is_featured = 1 THEN 1 ELSE 0 END) AS featured,
    SUM(CASE WHEN is_pg = 1 THEN 1 ELSE 0 END)       AS pg,
    SUM(CASE WHEN is_hidden = 1 THEN 1 ELSE 0 END)   AS hidden
  FROM ai_adlibs
  WHERE deleted_at IS NULL OR deleted_at = 0
")

feature_toggle <- dbGetQuery(con, "SELECT name, category, is_on FROM feature_toggles")
tones_ref      <- dbGetQuery(con, "SELECT id, style FROM adlib_tones")

dbDisconnect(con)

# ── UI ─────────────────────────────────────────────────────────────────────────
ui <- page_navbar(
  title = "AI Adlibs Dashboard",
  theme = bs_theme(bootswatch = "flatly", primary = "#2c7be5"),

  # ── Overview ──────────────────────────────────────────────────────────────
  nav_panel(
    "Overview",
    layout_columns(
      col_widths = c(3, 3, 3, 3),
      value_box("AI Adlibs",     total_ai_adlibs,  showcase = bsicons::bs_icon("file-text"),     theme = "primary"),
      value_box("Results",       total_results,    showcase = bsicons::bs_icon("check2-circle"),  theme = "success"),
      value_box("Categories",    total_categories, showcase = bsicons::bs_icon("tags"),           theme = "info"),
      value_box("Legacy Adlibs", total_old_adlibs, showcase = bsicons::bs_icon("archive"),        theme = "secondary")
    ),
    layout_columns(
      col_widths = c(8, 4),
      card(
        card_header("Results Generated Over Time"),
        plotOutput("results_time_plot", height = "300px")
      ),
      card(
        card_header("Adlib Flags"),
        plotOutput("flags_plot", height = "300px")
      )
    ),
    card(
      card_header("Feature Toggles"),
      tableOutput("feature_toggle_table")
    )
  ),

  # ── Categories ────────────────────────────────────────────────────────────
  nav_panel(
    "Categories",
    card(
      card_header("Top 15 Categories by Adlib Count"),
      plotOutput("top_categories_plot", height = "500px")
    )
  ),

  # ── Tones ─────────────────────────────────────────────────────────────────
  nav_panel(
    "Tones",
    layout_columns(
      col_widths = c(6, 6),
      card(
        card_header("Tone Distribution"),
        plotOutput("tone_plot", height = "350px")
      ),
      card(
        card_header("Tone Details"),
        DTOutput("tone_table")
      )
    )
  ),

  # ── Browse ────────────────────────────────────────────────────────────────
  nav_panel(
    "Browse Adlibs",
    layout_sidebar(
      sidebar = sidebar(
        selectInput("browse_filter", "Filter by:",
                    choices = c("All", "Featured", "PG-Rated", "Hidden")),
        selectInput("browse_tone", "Tone:",
                    choices = c("All", setNames(tones_ref$id, tones_ref$style))),
        numericInput("browse_n", "Max rows:", value = 100, min = 10, max = 1000, step = 50)
      ),
      card(DTOutput("adlibs_table"))
    )
  )
)

# ── Server ─────────────────────────────────────────────────────────────────────
server <- function(input, output, session) {

  output$results_time_plot <- renderPlot({
    ggplot(results_over_time, aes(x = month, y = n, group = 1)) +
      geom_line(color = "#2c7be5", linewidth = 1) +
      geom_point(color = "#2c7be5", size = 2) +
      labs(x = NULL, y = "Results Generated") +
      theme_minimal(base_size = 13) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })

  output$flags_plot <- renderPlot({
    flags_long <- data.frame(
      flag  = c("Featured", "PG-Rated", "Hidden"),
      count = c(adlib_flags$featured, adlib_flags$pg, adlib_flags$hidden)
    )
    ggplot(flags_long, aes(x = flag, y = count, fill = flag)) +
      geom_col(show.legend = FALSE) +
      labs(x = NULL, y = "Count") +
      theme_minimal(base_size = 13)
  })

  output$feature_toggle_table <- renderTable({
    feature_toggle |>
      mutate(Status = ifelse(is_on == 1, "ON", "OFF")) |>
      select(Name = name, Category = category, Status)
  })

  output$top_categories_plot <- renderPlot({
    ggplot(top_categories, aes(x = n, y = reorder(name, n))) +
      geom_col(fill = "#2c7be5") +
      labs(x = "Number of Adlibs", y = NULL) +
      theme_minimal(base_size = 13)
  })

  output$tone_plot <- renderPlot({
    if (nrow(tone_dist) == 0) {
      ggplot() + annotate("text", x = 0.5, y = 0.5, label = "No tone data") + theme_void()
    } else {
      ggplot(tone_dist, aes(x = reorder(style, n), y = n, fill = character)) +
        geom_col() +
        labs(x = "Tone Style", y = "Adlibs", fill = "Character") +
        theme_minimal(base_size = 13) +
        theme(axis.text.x = element_text(angle = 30, hjust = 1))
    }
  })

  output$tone_table <- renderDT({
    datatable(tone_dist, options = list(pageLength = 10), rownames = FALSE)
  })

  # Reactive browsing query
  adlibs_data <- reactive({
    con <- get_con()
    q <- "
      SELECT a.id, a.title, a.is_featured, a.is_pg, a.is_hidden,
             a.temperature, a.top_p, t.style AS tone, a.created_at
      FROM ai_adlibs a
      LEFT JOIN adlib_tones t ON a.tone_id = t.id
      WHERE (a.deleted_at IS NULL OR a.deleted_at = 0)
    "
    if (input$browse_filter == "Featured") q <- paste0(q, " AND a.is_featured = 1")
    if (input$browse_filter == "PG-Rated") q <- paste0(q, " AND a.is_pg = 1")
    if (input$browse_filter == "Hidden")   q <- paste0(q, " AND a.is_hidden = 1")
    if (input$browse_tone != "All")        q <- paste0(q, " AND a.tone_id = '", input$browse_tone, "'")
    q <- paste0(q, " LIMIT ", input$browse_n)
    result <- dbGetQuery(con, q)
    dbDisconnect(con)
    result
  })

  output$adlibs_table <- renderDT({
    datatable(adlibs_data(),
              options = list(pageLength = 20, scrollX = TRUE),
              rownames = FALSE)
  })
}

shinyApp(ui, server)
