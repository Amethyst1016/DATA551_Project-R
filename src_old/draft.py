import pandas as pd
import datetime




def select_time_range(df, time_range):
    # take time_range as the number of rows to select
    # start from the last row
    end = df['Date'].max()
    d = datetime.timedelta(days=time_range)
    start = end - d
    select = (df['Date'] >= start) & (df['Date'] <= end)
    return df.loc[select]

def top_5_company(time_range, df):
    df_selected = select_time_range(df, time_range)
    company_growth_rate = df_selected.groupby(['GICS Sector', 'Symbol']).apply(lambda x: (x['Close'].iloc[-1] - x['Close'].iloc[0])/x['Close'].iloc[0]).reset_index(name='Growth Rate')

    # Filter the top 5 companies in each sector
    top_5 = company_growth_rate.groupby('GICS Sector').apply(lambda x: x.nlargest(5, 'Growth Rate'))
    top_5 = top_5.reset_index(drop=True)

    # Obtain the symbol of top 5 companies in each sector
    top_5_symbol = top_5['Symbol'].unique().tolist()

    # Subset the df to only include the top 5 companies in each sector
    df_top_5 = df_selected[df_selected['Symbol'].isin(top_5_symbol)]

    return df_top_5


def update_company_options(time_range):
    df_top_5 = top_5_company(time_range, df_bar_chart)
    sectors = df_top_5['GICS Sector'].unique().tolist()
    options = [{'label': sector, 'value': sector} for sector in sectors]
    return options



df_bar_chart = pd.read_csv('SP500_merged.csv')


df_top_5 = top_5_company(7, df_bar_chart)
sectors = df_top_5['GICS Sector'].unique().tolist()
options = [{'label': sector, 'value': sector} for sector in sectors]
options

#%%
