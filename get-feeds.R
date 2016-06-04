#!/usr/bin/env Rscript


getPostIdFromFeed <- function(token) {
    require(data.table)
    require(magrittr)
    require(httr)
    result <- list()
    api_addr <- "https://graph.facebook.com/v2.6/me/feed"
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
        result %<>% 
            lapply(function(x) c(time=x$created_time, pid=x$id)) %>% 
            do.call(rbind, .) %>%
            as.data.table %>%
            .[, time:=as.POSIXct(time, format="%Y-%m-%dT%H:%M:%S%z")]
        result
    }
}

token <- "XXX"

res <- getPostIdFromFeed(token)
res



