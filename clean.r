library(janitor)
library(readr)
library(stringr)
library(dplyr)

# Parse and clean CSV file
file_str <- read_file("./deathrow.csv")

# CSV format: <number>|<info>|<statement>|<rest of record>EOL
pattern <- "^((?:.)+?)\\|((?:.)+?)\\|(.+?)\\|((?:.)+?)$"
regexp <- stringr::regex(pattern, multi = TRUE, dotall = TRUE)

records <- str_match_all(file_str, regexp)[[1]] %>%
  subset(select = -c(1))

records[, 3] <- records[, 3] %>%
  str_replace_all(c("[\n\r]" = " "))

bar_delim <- apply(records, 1, function(x) paste(x, collapse = "|"))
data <- read_delim(bar_delim, quote = "", delim = "|")

data <- data %>%
  clean_names() %>%
  mutate_all(str_trim) %>%
  rename_at(3, ~"statement") %>%
  select(-c("link", "tdcj_number", "county")) %>%
  mutate_at(c("execution", "age"), as.numeric) %>%
  mutate_at("date", as.Date, format = "%m/%d/%Y") %>%
  mutate_at("statement", tolower)

saveRDS(data, "deathrow.rds")
tbl <- tibble(a = 1:3, bc = 4:6)
tbl[, 1, drop = TRUE]
