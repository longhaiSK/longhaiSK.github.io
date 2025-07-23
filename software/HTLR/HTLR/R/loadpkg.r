.First.lib <- function(lib,pkg)
{
   library (BCBCSF)
   library (scatterplot3d)
   library (abind)
   library.dynam("HTLR",pkg,lib)
   cat(sprintf("Package 'HTLR' loaded. \n"))
   
}

.Last.lib <- function(libpath)
{
   library.dynam.unload("HTLR",libpath)
   cat(sprintf("Package 'HTLR' unloaded. \n"))
}



