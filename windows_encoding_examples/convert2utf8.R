

library(Unicode)
library(data.table)
library(magrittr)
library(stringr)

dat <- fread("example.dat.csv")

corrected <- str_match_all(dat$district, "U\\+([0-9A-Z]+)>") %>% 
    lapply(function(x) x[,2]) %>%
    lapply(as.u_char) %>%
    sapply(intToUtf8)

dat$district <- corrected
dat %>% head
