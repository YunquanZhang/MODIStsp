#' @title Reproject a bounding box
#' @description
#'  Helper function used to reproject bounding boxes; setting the parameter
#'  'enlarge' allows to choose if the new one would be the one which completely
#'  includes the original extent in the output projection, or if is simply the
#'  one obtained by reprojecting the upper-left and the lower-right corners.
#' @param bbox The input bounding box (it can be a matrix obtained from `sp::bbox()`,
#'  or a numeric vector in the format (xmin, ymin, xmax, ymax)).
#' @param in_proj `character` The input projection (proj4 format).
#' @param out_proj `character` The output projection (proj4 format).
#' @param enlarge `logical`` if TRUE, the reprojected bounding box is the
#'  one which completely include the original one; if FALSE, it is simply the
#'  one obtained by reprojecting the upper-left and the lower-right corners.
#' @author Luigi Ranghetti, phD (2015) \email{ranghetti.l@@irea.cnr.it}
#' @note License: GPL 3.0
#' @importFrom sp bbox CRS Polygon Polygons proj4string SpatialPoints
#'  SpatialPolygons spTransform

reproj_bbox <- function(bbox, in_proj, out_proj, enlarge=TRUE) {


  if (!any(is.na(bbox))) {
  # densify the original bounding box
  N_dens <- ifelse(enlarge, 1000, 1)

  d_bbox_in <- data.frame(
    lon = as.numeric(c(bbox[1] + diff(bbox[c(1, 3)]) * (0:N_dens) / N_dens,
            rep(bbox[3], N_dens - 1),
            bbox[1] + diff(bbox[c(1, 3)]) * (N_dens:0) / N_dens,
            rep(bbox[1], N_dens - 1))),
    lat = as.numeric(c(rep(bbox[2], N_dens),
            bbox[2] + diff(bbox[c(2, 4)]) * (0:N_dens) / N_dens,
            rep(bbox[4], N_dens - 1),
            bbox[2] + diff(bbox[c(2, 4)]) * (N_dens:1) / N_dens)),
    stringsAsFactors = FALSE
  )

  d_bbox_in <- as.matrix(d_bbox_in)

  # convert in a SpatialPolygons
  d_bbox_in <- sp::SpatialPolygons(
    list(sp::Polygons(list(sp::Polygon(d_bbox_in)), 1))
  )
  sp::proj4string(d_bbox_in) <- in_proj # assign the projection
  # reproject the bbox in a polygon
  d_bbox_out <- sp::spTransform(d_bbox_in, sp::CRS(out_proj))

  return(sp::bbox(d_bbox_out))
  } else {
    return(bbox)
  }
}
