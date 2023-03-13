# Reflection-milestone3

So far, all four main plots have been completed using daily data. The functions are equivalent R-version code with ggplotly.
Minute data will be added in a later stage. But it might become optional based on the workload for the final project.

### The current content of the dashboard includes:
- Plot 1. Line plot: Comparison of global indices
- Plot 2. Bar chart: Growth rate for each sector
- Plot 3. Line plot: Close price of the top 5 companies in each sector
- Plot 4. Pie chart: Volume of the top 5 companies in each sector

### Reflection on implementing the dashboard a second time in another language.
On the one hand, having prior experience with the design and development process in Python made the process of implementing the dashboard in R more efficient and streamlined. On the other hand, working with R requires a learning curve and have posed new challenges that were not present during the first implementation. From Python to R, it’s not just copy and paste. Although the main framework is similar, the details are different, which includes the difference in grammar, function and package. Overall, this experience gave us a valuable learning experience, as it provides an opportunity to gain new insights, expand our skillset, and learn how to work with different tools and technologies.

### Reflection on current process:
Reflection on implementing the dashboard in a different language for the second time showed that prior experience with the design and development process in Python helped streamline the process of implementing the dashboard in R, but working with R also presented new challenges. Although the main framework was similar, the details differed, including differences in grammar, function, and package. This experience provided an opportunity to expand skill sets, gain new insights, and learn how to work with different tools and technologies.

Regarding the current process, Plot 1 now allows users to choose which two global indices to compare, while Plot 2 calculates the growth rate based on a selected time period and displays the top 5 companies in a sector when hovering over a bar. However, due to time constraints, we cannot highlight the specified company on Plots 3 and 4.

The overall framework has been completed, allowing investors to track global indices and individual company stock prices, but there are still limitations and areas for improvement. For instance, the large amount of data required for data processing can be time-consuming and inconvenient for users when launching the app. Additionally, when selecting multiple global indices in Plot 1, the lines in the plot may not be distinct. The method of calculating growth rates in Plots 2 and 3 is currently slow and needs improvement.

### Limitations and future improvement
Prior to generating the plots, the first step is to complete data processing, which involves generating daily and minute data for global indices and companies in the S&P 500. However, due to the large amount of data, downloading and processing can be time-consuming and inconvenient for users when launching the app.

When selecting multiple (more than two) global indices in Plot 1, the lines in the plot may not be distinct due to the different Close prices of the indices.
The method of calculating growth rate in Plot 2 and 3 is currently slow, which affects the user experience. Improvements to the calculation method will be made in the future.

Moreover, investors care about more than just stock prices; they also look at a company's PE ratio, which provides a quick and simple way to evaluate its stock valuation. Plot 5 could be added to the dashboard to display the PE ratio of the top 5 companies alongside Plots 3 and 4, giving investors diverse metrics to help make investment decisions.

