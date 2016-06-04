#!/usr/bin/env Rscript

getComments <- function(pid, token) {
    require(data.table)
    require(magrittr)
    require(httr)
    result <- list()
    fields <- c("id", "message", "comment_count", "like_count")
    api_addr <- sprintf("https://graph.facebook.com/v2.6/%s/comments?fields=%s", 
                        pid, paste(fields, collapse=','))
    qs <- list(access_token=token)
    r <- GET(api_addr, query=qs)
    res <- content(r)
    result <- 
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
            result %>% rbindlist %>% cbind(pid=pid)
        }
    result
}

token <- "XXX"
pid <- "XXX"

comments <- getComments(pid, token)
replies <- lapply(comments[comment_count > 0, id], getComments, token=token) %>% rbindlist

res <- rbind(comments, replies)
res


