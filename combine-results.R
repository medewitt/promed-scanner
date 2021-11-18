library(data.table)

last_30 <- tail(list.files(all.files = TRUE,
                           recursive = TRUE,
                           path = "data",
                           full.names = TRUE),30)

dat_combined <- rbindlist(lapply(last_30, fread))

dat_combined <- unique(dat_combined)

dat_combined <- dat_combined[order(date, decreasing = TRUE)]

dat_combined$x <- with(dat_combined, sprintf('<tr><td>%s</td> <td>%s</td> <td><a href="%s">%s</a></td></tr>',date,caption, link,link) )

x = paste(dat_combined$x, collapse = '\n')

writeLines(c(
  '<!DOCTYPE html><html lang="en">',
  '<head>',
  '<style>
    html {
      max-width: 70ch;
      padding: 3em 1em;
      margin: auto;
      line-height: 1.75;
      font-size: 1.25em;
     }
     h1,h2,h3,h4,h5 {
     margine: 3em 0 1em;       
}
p {
margin-bottom: 3em;
}
    table,tr,th,td{
      border:1px solid black;
    }

    .table>tbody>tr>td {
    border:1px solid black;
    padding: 10px;
    }
    td, th {
    padding: 5px;
}
  </style>',
  '<title>PROMED Scanner</title>',
  '</head>',
  '<body>',
  '<h1>Overview</h1>',
  '<table>',
  '<tr><th>Date</th><th>Caption</th><th>Link</th></tr>',
  x,
  '</table>',
'</div>',
'</body>',
"<footer><br><br><br><center>",
"Last updated at:", format(Sys.time(), "%a %b %d %X %Y"),
"</center></footer>",
'</html>'
), 'docs/index.html')
