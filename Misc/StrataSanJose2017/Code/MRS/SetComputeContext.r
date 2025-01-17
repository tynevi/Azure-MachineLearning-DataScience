isLinux <- Sys.info()["sysname"] == "Linux"

useHDFS <- isLinux
useRxSpark <- isLinux

if(useHDFS) {

  ################################################
  # Use Hadoop-compatible Distributed File System
  ################################################
  
  rxOptions(fileSystem = RxHdfsFileSystem())
  
  dataDir <- "/HdiSamples/HdiSamples/FlightDelay"
  
  ################################################

  if(rxOptions()$hdfsHost == "default") {
    fullDataDir <- dataDir
  } else {
    fullDataDir <- paste0(rxOptions()$hdfsHost, dataDir)
  }  
} else {
  
  ################################################
  # Use Native, Local File System
  ################################################

  rxOptions(fileSystem = RxNativeFileSystem())
  
  dataDir <- file.path(getwd(), "delayDataLarge")
  
  ################################################
}

if(useRxSpark) {
  
  ################################################
  # Distributed computing using Spark
  ################################################

  computeContext <- RxSpark(consoleOutput=TRUE, numExecutors = 1, executorCores=2, executorMem="1g")
  
  ################################################

} else {
  
  ################################################
  # Single-node Computing
  ################################################

  computeContext <- RxLocalSeq()
  
  ################################################
}

rxSetComputeContext(computeContext)


if(Sys.getenv("R_ZIPCMD")=="")
{
  Sys.setenv(R_ZIPCMD="zip") # needed by AzureML::publishWebService
}


rxRoc <- function(...){
  rxSetComputeContext(RxLocalSeq())

  roc <- RevoScaleR::rxRoc(...)

  rxSetComputeContext(computeContext)

  return(roc)
}
