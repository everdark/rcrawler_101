#!/usr/bin/env Rscript

# when R in Windows write a file in text mode but the UTF-8 encoding can not be resolved,
# escaped code point literals are used to represent the original text
# (see example.dat.csv for example)
# this script provides a viable way to force the escaped format back to corrected UTF
# however the best practice in dealing with UTF-8 in Windows is not to write file in text mode but in binary mode
# or even better, don't use Windows :)

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
