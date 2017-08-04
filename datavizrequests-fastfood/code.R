# Fast Food Data Visualization from Reddit.com/r/DataVizRequests
# Page: https://www.reddit.com/r/DataVizRequests/comments/6rgefo/request_chart_my_fast_food_spending_habits/

library(readxl); library(dplyr); library(stringr); library(ggplot2); library(tidyr)
library(lubridate)

# Spending: 1 line per "visit" to a place
spending <- 
  bind_rows(read_excel("Fast Food 2017 So Far.xlsx"), 
            read_excel("Fast Food 2016.xlsx")) %>%
  rename(date = Date, amount = `$ Spent`) %>%
  mutate(place = as.factor(Place),
         year = year(date), month = month(date), week = week(date),
         weekday = wday(date),
         quarter = quarter(date)) %>%
  select(-Place)

# Table of info by place
summary1 <- 
  spending %>% group_by(place) %>% 
  summarise(visits = n(), total.amount = sum(amount),
            amount.per.visit = total.amount / visits) %>%
  mutate(type = factor(ifelse(amount.per.visit >= 10, "Expensive", "Cheap"),
                       levels = c("Cheap", "Expensive")))

# Plot: Monthly Amount Spent ----
spending %>% 
  left_join(summary1 %>% select(place, type), by = "place") %>% 
  group_by(month, type, year) %>% 
  summarise(amount = sum(amount)) %>% 
  ggplot() + 
  geom_line(aes(factor(month), amount, color = type, group = type), size = 1) + 
  facet_wrap(~year) + xlab("Month") + ylab("Total Amount") + 
  ggtitle("Monthly Amount Spent, by Type of Restaurant", 
          subtitle = "Cheap: Avg Amt per Visit < $10,  Expensive: >= $10")
ggsave("monthly.spending.png", width = 8, height = 4)

# Plot: Quarterly Amount Spent ----
spending %>% 
  left_join(summary1 %>% select(place, type), by = "place") %>% 
  filter(!(year == 2017 & quarter == 3)) %>%
  group_by(quarter, type, year) %>% 
  summarise(amount = sum(amount)) %>% 
  ggplot() + 
  geom_line(aes(factor(quarter), amount, color = type, group = type), size = 1) + 
  geom_point(aes(factor(quarter), amount, color = type)) + 
  facet_wrap(~year) + xlab("Quarter") + ylab("Total Amount") + 
  ggtitle("Quarterly Amount Spent, by Type of Restaurant", 
          subtitle = "Cheap: Avg Amt per Visit < $10,  Expensive: >= $10") +
  scale_y_continuous(breaks = seq(0, 200, by = 25), minor_breaks = NULL)
ggsave("quarterly.spending.png", width = 8, height = 4)