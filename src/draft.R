df_bar_chart <- read_csv('SP500_merged.csv')
colnames(df_bar_chart) <- make.names(colnames(df_bar_chart))
df_bar_chart <- mutate(df_bar_chart, Date = as.Date(Date))
df_bar_chart <- filter(df_bar_chart, Symbol != 'GEHC')

head(df_bar_chart)

top_5_company <- function(time_range, df){
  df_selected <- select_time_range(df, time_range)
  company_growth_rate <- df_selected |>
    group_by(GICS.Sector, Symbol)|>
    filter(row_number() == 1 | row_number() == n()) |>
    mutate(diff=Close-lag(Close,default=first(Close)), min=lag(Close,default=first(Close))) |>
    filter(diff != 0) |>
    mutate(Growth.Rate = diff/min) |>
    select(-diff, -min)
  top_5 <- company_growth_rate |>
    arrange(desc(Growth.Rate)) |>
    group_by(GICS.Sector) |>
    slice(1:5) |>
    group_by(Symbol) |>
    pull(Symbol)
  df_top_5 <- df_selected |>
    filter(Symbol %in% top_5)
  df_top_5
}

df_top_5 <-  top_5_company(7, df_bar_chart)
sectors <- unique(df_top_5$GICS.Sector)
options <- lapply(sectors, function(x) list('label'=x, 'value'=x))
options

list(
  list(label = "Industrials", value = "Industrials"),
  list(label = "Health Care", value = "Health Care"),
  list(label = "Information Technology", value = "Information Technology"),
  list(label = "Communication Services", value = "Communication Services"),
  list(label = "Consumer Staples", value = "Consumer Staples"),
  list(label = "Consumer Discretionary", value = "Consumer Discretionary"),
  list(label = "Utilities", value = "Utilities"),
  list(label = "Financials", value = "Financials"),
  list(label = "Materials", value = "Materials"),
  list(label = "Real Estate", value = "Real Estate"),
  list(label = "Energy", value = "Energy")
)





df_top_5 <-  top_5_company(7, df_bar_chart)
df_top_5_selected_sector <- df_top_5 %>% filter(GICS.Sector %in% 'Health Care')
#df_top_5_selected_sector['Date'] <- as.date(df_top_5_selected_sector['Date'])

if (is.null('ALGN') || length('ALGN') == 0) {
  # If no companies are selected, return an empty dataframe
  df_top_5_selected_sector_company <- data.frame(matrix(ncol = ncol(df_top_5_selected_sector),
                                                        nrow = 0,
                                                        dimnames = list(NULL,
                                                                        colnames(df_top_5_selected_sector))),
                                                 stringsAsFactors = FALSE)
} else {
  # Filter the dataframe based on the selected companies
  df_top_5_selected_sector_company <- df_top_5_selected_sector %>%
    filter(Symbol %in% 'ALGN')
}

ggplot(df_top_5_selected_sector_company, aes(x = Date, y = Close, color = Symbol)) +
  geom_line() +
  geom_point() +
  scale_color_manual(values = c('#FF0000', '#0000FF', '#00FF00', '#FF00FF', '#FFFF00')) +
  labs(x = 'Date', y = 'Close Price', title = 'Top 5 companies in selected sector') +
  theme(plot.title = element_text(hjust = 0.5))


