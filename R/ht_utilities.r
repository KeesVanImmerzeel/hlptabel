#' Internal function to convert GHG (m-sf) to (cm-sl) and limit value.
#'
#' @param GHG Average highest groundwater level, relative to soil surface level, (m) (numeric)
#' @return GHG (cm-sl)
.chaste_GHG <- function(GHG) {
  .chaste_GLG(GHG)
}

#' Internal function to convert GLG (m-sf) to (cm-sl) and limit value.
#'
#' @param GLG Average lowest groundwater level, relative to soil surface level, (m) (numeric)
#' @return GLG (cm-sl)
.chaste_GLG <- function(GLG) {
  max(min(GLG * 100, 999), 0)
}

#' Function to calculate the reduction in crop production caused by drought.
#' @inheritParams .chaste_GLG
#' @param x Parameters (A-E) in the analytic function to calculate the reduction in crop production caused by drought.
#' @return Reduction in crop production caused by drought (%); (numeric)
# HELP <- 15
# landuse <- 1
# x <- boot113 %>% dplyr::filter(HELPNR == HELP & as.numeric(BODEMGEBRUIK) == landuse & AARDDEPRESSIE == "Droogteschade")
# .fdr <- function(x, GLG)
.fdr <- function(x, GLG) {
  GLG %<>% .chaste_GLG()
  min(100, max(x[5] + x[1] * (1 - 1 / (1 + (
    x[2] * (max(GLG - x[3], 0.01))
  ) ^ x[4])), x[5]))
}

#' Function to calculate the reduction in crop production caused by waterlogging.
#' @inheritParams .chaste_GHG
#' @inheritParams .chaste_GLG
#' @param min_red Minimum value of the reduction in crop production caused by waterlogging (%) (numeric)
#' @param x Parameters (A-E) in the analytic function to calculate the reduction in crop production caused by waterlogging.
#' @return Reduction in crop production caused by waterlogging (%); (numeric)
.fwl <- function(x, GHG, GLG, min_red) {
  GHG %<>% .chaste_GHG()
  GLG %<>% .chaste_GLG()
  min(100, max(x[1] + x[2] * ((GHG + x[3]) ^ -x[4] + (GLG + x[3]) ^ -x[4]), min_red))
}

#' Function to calculate the total reduction in crop production caused by waterlogging and drought.
#'
#' @param red_wl Reduction in crop production caused by waterlogging (%); (numeric)
#' @param red_dr Reduction in crop production caused by drought (%); (numeric)
#' @return Total reduction in crop production caused by both waterlogging and drought (%); (numeric)
.ftot <- function(red_wl, red_dr) {
  (1 - ((100 - red_wl) / 100) * ((100 - red_dr) / 100)) * 100
}

#' Retreive tabulated values of HELP 1987 table
#' @inheritParams ht_reduction
#' @param aard Nature of the reduction in crop production ("Natschade", "Droogteschade") (character)
#' @return help_table_values (numeric vector)
.help_table_values <- function(HELP, landuse, aard) {
  if (aard == "Natschade") {
    if (landuse == 1) {
      return(HELP1987[, HELP]$grasnat)
    } else if (landuse == 2) {
      return(HELP1987[, HELP]$bouwnat)
    } else {
      return(NA)
    }
  } else if (aard == "Droogteschade") {
    if (landuse == 1) {
      return(HELP1987[, HELP]$grasdroog)
    } else if (landuse == 2) {
      return(HELP1987[, HELP]$bouwdroog)
    } else {
      return(NA)
    }
  } else {
    return(NA)
  }
}

#' Return tabulated and calculated reductions in crop production.
#'
#' @inheritParams ht_reduction
#' @inheritParams .help_table_values
#' @return Data frame with the fields:
#'   HELP: HELP (soil) number 1-70 (integer).
#'   landuse: 1=grassland; 2=arable land (numeric)
#'   aard: Nature of the reduction in crop production ("Natschade", "Droogteschade") (character)
#'   GHG: Average highest groundwater level, relative to soil surface level, (m) (numeric)
#'   GLG: Average lowest groundwater level, relative to soil surface level, (m) (numeric)
#'   red_HELP_table: Reduction in crop production in HELP 1987 table (%); (numeric)
#'   red_calculated: Calculated reduction in crop production (%); (numeric)
#' @examples
#' ht_tab_calc_values(HELP=15, landuse=1, aard="Natschade")
#' ht_tab_calc_values(HELP=15, landuse=1, aard="Droogteschade")
#' @export
ht_tab_calc_values <- function(HELP, landuse, aard) {
  df <- NA
  red_HELP_table <- .help_table_values(HELP, landuse, aard)
  GHG <- HELP1987[, HELP]$GHG / 100
  GLG <- HELP1987[, HELP]$GLG / 100
  x <-
    mapply(ht_reduction, GHG, GLG, HELP, landuse, USE.NAMES = FALSE) %>% t() %>% as.data.frame()
  if (nrow(x) > 0) {
    red_calculated <- NA
    if (aard == "Natschade") {
      red_calculated <- x$red_wl %>% unlist()
    } else if (aard == "Droogteschade") {
      red_calculated <- x$red_dr %>% unlist()
    }
    if (length(red_calculated) > 0) {
      df <- data.frame(HELP, landuse, aard, GHG, GLG, red_HELP_table, red_calculated)
    }
  }
  return(df)
}

#' Return plot of tabulated and calculated reductions in crop production.
#'
#' @inheritParams ht_reduction
#' @inheritParams .help_table_values
#' @return plot with tabulated and calculated reductions in crop production.
#' @examples
#' ht_plot_tab_calc_values(HELP=15, landuse=1)
#' ht_plot_tab_calc_values(HELP=15, landuse=1)
#' @export
ht_plot_tab_calc_values <- function(HELP, landuse) {
  red_dr <- ht_tab_calc_values(HELP, landuse, aard = "Droogteschade")
  red_wl <- ht_tab_calc_values(HELP, landuse, aard = "Natschade")
  df <-
    rbind(red_dr, red_wl) %>% dplyr::select(c("aard", "red_HELP_table", "red_calculated"))
  title <-
    paste(
      landuse_str[landuse],
      "HELP nummer =",
      as.character(HELP),
      "( HELP code", ht_HELPnr_to_HELPcode(HELP), ")")
  f <- ggplot2::ggplot(df,
                       ggplot2::aes(x = red_HELP_table,
                                    y = red_calculated,
                                    color = aard)) +
    ggplot2::geom_abline(intercept = 0,
                         slope = 1,
                         linetype = "dashed") +
    ggplot2::geom_point(size = 3) +
    ggplot2::theme(legend.title = ggplot2::element_blank()) +
    ggplot2::labs(x = "Reductie (HELP1987 tabel, %)", y = "Reductie (Berekend, %)") +
    ggplot2::ggtitle(title) +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))
  return(f)
}

#' Calulate the root-mean-square error in the relation between the tabulated HELP1987 values and the calculated values
#' of the reduction in crop production caused by waterlogging.
#'
#' @inheritParams ht_reduction
#' @inheritParams .fwl
#' @return Root-mean-square error (numeric)
# HELP <- 15
# landuse <- 1
# x <- boot113 %>% dplyr::filter(HELPNR == HELP & as.numeric(BODEMGEBRUIK) == landuse & AARDDEPRESSIE == "Natschade")
# .rmse_wl(x[,1:5], HELP, landuse)
.rmse_wl <- function(x, HELP, landuse) {
  red_wl <- .help_table_values(HELP, landuse, aard = "Natschade")
  if (!all(is.na(red_wl))) {
    res <-
      mapply(
        .fwl,
        GHG = HELP1987[, HELP]$GHG / 100,
        GLG = HELP1987[, HELP]$GLG / 100,
        min_red = min(red_wl, na.rm = TRUE),
        MoreArgs = list(x = x),
        SIMPLIFY = TRUE,
        USE.NAMES = FALSE
      )
    df <- data.frame(x = red_wl, y = res) %>% na.omit()
    if (nrow(df) > 5) {
      return(sqrt(sum((df$x - df$y) ^ 2) / nrow(df)))
    } else {
      return(NA)
    }
  } else {
    return(NA)
  }
}

#' Calulate the root-mean-square error in the relation between the tabulated HELP1987 values and calculated values
#' of reduction in crop production caused drought.
#'
#' The residual standard error is the positive square root of the mean square error.
#'
#' @inheritParams ht_reduction
#' @inheritParams .fdr
#' @return Root-mean-square error (numeric)
#  HELP <- 15
#  landuse <- 1
#  x <- boot113 %>% dplyr::filter(HELPNR == HELP & as.numeric(BODEMGEBRUIK) == landuse & AARDDEPRESSIE == "Droogteschade")
#  rmse_dr(x[,1:5], HELP, landuse)
.rmse_dr <- function(x, HELP, landuse) {
  red_dr <- .help_table_values(HELP, landuse, aard = "Droogteschade")
  if (!all(is.na(red_dr))) {
    res <-
      mapply(
        .fdr,
        GLG = HELP1987[, HELP]$GLG / 100,
        MoreArgs = list(x = x),
        SIMPLIFY = TRUE,
        USE.NAMES = FALSE
      )
    df <- data.frame(x = red_dr, y = res) %>% na.omit()
    if (nrow(df) > 5) {
      return(sqrt(sum((df$x - df$y) ^ 2) / nrow(df)))
    } else {
      return(NA)
    }
  } else {
    return(NA)
  }
}

#' Calculate reduction in crop production caused by waterlogging and drought.
#'
#' @inheritParams .chaste_GHG
#' @inheritParams .chaste_GLG
#' @param HELP HELP (soil) number 1-70 (integer).
#' @param landuse 1=grassland; 2=arable land (integer)
#' @return Calculated reduction in crop production (list) with three elements:
#'         red_wl: caused by waterlogging (%); (numeric)
#'         red_dr: caused by drought (%); (numeric)
#'         red_tot: (%) (numeric)
#' @examples
#' GHG <- 0.25
#' GLG <- 1.4
#' HELP <- 15
#' landuse <- 1
#' ht_reduction( GHG, GLG, HELP, landuse )
#' @export
ht_reduction <- function(GHG, GLG, HELP, landuse) {
  res <- list(red_dr=NA,red_wl=NA,red_tot=NA)
  if (is.na(GHG)|is.na(GLG)|is.na(HELP)|is.na(landuse)) {
    return(res)
  }
  x <-
    boot113 %>% dplyr::filter(HELPNR == HELP &
                                as.numeric(BODEMGEBRUIK) == landuse) %>% dplyr::arrange(dplyr::desc(AARDDEPRESSIE))
  x <- cbind(x$A, x$B, x$C, x$D, x$E)
  if (nrow(x) > 0) {
    if (GHG < GLG) {
      res <- list()
      res$red_wl <-
        .fwl(x[2,], GHG, GLG, min_red = x[2,5])
      res$red_dr <- .fdr(x[1,], GLG)
      res$red_tot <- .ftot(res$red_wl, res$red_dr)
    }
  }
  return(res)
}

#' Helper function for function '.ht_reduction_brk()'.
#' @param x Numeric vector with four elements:
#' \describe{
#'   \item{GHG}{Average highest groundwater level, relative to soil surface level (m)}
#'   \item{GLG}{Average lowest groundwater level, relative to soil surface level (m)}
#'   \item{HELP}{(soil) number 1-70}
#'   \item{landuse}{ 1=grassland; 2=arable land}
#' }
#' @return Numeric vector with reduction in crop production:
#' \describe{
#'   \item{1}{due to waterlogging (%)}
#'   \item{2}{due to drought (%)}
#'   \item{3}{total (%)}
#' }
# @examples
# x <- c(0.25,1.4,15,1)
# .f(x)
.f <- function(x){
  res <- ht_reduction(GHG=x[1], GLG=x[2], HELP=x[3], landuse=x[4])
  return(c(res$red_wl,res$red_dr,res$red_tot))
}

#' Calculate reduction in crop production caused by waterlogging and drought using a RasterBrick object as input.
#'
#' @param x A RasterBrick object with the following Raster layers (in this order):
#' \describe{
#'   \item{GHG}{Average highest groundwater level, relative to soil surface level (m)}
#'   \item{GLG}{Average lowest groundwater level, relative to soil surface level (m)}
#'   \item{HELP}{(soil) number 1-70}
#'   \item{landuse}{ 1=grassland; 2=arable land}
#' }
#' @return A RasterBrick object with the following Raster layers:
#' \describe{
#'   \item{wl}{Reduction in crop production caused by waterlogging (%)}
#'   \item{dr}{Reduction in crop production caused by drought (%)}
#'   \item{tot}{Total reduction in crop production caused by both waterlogging and drought (%)}
#'   \item{landuse}{ 1=grassland; 2=arable land}
#' }
#' @details This is the single-core version of the function 'ht_reduction_brk()'.
# @examples
#' x <- raster::brick(system.file("extdata","example_brick.grd",package="hlptabel"))
#' r <- .ht_reduction_brk(x)
.ht_reduction_brk <- function(x){
  res <- x %>% raster::calc( .f  )
  names(res) <- c("wl","dr","tot")
  return(res)
}

#' Calculate reduction in crop production caused by waterlogging and drought using a RasterBrick object as input.
#'
#' @inherit .ht_reduction_brk
#' @details Muliple-cores are used to compute the results.
#' @examples
#' x <- raster::brick(system.file("extdata","example_brick.grd",package="hlptabel"))
#' r <- ht_reduction_brk(x)
#' @export
ht_reduction_brk <- function(x) {
  raster::beginCluster()
  res <- raster::clusterR(x, .ht_reduction_brk)
  raster::endCluster()
  names(res) <- c("wl", "dr", "tot")
  return(res)
}

#' Get HELP number by specifying a bofek number.
#'
#' @param bofek Bofek number(integer).
#' @return HELP HELP (soil) number 1-70 (integer).
#' @examples
#' ht_bofek_to_HELPnr( 101 )
#' @export
ht_bofek_to_HELPnr <- function(bofek) {
  res <- NA
  x <- bofek_help %>% dplyr::filter(BOFEK == bofek)
  if (nrow(x) > 0) {
    res <- x$HELPNR
  }
  return(res)
}

#' Get HELP number by specifying a soil number (1010, ..., 22020).
#'
#' @param soilnr Soil number (1010, ..., 22020) (integer).
#' @return HELP HELP (soil) number 1-70 (integer).
#' @examples
#' ht_soilnr_to_HELPnr( 1030 )
#' @export
ht_soilnr_to_HELPnr <- function(soilnr) {
  res <- NA
  x <- bodem_help %>% dplyr::filter(BODEMNR == soilnr & HELPNR <= max_HELP_nr)
  if (nrow(x) > 0) {
    res <- x$HELPNR
  }
  return(res)
}

#' Get HELP number by specifying a soil unit ("soil_unit").
#'
#' @param soil_unit Soil unit (character).
#' @return HELP HELP (soil) number 1-70 (integer).
#' @examples
#' ht_soil_unit_to_HELPnr( "faVzt" )
#' @export
ht_soil_unit_to_HELPnr <- function(soil_unit) {
  res <- NA
  x <- bofek_help %>% dplyr::filter(EENHEID == soil_unit & HELPNR <= max_HELP_nr)
  if (nrow(x) > 0) {
    res <- x$HELPNR
  }
  return(res)
}

#' Get HELP (soil) code by specifying HELP number.
#'
#' @inheritParams ht_reduction
#' @return HELPcode (character).
#' @examples
#' ht_HELPnr_to_HELPcode( HELP=15 )
#' @export
ht_HELPnr_to_HELPcode <- function(HELP) {
  res <- NA
  x <- boot113 %>% dplyr::filter(HELPNR == HELP)
  if (nrow(x) > 0) {
    res <- x$HELPCODE[1] %>% as.character()
  }
  return(res)
}

#' Valid soil units.
#'
#' @return soil units (character vector)
#' @examples
#' ht_soil_units()
#' @export
ht_soil_units <- function() {
  unique(bofek_help$EENHEID)
}

#' Valid bofek numbers.
#'
#' @return bofek (integer)
#' @examples
#' ht_bofek_numbers()
#' @export
ht_bofek_numbers <- function() {
  unique(bofek_help$BOFEK)
}



