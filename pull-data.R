library(httr)
library(rvest)
library(stringr)

POST(url = "https://promedmail.org/wp-admin/admin-ajax.php",
     body = list(action = "get_latest_posts_widget",
                 searchterm = "#covid-19",
                 post_count = 20),
     encode = "form") -> res


a <- jsonlite::fromJSON(content(res, as = "text"))


b <- data.frame(full_text = do.call(cbind, strsplit(a[[1]], split = "</li>")[1]))
b$link <- str_match(b$full_text, "<a href=\"(.*?)\"")[,2]

b$date <- str_extract(b$full_text, "[^<ul><li>](.*?)<a")
b$date <- str_trim(str_remove(b$date, pattern = "<a"))
b$date <- as.Date(b$date, "%d %b %Y")

b$caption <- str_match(b$full_text, ">\\s(.*?)</a>")[,2]

out <- b[,c("date", "caption", "link")]
out <- out[!is.na(out$date),]
filnm <- sprintf("%s-promed.csv", format(Sys.time(),"%Y-%m-%d-%H%M"))
write.csv(x = out, row.names = FALSE, file = file.path("data",filnm))
