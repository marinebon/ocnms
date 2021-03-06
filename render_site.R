library(rmarkdown)
library(here)
library(readr)
library(fs)
library(purrr)

# parameters
csv         <- here("svg/svg_links_ocnms.csv")
redo_modals <- F

# read in links for svg
d <- read_csv(csv)

render_page <- function(rmd){
  render(rmd, html_document(
    theme = site_config()$output$html_document$theme, 
    self_contained=F, lib_dir = here("modals/modal_libs"), 
    mathjax = NULL))
}

render_modal <- function(rmd){
  rmds_theme_white <- c("")
  
  site_theme <- site_config()$output$html_document$theme
  rmd_theme  <- ifelse(input %in% rmds_theme_white, "cosmo", site_theme)
  
  render(rmd, html_document(
    theme = site_config()$output$html_document$theme, 
    self_contained=F, lib_dir = here("modals/modal_libs"), 
    mathjax = NULL))
  
  htm <- fs::path_ext_set(rmd, "html")
  docs_htm <- glue("docs/{htm}")
  docs_rmd <- glue("docs/{rmd}")
  file.copy(rmd, docs_rmd, overwrite = T)
  file.copy(htm, docs_htm, overwrite = T)
}

# render_modal("modals/algal-groups.Rmd")
# render_modal("modals/barnacles.Rmd")
# render_modal("modals/mussels.Rmd")

# create/render modals by iterating over svg links in csv ----
for (i in 1:nrow(d)){ # i=1
  # paths
  htm <- d$link[i]
  rmd <- path_ext_set(htm, "Rmd")
  
  # create Rmd, if doesn't exist
  if (!file.exists(rmd)) file.create(rmd)
  
  # render Rmd to html, if Rmd newer or redoing
  if (file.exists(htm)){
    rmd_newer <- file_info(rmd)$modification_time > file_info(htm)$modification_time
  } else {
    rmd_newer <- T
  }
  if (rmd_newer | redo_modals){
    render_modal(rmd)
  }
}

# render website, ie Rmds in root ----
walk(list.files(".", "*\\.md$"), render_page)
walk(
  list.files(".", "*\\.html$"), 
  function(x) file.copy(x, file.path("docs", x)))
render_site()

fs::file_touch("docs/.nojekyll")

# shortcuts w/out full render:
# file.copy("libs", "docs", recursive=T)
# file.copy("svg", "docs", recursive=T)
# file.copy("modals", "docs", recursive=T)
