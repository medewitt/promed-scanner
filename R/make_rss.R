#' Purpose:
#'     Generate an RSS using the available files
#'

make_rss <- function(site_config = yaml::read_yaml("_config.yaml"), files){
  # Based off of RSS Create from Distill
  # https://github.com/rstudio/distill/blob/cd7cf53ad0069a4b221baadb1dfedf433723e040/R/sitemap.R

  namespaces <- list(
    "xmlns:atom" = "http://www.w3.org/2005/Atom",
    "xmlns:media" = "http://search.yahoo.com/mrss/",
    "xmlns:content" = "http://purl.org/rss/1.0/modules/content/",
    "xmlns:dc" = "http://purl.org/dc/elements/1.1/"
  )

  feed <- do.call("xml_new_root", c("rss", namespaces, list(version = "2.0")), envir = asNamespace("xml2"))

  # helper to add a child element
  add_child <- function(node, tag, attr = c(), text = NULL, optional = FALSE) {
    child <- xml2::xml_add_child(node, tag)
    xml2::xml_set_attrs(child, attr)
    if (!is.null(text))
      xml2::xml_text(child) <- text
    child
  }
  set_locale <- function (cats) {
    cats <- as_character(cats)
    if ("LC_ALL" %in% names(cats)) {
      stop("Setting LC_ALL category not implemented.", call. = FALSE)
    }
    old <- vapply(names(cats), Sys.getlocale, character(1))
    mapply(Sys.setlocale, names(cats), cats)
    invisible(old)
  }
  with_locale <-function (new, code) {
    old <- set_locale(cats = new)
    on.exit(set_locale(old))
    force(code)
  }
  as_character <- function (x) {
    nms <- names(x)
    res <- as.character(x)
    names(res) <- nms
    res
  }
  is_windows <- function() {
    .Platform$OS.type == "windows"
  }
  date_as_rfc_2822 <- function(date) {
    date <- as.Date(date, tz = "UTC")
    with_locale(
      new = c("LC_TIME" = ifelse(is_windows(), "English", "en_US.UTF-8")),
      as.character(date, format = "%a, %d %b %Y %H:%M:%S %z", tz = "UTC")
    )
  }

  channel <- xml2::xml_add_child(feed, "channel")
  add_channel_attribute <- function(name) {
    if (!is.null(collection[[name]]))
      add_child(channel, name, text = collection[[name]])
  }
  add_channel_attribute("title")
  add_child(channel, "link", text = site_config$base_url)

  for (article in seq_along(files$caption)) {
  item <- add_child(channel, "item")
  add_child(item, "title", text = files$caption[article])
  add_child(item, "link", text = files$link[article])
  add_child(item, "pubDate", text = date_as_rfc_2822(files$date[article]))

  }


  xml2::write_xml(feed, "test.rss")

}
