setwd("~/myR_on_GitHub/packages/hlptabel/data-raw/Validate")
library(dplyr)
library(magrittr)
library(readxl)
library(hlptabel)
library(metrica)
library(ggplot2)

## Read original HELP tables 1987
f <- function(HELPNR) {
  x <- readxl::read_excel(path = "../help-tabellen 1987.xlsx",
                          sheet = as.character(HELPNR),
                          range = "A2:F16") %>% as.data.frame()
  names(x) <- c("GHG","GLG","grasnat","grasdroog","bouwnat","bouwdroog")
  return(x)
}
HELP1987 <- sapply(1:70,f)
v_ht_reduction <- Vectorize(hlptabel::ht_reduction)

get_2_samples_HELP1987 <-
  function(HELPNR, x = HELP1987, selection = "grasnat") {
    x <- x[, HELPNR] %>% as.data.frame()
    x %<>% dplyr::select(GHG, GLG, selection) %>% na.omit()
    x$id <- x %>% row.names() %>% as.numeric()
    i <- sample(1:nrow(x), 2, replace = FALSE)
    x <- x[i,]
    x %<>% dplyr::arrange(id) %>% dplyr::select(-id) %>% dplyr::mutate(GHG=GHG/100,GLG=GLG/100)
    return(x)
  }
get_validation_point <- function( x = HELP1987, selection = "grasnat"  ) {
  HELPNR <- sample(1:ncol(HELP1987), 1)
  x <- get_2_samples_HELP1987(HELPNR, x=HELP1987, selection )
  dif_x <- x[2,3] -  x[1,3]

  if (startsWith(selection, "gras")) {
    landuse <- 1
  } else {
    landuse <- 2
  }
  y <- v_ht_reduction(x$GHG,x$GLG,HELPNR,landuse)
  if (endsWith(selection, "nat")) {
    rownr <- 1
  } else {
    rownr <- 2
  }
  y <- unlist(y[rownr,])
  dif_y <- y[2] - y[1]
  c(dif_x, dif_y)
}

se <- function(x) {sqrt(var(x, na.rm=TRUE)/length(x))}
standard_error <- function(x) sd(x) / sqrt(length(x))

validate <- function(selection="grasnat", n=100){
  print("############")

  print(selection)
  print(paste("n=",n))

  x <-apply(as.array(1:n), MARGIN=1,get_validation_point, selection = "grasnat", simplify = TRUE) %>% unlist() %>% t()
  df <- data.frame( observed=x[,1], predicted=x[,2])
  df %<>% na.omit()

  observed  <- df$observed
  predicted <- df$predicted

  paste0(selection,".png")
  ggp <- ggplot(df, aes(observed, predicted)) +    # Draw data without line
    geom_point() + geom_abline(intercept = 0,
                               slope = 1) +
    xlab("Verandering bepaald met HELP-tabel (%)") +
    ylab("Verandering bepaald met HELP-formules (%)")
  ggsave(filename=paste0(selection,".png"), plot=ggp)

  #fit <- lm(predicted~observed)
  #summary <- summary(fit)
  #print(summary)

  x <- observed - predicted

  cat("Root Mean Square Error (RMSE):", sqrt(mean((observed - predicted)^2)), "\n")

  # Standaarddeviatie = de toevallige component van RMSE:
  cat("Random Error Component (REC) = standaarddeviatie", sd(x), "\n")

  cat("Systematic Error Component (SEC) = het gemiddelde verschil:", mean(x), "\n")
}

###################

sink("validate.log")

n <- 1000
validate(selection="grasnat", n)
validate(selection="grasdroog", n)
validate(selection="bouwnat", n)
validate(selection="bouwdroog", n)

