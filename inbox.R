#!/usr/bin/env Rscript
# notice: the inbox node is deprecated in Graph API v2.4 or above

library(httr)
library(data.table)

# replace with your working token
token <- "XXX"

getAllConversationMembers <- function(token) {
    require(httr)
    require(data.table)
    parseMembers <- function(res_data) {
        con_ids <- sapply(res_data, function(x) x$id)
        con_mem_ids <- lapply(res$data, function(x) 
            sapply(x$to$data, function(y) y$id))
        names(con_mem_ids) <- con_ids
        con_mem_ids
    }
    result <- list()
    api_addr <- "https://graph.facebook.com/v2.3/me/inbox"
    qs <- list(access_token=token)
    res <- content(GET(api_addr, query=qs))
    if ( !length(res$data) ) {
        result
    } else {
        members <- parseMembers(res$data)
        result <- c(result, members)
        while ( "next" %in% names(res$paging) ) {
            next_query <- res$paging$`next`
            res <- content(GET(next_query))
            members <- parseMembers(res$data)
            result <- c(result, members)
        }
        result
    }
}

getConversationWithMemberId <- function(token, mem_id, all_con) {
    require(httr)
    require(data.table)
    parseMessages <- function(res_com_data) {
        # cleanse null message records
        com_data <- res_com_data[sapply(res_com_data, function(x) length(x) == 4)]
        mesg <- lapply(com_data, function(x) 
            list(ts=x$created_time, from=x$from$name, mesg=x$message))
        rbindlist(mesg)
    }
    # restrict to one-to-one conversation
    one2one_con <- all_con[sapply(all_con, length) == 2]
    con_id <- names(which(sapply(one2one_con, function(x) mem_id %in% x)))
    api_addr <- sprintf("https://graph.facebook.com/v2.3/%s", con_id)
    qs <- list(access_token=token)
    res <- content(GET(api_addr, query=qs))
    result <- data.table()
    res <- res$comments # the json structure changes for non-first pages
    if ( !length(res$data) ) {
        result
    } else {
        result <- rbind(result, parseMessages(res$data))
        while ( "next" %in% names(res$paging) ) {
            next_query <- res$paging$`next`
            res <- content(GET(next_query))
            if ( length(res$data) ) # last page is empty
                result <- rbind(result, parseMessages(res$data))
        }
        result[, ts:=as.POSIXct(ts, format="%Y-%m-%dT%H:%M:%S%z")]
        setorder(result, ts)
        result
    }
}

all_con <- getAllConversationMembers(token=token)

# replace with the user id of a person having conversation with you
mem_id <- "YYY"

conv <- getConversationWithMemberId(token=token, mem_id=mem_id, all_con=all_con)
table(conv$from)

# some more analysis can be done creatively :)


