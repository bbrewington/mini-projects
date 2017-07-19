library(readxl); library(dplyr); library(stringr); library(tidyr)
library(ggplot2); library(gganimate)

months <- data.frame(month.num = 1:12,
                     month.name = c("January", "February", "March",
                                  "April", "May", "June", "July",
                                  "August", "September", "October",
                                  "November", "December"),
                     stringsAsFactors = F)

# Download this file and save in working directory:
#   ftp://sidads.colorado.edu/DATASETS/NOAA/G02135/seaice_analysis/Sea_Ice_Index_Monthly_Data_by_Year_G02135_v2.1.xlsx
# (I got a .zip error when using download.file, so doing this part manually)

ice1 <- 
  bind_rows(read_excel("~/../Downloads/Sea_Ice_Index_Monthly_Data_by_Year_G02135_v2.1.xlsx",
           sheet = "NH-Extent") %>% 
            rename(year = X__1) %>%
            select(-X__2, -Annual) %>%
            mutate(region = "North"),
          read_excel("~/../Downloads/Sea_Ice_Index_Monthly_Data_by_Year_G02135_v2.1.xlsx",
                     sheet = "SH-Extent") %>% 
            rename(year = X__1) %>%
            select(-X__2, -Annual) %>%
            mutate(region = "South")) %>%
  gather(month, ice.extent, January:December) %>%
  left_join(
    ice1 %>% group_by(region, year) %>% 
      summarise(mean.yearly.extent = mean(ice.extent, na.rm=T)) %>% 
      ungroup(),
    by = c("region", "year")) %>%
  arrange(region, year) %>%
  left_join(months, by = c("month" = "month.name")) %>%
  filter(!(year %in% c(1978, 2017)))
p <- 
  ggplot(ice1) + 
  geom_line(aes(month.num, ice.extent, group = 1, frame = year)) + 
  geom_line(data = ice1 %>% filter(year == 1979),
            mapping = aes(month.num, ice.extent, group = 1),
            color = "red") +
  geom_point(aes(month.num, ice.extent, frame = year)) + 
  geom_point(data = ice1 %>% filter(year == 1979),
             mapping = aes(month.num, ice.extent),
             color = "red") +
  geom_hline(aes(frame = year, yintercept = mean.yearly.extent)) +
  geom_hline(data = ice1 %>% filter(year == 1979) %>% 
               select(region, mean.yearly.extent) %>% distinct(),
             mapping = aes(yintercept = mean.yearly.extent),
             color = "red") +
  facet_wrap(~region) +
  scale_x_continuous(breaks = 1:12, minor_breaks = NULL) +
  ylab("Ice Extent Index") +
  xlab("Month")
gganimate(p, filename = "Ice Extent Index.gif", 
          interval = .4, ani.height = 300, ani.width = 500)
