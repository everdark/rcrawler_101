#!/usr/bin/env Rscript

library(data.table)
library(magrittr)

getAllReact <- function(token, node) {
    require(httr)
    result <- list()
    api_addr <- sprintf("https://graph.facebook.com/v2.6/%s/reactions", node)
    qs <- list(access_token=token)
    r <- GET(api_addr, query=qs)
    res <- content(r)
    if ( !length(res$data) ) {
        result
    } else {
        result <- c(result, res$data)
        while ( "next" %in% names(res$paging) ) {
            next_query <- res$paging$`next`
            r <- GET(next_query)
            res <- content(r)
            result <- c(result, res$data)
        }
        result
    }
}

token <- "XXX"
node <- "XXX"

reactions <- getAllReact(token, node) %>%
    do.call(rbind, .) %>%
    as.data.table

reactions

