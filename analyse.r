library(sentimentr)
library(stringr)
library(dplyr)
library(ggplot2)
library(tidytext)
library(tidyr)
library(wordcloud)

data <- readRDS("./deathrow.rds")

# Executions per year
executions_per_year <- data %>%
  group_by(year = format(date, "%Y")) %>%
  count() %>%
  ungroup() %>%
  mutate_at("year", as.numeric)

ggplot(executions_per_year, aes(x = year, y = n)) +
  geom_bar(stat = "identity") +
  labs(title = "Executions per year", x = "Year", y = "Executions")

# Average age by year
year_avg <- data %>%
  group_by(year = format(date, "%Y")) %>%
  summarise(mean_age = mean(age)) %>%
  mutate_at("year", as.numeric)

ggplot(year_avg, aes(x = year, y = mean_age)) +
  geom_bar(stat = "identity") +
  labs(title = "Average age at execution by year", x = "Year", y = "Age")

# Average age by race
age_by_race <- aggregate(age ~ race, data, mean)

ggplot(age_by_race, aes(x = race, y = age)) +
  geom_bar(stat = "identity", width = 0.5) +
  labs(title = "Average age at execution by race", x = "Year", y = "Race")

# Race distribution by year
race_by_year <- data %>%
  group_by(year = format(date, "%Y")) %>%
  count(race) %>%
  ungroup() %>%
  mutate_at("year", as.numeric) %>%
  pivot_wider(names_from = race,
              values_from = n,
              values_fill = list(n = 0)) %>%
  select(-c("Other")) # Sample too small

race_by_year_long <- race_by_year %>%
  pivot_longer(-year, names_to = "race", values_to = "count")

ggplot(race_by_year_long, aes(x = year, y = count, fill = race)) +
  geom_bar(stat = "identity") +
  labs(title = "Race distribution by year", x = "Year", y = "Race") +
  theme_bw() +
  scale_fill_grey()

# Most frequest words
words <- data %>%
  select("statement") %>%
  unnest_tokens(word, statement) %>%
  anti_join(stop_words) %>%
  count(word, sort = TRUE) %>%
  slice(1:100)

wordcloud(words$word, words$n, random.order = FALSE, scale = c(10, 1))

# Most frequent phrases
trigrams <- data %>%
  select("statement") %>%
  unnest_tokens(trigram, statement, token = "ngrams", n = 3) %>%
  count(trigram, sort = TRUE) %>%
  slice(1:100)

wordcloud(trigrams$trigram, trigrams$n, random.order = FALSE, scale = c(10, 1))

# Sentiment analysis
sentiments <- data %>%
  mutate(sentiment = sentiment_by(statement)$ave_sentiment) %>%
  arrange(sentiment) %>%
  select(c("statement", "sentiment"))

# Sentiment by age
sentiment_by_age <- data %>%
  mutate(cuts = cut(age, seq(20, 80, 10))) %>%
  mutate(sentiment = sentiment_by(statement)$ave_sentiment) %>%
  group_by(cuts) %>%
  select(cuts, sentiment)

ggplot(sentiment_by_age, aes(x = cuts, y = sentiment)) +
  geom_boxplot() +
  labs(title = "Sentiment by age", x = "Age group", y = "Sentiment")

# Sentiment by race
sentiment_by_race <- data %>%
  mutate(sentiment = sentiment_by(statement)$ave_sentiment) %>%
  group_by(race) %>%
  filter(race != "Other") # Sample too small

ggplot(sentiment_by_race, aes(x = race, y = sentiment)) +
  geom_boxplot() +
  labs(title = "Sentiment by race", x = "Race", y = "Sentiment")
