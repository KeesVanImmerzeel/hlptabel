library(devtools)
devtools::load_all()

library(dplyr)
library(magrittr)
library(stringr)
library(readxl)

## Read original HELP tables 1987
f <- function(HELPNR) {
  x <- readxl::read_excel(path = "help-tabellen 1987.xlsx",
                          sheet = as.character(HELPNR),
                          range = "A2:F16") %>% as.data.frame()
  names(x) <- c("GHG","GLG","grasnat","grasdroog","bouwnat","bouwdroog")
  return(x)
}
HELP1987 <- sapply(1:70,f)
#HELPNR <- 15
#HELP1987[,HELPNR]

## prepare internal `boot113` dataset with parameters A-E
fname <- "Boot113.EP0"
x <-
  readLines(fname) %>%  grep("\t", ., value = TRUE) %>% stringr::str_split_fixed("\t", 8) %>% as.data.frame()
xn <- x[, 1:7]
xn <- sapply(xn, as.numeric)
xn[xn == -1] <- NA
x[, 1:7] <- xn
x[, 8] <- sapply(x[, 8], as.factor) # HELP-code
x$V9  <- c(rep(c(rep(1, 70), rep(0, 70)), 2)) %>% as.character()
x$V9[x$V9 == "0"] <- "Bouwland"
x$V9[x$V9 == "1"] <- "Grasland"
x$V9 %<>% as.factor() %>% relevel("Grasland") # Make "Grasland" first
x$V10 <-
  c(rep(1, 140), rep(0, 140)) %>% as.character() # Nat of droogteschade; 0=Droogteschade 1=Natschade
x$V10[x$V10 == "0"] <- "Droogteschade"
x$V10[x$V10 == "1"] <- "Natschade"
x$V10 %<>% as.factor() %>% relevel("Natschade") # Make "Natschade" first
x$ID <- 1:nrow(x)
names(x) <-
  c("A",
    "B",
    "C",
    "D",
    "E",
    "SE",
    "HELPNR",
    "HELPCODE",
    "BODEMGEBRUIK",
    "AARDDEPRESSIE",
    "ID")
boot113 <- x

## Define global variables with fieldnames in data frame "boot113"
## in order to prevent the note "no visible binding for global variable"
## in the output of devtools::check(document = FALSE)
HELPNR <- 1
BODEMGEBRUIK <- "Grasland"
AARDDEPRESSIE <- "Natschade"

## Translation of Bofek codes to HELP number
bofek_help <- read.csv2("data-raw/Bofek2020/BOFEK2020_HELP.csv",sep=",")
names(bofek_help) <- c("BOFEK", "HELP")

## Read soil descriptions ("EENHEID") corresponding to Bofek codes ("BOFEK")
df <- readxl::read_excel(path = "BOFEK2012_profielen_versie2_1.xlsx",
                        sheet = "Dominant profiel",
                        range = "A1:D308") %>% as.data.frame()

## Add soil descriptions ("EENHEID") to table "bofek_help"
x <- data.frame(BOFEK=df$BOFEK2012,EENHEID=df$Eenheid) %>% dplyr::distinct()
bofek_help %<>% dplyr::left_join(x)

## Add soil number ("BODEMNR") table "bofek_help".
# Fields in "bofek_help" (72 rows):
#  - BOFEK_NHI: 1-72 Codering volgens NHI/LHM
#  - BOFEK: 101-507 BOFEK codes
#  - HELPNR: 4-68 (niet alle HELP nummers 1-72 komen voor, m.a.w. niet alle HELP tabellen worden door het NHI gebruikt
#      voor het berekenen van landbouwschade)
#  - EENHEID: bodemeenheid ("hVc" etc)
#  - BODEMNR (1050, ..., 18050)
x <- data.frame(BOFEK=df$BOFEK2012,BODEMNR=df$Bodemnr) %>% dplyr::distinct()
bofek_help %<>% dplyr::left_join(x)

# Create table "bodem_help"
# (Used for translation from "BODEMNR" (1010, ..., 22020) to HELP number 1-72)
# Fields in "bodem_help" (370 rows):
# - BODEMNR (1010, ..., 22020)
# - HELPNR (1-72)
# - EENHEID: bodemeenheid ("hVc" etc)
x1 <- read.csv2("wur/BODEM_Eenheid_654.csv",sep=",")
x2 <- read.csv2("wur/BODEM_HELP.csv",sep=",") # niet alle HELP nummers komen in de tabel voor (dwz zijn gekoppeld aan een bodem)
bodem_help <- x1 %>% dplyr::inner_join(x2, by="ID")
remove_trailing_letter <- function(x) {
  gsub("(_[A-Z]$)|(_[a-z]$)","",x)
}
bodem_help$BODEMNR <- remove_trailing_letter(bodem_help$ABGN) %>% as.numeric()
bodem_help %<>% dplyr::select(-c(ABGN,KLEUR,ID))

## Define global variables with fieldnames in data frame "bofek_help"
## in order to prevent the note "no visible binding for global variable"
## in the output of devtools::check(document = FALSE)
BOFEK <- 101
EENHEID <- "hVc"

## Define usefull constants
max_HELP_nr <- 70

# Optimize, for all soil / landuse combinations, the parameters of the functions to calculate the reduction of
# crop production due to water logging or drought.
# Initial values are stored in data frame "boot113".

# @param aard Nature of the reduction in crop production ("Natschade", "Droogteschade") (character)
optim_pars <- function(x, aard) {
  HELP <- x[1]
  landuse <- x[2]
  # HELP <- 15
  # landuse <- 1
  # aard <- "Natschade"
  x <-
    boot113 %>% dplyr::filter(HELPNR == HELP &
                                as.numeric(BODEMGEBRUIK) == landuse &
                                AARDDEPRESSIE == aard)
  ID <- x$ID
  print(ID)
  if (aard == "Droogteschade") {
    fRSE <-
      getFunction(".rmse_dr")
    x <- x[, 1:5]
  } else {
    fRSE <- getFunction(".rmse_wl")
    x <- x[, 1:4]
  }
  if (!is.na(fRSE(x, HELP, landuse))) {
    psc <- # Scale of parameters
      c(
        median(boot113$A, na.rm = TRUE),
        median(boot113$B, na.rm = TRUE),
        median(boot113$C, na.rm = TRUE),
        median(boot113$D, na.rm = TRUE)
      )
    if (aard == "Droogteschade") {
      psc <- c(psc,median(boot113$E, na.rm = TRUE))
    }
    opt_res <-
      optim(
        x,
        fRSE,
        HELP = HELP,
        landuse = landuse,
        control = list(parscale = psc)
      )
    rmse <- fRSE(opt_res$par, HELP = HELP, landuse = landuse)
    if (aard == "Droogteschade") {
      res <- c(opt_res$par, rmse, ID)
    } else {
     help_table_values <- .help_table_values (HELP, landuse, aard)
     res <- c(opt_res$par, min(help_table_values, na.rm=TRUE), rmse, ID)
    }
    names(res) <- c("A", "B", "C", "D", "E", "RMSE", "ID")
    return(res)
  } else {
    return(c(NA, NA, NA, NA, NA, NA, ID))
  }
}
df <-
  data.frame(HELP = rep(1:70, 2), landuse = c(rep(1, 70), rep(2, 70)))
x_wl <-
  apply(df, MARGIN = 1, optim_pars, aard = "Natschade") %>% t() %>% as.data.frame()
s <- c("A", "B", "C", "D", "E", "RMSE", "ID")
names(x_wl) <- s
x_wl %<>% dplyr::arrange(ID)
max_err_wl <- max(x_wl$RMSE,na.rm=TRUE)
i_max_wl <- which(x_wl$RMSE == max_err_wl)
# .rmse_wl(x=boot113[15,],HELP=15,landuse=1)
# .rmse_wl(x=x_wl[15,],HELP=15,landuse=1)

x_dr <-
  apply(df, MARGIN = 1, optim_pars, aard = "Droogteschade") %>% t() %>% as.data.frame()
names(x_dr) <- s
x_dr %<>% dplyr::arrange(ID)
max_err_dr <- max(x_dr$RMSE,na.rm=TRUE)
i_max_dr <- which(x_dr$RMSE == max_err_dr)
# .rmse_dr(x=boot113[155,],HELP=15,landuse=1)
# .rmse_dr(x=x_dr[15,],HELP=15,landuse=1)

# Replace original parameter values in table boot113 by optimized values
tmp <- boot113 %>% dplyr::select("HELPNR","HELPCODE","BODEMGEBRUIK", "AARDDEPRESSIE","ID")
boot113 <- dplyr::inner_join(tmp,rbind(x_wl,x_dr),by="ID") %>% dplyr::arrange(ID)

hist(boot113$RMSE[1:140], main="RMSE waterlogging", xlab="RMSE", ylab="Frequency")
hist(boot113$RMSE[141:280], main="RMSE drought", xlab="RMSE", ylab="Frequency")

# Labels
landuse_str <- c("Grasland","Bouwland")
aard_str <- c("Natschade","Droogteschade")

## Prepare check objects chk_red_gras and chk_red_bouw for function ht_reduction()
chk_red_gras <-
  ht_reduction(
    HELP = 15,
    landuse = 1,
    GHG = 0.25,
    GLG = 1.4
  )
landuse <- 2
chk_red_bouw <-
  ht_reduction(
    HELP = 15,
    landuse = 2,
    GHG = 0.25,
    GLG = 1.4
  )

## Prepare check objects chk_red_brk for function ht_reduction_brk()
## Remark: INSTALL THIS PACKAGE FIRST so that the different processes in the multicore
## application use the latest version.
x <- raster::brick(system.file("extdata","example_brick.grd",package="hlptabel"))
chk_red_brk <- ht_reduction_brk(x)

## Save internal objects to file "R/sysdata.rda so that the correct check objects are stored."
usethis::use_data(
  HELP1987,
  boot113,
  HELPNR,
  BODEMGEBRUIK,
  AARDDEPRESSIE,

  bofek_help,
  bodem_help,
  BOFEK,
  EENHEID,
  max_HELP_nr,

  landuse_str,
  aard_str,

  chk_red_gras,
  chk_red_bouw,
  chk_red_brk,

  overwrite = TRUE,
  internal = TRUE
)

