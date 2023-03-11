library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashBootstrapComponents)
library(plotly)
library(tidyverse)
library(zoo)

df_line_chart <- read_csv('Global_index.csv')
colnames(df_line_chart) <- make.names(colnames(df_line_chart))
df_line_chart <- df_line_chart |>
  mutate(Date = as.Date(Date)) |>
  mutate(S.P_original = na.approx(S.P_original)) |>
  mutate(S.P_energy = na.approx(S.P_energy)) |>
  mutate(S.P_industry = na.approx(S.P_industry)) |>
  mutate(S.P_consumer = na.approx(S.P_consumer)) |>
  mutate(FTSE_100 = na.approx(FTSE_100)) |>
  mutate(Euro_Stoxx_50 = na.approx(Euro_Stoxx_50)) |>
  mutate(HANG_SENG = na.approx(HANG_SENG)) |>
  mutate(Nikkei_225 = na.approx(Nikkei_225))

df_bar_chart <- read_csv('SP500_merged.csv')
colnames(df_bar_chart) <- make.names(colnames(df_bar_chart))
df_bar_chart <- mutate(df_bar_chart, Date = as.Date(Date))
df_bar_chart <- filter(df_bar_chart, Symbol != 'GEHC')

select_time_range <- function(df, time_range){
  end <- max(df$Date)
  start <- end - time_range
  df_selected <- filter(df, Date>=start, Date<=end)
  df_selected
}

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

app <- Dash$new(external_stylesheets = dbcThemes$BOOTSTRAP)

US_Market  <- list('font-size'=15, 'text-align'='left', 'color'='#036d90', 'margin-left'=20)
other_Market <- list('font-size'=15, 'text-align'='left', 'margin-left'=20)
labels <- list('display'='inline', 'font-size'=20, 'margin-left'=5)
page_height <- '100vh'

symbols <- list(
  list('label'='S.P_original', 'value'='S.P_original'),
  list('label'='S.P_energy', 'value'='S.P_energy'),
  list('label'='S.P_industry', 'value'='S.P_industry'),
  list('label'='S.P_consumer', 'value'='S.P_consumer'),
  list('label'='FTSE_100', 'value'='FTSE_100'),
  list('label'='Euro_Stoxx_50', 'value'='Euro_Stoxx_50'),
  list('label'='HANG_SENG', 'value'='HANG_SENG'),
  list('label'='Nikkei_225', 'value'='Nikkei_225')
)


app$layout(
  htmlDiv(list(
    htmlDiv(list( # left part
      htmlDiv(
        list(htmlP('Summary of Stock Symbol', style=list('font-size'=20,'text-align'='center')),
        htmlP('SP500 - US Market', style=US_Market),
        htmlP('FTSE_100 - London Market', style=other_Market),
        htmlP('Euro_Stoxx_50 - Europe Market', style=other_Market),
        htmlP('HANG_SENG - Hong Kong Market', style=other_Market),
        htmlP('Nikkei_225 - Toyko Market', style=other_Market)),
        style=list('border-style'='solid', 'border-color'='#a1979e', 'margin'=10)
      ),
      dccRadioItems(
        id='time_range_selector',
        options=list(
          list('label'='Last 7 Days', 'value'=7),
          list('label'='Last 30 Days', 'value'=30),
          list('label'='Last 90 Days', 'value'=90),
          list('label'='Last 180 Days', 'value'=180),
          list('label'='Last year', 'value'=365)
        ),
        value=7,
        labelStyle=list('display'='block', 'margin'=20)
      )
    ), style=list('width'='20%','height'='100vh','float'='left','margin'=0,'background'='#e1edd5')),
    htmlDiv(list(# right part
      dbcTabs(list(
        # tab 1 -  Stock markets compare trend plot
        dbcTab(htmlDiv(
          htmlDiv(list(
            htmlDiv(list(
              dccDropdown(
                id='symbol-dropdown',
                options=symbols,
                value='S.P_original',
                style=list('width'=200, 'float'='left')
              ),
              dccDropdown(
                id='compare-dropdown',
                options=symbols,
                value='FTSE_100',
                style=list('width'=200, 'float'='left')
              )
            ), style=list('height'='10%')),
            dccGraph(id='line-chart', figure=c(), style=list('height'='90%'))
        ), style=list('width'='100%', 'height'='90vh'))
      ), label='Stock markets compare trend plot'),
      # tab 2 - SP500 sectors growth rate rank
      dbcTab(htmlDiv(
        id='bar-chart',
        children=c(),
        style=list('width'='100%','height'='90vh')
      ), label='SP500 sectors growth rate rank'),
      # tab 3 - Top 5 companies in SP500 GICS sectors
      dbcTab(list(
        htmlDiv(list(
          dccDropdown(
            id='dropdown_sector',
            options=c(),
            value=c(),
            style=list('width'=300, 'float'='left')),
          dccChecklist(
            id='checkbox_company',
            options=list(),
            value=list(),
            style=list('float'='left', 'margin-left'=10))
        ), style=list('width'='100%', 'display'='inline-block')),
        htmlDiv(dccGraph(
          id='scatter',
          figure=c(),
          style=list('width'='100%', 'height'='45vh')
        )),
        htmlDiv(dccGraph(
          id='pie', 
          figure=c(),
          style=list('width'='100%', 'height'='45vh')
        ))
      ), label='Top 5 companies in SP500 GICS sectors')
    ))
  ), style=list('width'='80%', 'height'='100%', 'float'='right', 'margin'=0))
))
)


app$callback(
<<<<<<< HEAD
  output(id = 'bar-chart', property = 'children'),
  list(input(id = 'time_range_selector', property = 'value')),
  function(time_range){
    df_selected <-  select_time_range(df_bar_chart, time_range)

    sector_growth_rate <- df_selected %>%
      group_by(`GICS Sector`) %>%gi
      summarize(growth_rate = (last(Close) / first(Close) - 1))

    sector_growth_rate$marker_color <- ifelse(sector_growth_rate$growth_rate > 0, 'green', 'red')

    fig <- plot_ly(sector_growth_rate, x = ~`GICS Sector`, y = ~growth_rate, type = 'bar',
                   marker = list(color = ~marker_color)) %>%
      layout(title = 'Sector Growth Rates',
             xaxis = list(title = 'Sector', categoryorder = 'total descending'),
             yaxis = list(title = 'Growth Rate'))

    return(fig)
=======
  output(id = 'dropdown_sector', property = 'options'),
  list(input(id = 'time_range_selector', property = 'value')),
  function(time_range){
    df_top_5 <- top_5_company(time_range, df_bar_chart)
    sectors <- unique(df_top_5$GICS.Sector)
    options <- lapply(sectors, function(x) list('label'=x, 'value'=x))
    options
>>>>>>> 65375eaec40eadb732de48cb1d14e92d3a5f1bb6
  }
)

app$callback(
<<<<<<< HEAD
  output(id = 'dropdown_sector', property = 'options'),
  list(input(id = 'time_range_selector', property = 'value')),
  function(time_range){
    df_top_5 <- top_5_company(time_range, df_bar_chart)
    sectors <- unique(df_top_5$GICS.Sector)
    options <- lapply(sectors, function(x) list('label'=x, 'value'=x))
    options
  }
)

app$callback(
=======
>>>>>>> 65375eaec40eadb732de48cb1d14e92d3a5f1bb6
  output(id = 'dropdown_sector', property = 'value'),
  list(input(id = 'time_range_selector', property = 'value')),
  function(time_range){
    df_top_5 <-  top_5_company(time_range, df_bar_chart)
    sectors <- unique(df_top_5$GICS.Sector)
    return (sectors[1])
  }
)

# Define the callback to update the options of the checkbox based on the selected sector
app$callback(
  output(id = 'checkbox_company', property = 'options'),
  list(input(id = 'dropdown_sector', property = 'value'),
       input(id = 'time_range_selector', property = 'value')),
  function(selected_sector, time_range){
    df_top_5 <-  top_5_company(time_range, df_bar_chart)
    df_top_5_selected_sector <- df_top_5 %>% filter(GICS.Sector %in% selected_sector)
    top_5_symbol <- unique(df_top_5_selected_sector$Symbol)
    options <- lapply(top_5_symbol, function(x) list('label'=x, 'value'=x))
    return (options)
  }
)

app$callback(
  output(id = 'checkbox_company', property = 'value'),
  list(input(id = 'dropdown_sector', property = 'value'),
       input(id = 'time_range_selector', property = 'value')),
  function(selected_sector, time_range){
    df_top_5 <-  top_5_company(time_range, df_bar_chart)
    df_top_5_selected_sector <- df_top_5 %>% filter(GICS.Sector %in% selected_sector)
    top_5_symbol <- unique(df_top_5_selected_sector$Symbol)
    return (top_5_symbol)
  }
)

# Define the callback to update the graph based on the selected sector and companies
app$callback(
  output(id = 'scatter', property = 'figure'),
  list(input(id = 'dropdown_sector', property = 'value'),
       input(id = 'checkbox_company', property = 'value'),
       input(id = 'time_range_selector', property = 'value')),
  function(selected_sector, selected_companies, time_range){
    df_top_5 <-  top_5_company(time_range, df_bar_chart)
    df_top_5_selected_sector <- df_top_5 %>% filter(GICS.Sector %in% selected_sector)

    if (is.null(selected_companies) || length(selected_companies) == 0) {
      # If no companies are selected, return an empty dataframe
      df_top_5_selected_sector_company <- data.frame(matrix(ncol = ncol(df_top_5_selected_sector),
                                                            nrow = 0,
                                                            dimnames = list(colnames(df_top_5_selected_sector))),
                                                     stringsAsFactors = FALSE)
    } else {
      # Filter the dataframe based on the selected companies
      df_top_5_selected_sector_company <- df_top_5_selected_sector %>%
        filter(Symbol %in% selected_companies)
    }

    chart <- ggplot(df_top_5_selected_sector_company, aes(x = Date, y = Close, color = Symbol)) +
      geom_line() +
      geom_point()  +
      labs(x = 'Date', y = 'Close Price', title = 'Top 5 companies in selected sector') +
      theme(plot.title = element_text(hjust = 0.5))

    ggplotly(chart)
<<<<<<< HEAD
  }
)

# Define the callback to update the graph based on the selected sector
app$callback(
  output(id = 'pie', property = 'figure'),
  list(input(id = 'dropdown_sector', property = 'value'),
       input(id = 'time_range_selector', property = 'value')),
  function(selected_sector, time_range){
    df_top_5 <-  top_5_company(time_range, df_bar_chart)
    df_top_5_selected_sector <- df_top_5 %>% filter(GICS.Sector %in% selected_sector)

    df_summary <- df_top_5_selected_sector %>%
      group_by(Symbol) %>%
      summarize(Volume = sum(Volume)) %>%
      mutate(Proportion = Volume/sum(Volume))


    chart <- ggplot(df_summary, aes(x = '', y = Volume, color = Symbol, fill = Symbol, label = Proportion)) +
      geom_bar(stat = "identity") +
      coord_polar(theta = "y")

    ggplotly(chart)
=======
>>>>>>> 65375eaec40eadb732de48cb1d14e92d3a5f1bb6
  }
)


app$run_server(debug = T)
