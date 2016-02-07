## Kaggle San Francisco Crime Classification Competition: Leaderboard Plots

#### Intro
I just started the San Francisco Crime Classification Competition, and before digging in, I wanted to get a rough profile of the field I am up against.  I was also curious how Kaggle's score benchmark compared to the entries, and if there were other benchmarks I could look for.

#### Set up libraries rvest & ggplot2, and read leaderboard html:

```{r, warning=FALSE, message=FALSE}
library(rvest)
library(ggplot2)
library(dplyr)
page <- "https://www.kaggle.com/c/sf-crime/leaderboard"
page.html <- read_html(page)
leaderboard <- page.html %>% html_nodes("#leaderboard-table") %>% html_table() %>% .[[1]]

names(leaderboard) <- c("rank","delta.1wk","team.name","score",
                        "num.entries","last.submission")
```

Calculate % of entries less than the benchmark of 32.89184
```{r}
leaderboard %>% filter(score < 32.89184) %>% summarise(count = n()) %>% as.numeric(.)/length(leaderboard[,1])
```

#### Plot #1

At first glance, there are some patterns evident in the data, by looking at the plot:
* 2 main clusters in score: 0-5, and 24+
* The entries with score less than 4 are the only ones with 30 or more entries
* The competition is pretty tough up at the higher ranks (i.e. lower score)

```{r, warning=FALSE}
ggplot(leaderboard, aes(num.entries, score)) + geom_point() + 
     geom_hline(yintercept = 32.89184, color="red") + ggtitle(paste0("score vs. number entries (red line: benchmark) - ",Sys.Date()))
```


#### Plot #2

```{r, warning=FALSE}
ggplot(leaderboard, aes(score, rank)) + geom_point() + 
     geom_vline(aes(xintercept = 32.89184, color="1")) + 
     geom_vline(aes(xintercept = 2, color = "3")) +
     geom_vline(aes(xintercept = 4, color = "2")) +
     geom_vline(aes(xintercept = 24, color = "2")) +
     geom_vline(aes(xintercept = 27.63, color = "2")) +
     ggtitle(paste0("score vs. rank (red line: benchmark) - ",Sys.Date())) +
     theme(legend.position = "none")
```

Score ranges (as of 2/7/16)

* `[2-4)`: 75.8%
* `[4-24)`: 5.6% (cumulative: 81.4%)
* `[24:27)`: 9.1% (cumulative: 90.5%)
* `[27:benchmark)`: 5.3% (cumulative: 95.8%)
* `[benchmark:max]`: 4.1%

#### Conclusion

Once I get my code up and running for competition, I'll have a good idea of which camp I'm in.  Since this is my first time doing a Kaggle competition, as well as my first running a machine learning algorithm, I'll be satisfied to get a better-than-benchmark score.  I'd like to get at least below 27, which would put me in the top 90% of the field (as of 2/7/16)