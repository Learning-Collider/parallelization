library(parallel)
library(dplyr)

# Detect the number of available cores and create cluster
cores <- detectCores()
cl <- parallel::makeCluster(cores)

# Run parallel computation
time_parallel <- system.time(
  parallel::parLapply(cl,
                      mtcars$mpg,
                      mean)
)

# Across columns
parSapply(cl,
          mtcars,
          mean)

# User-defined
times_two <- function(x){
  return(x*2)
}

parSapply(cl,
          mtcars,
          times_two)

# Split dataset into chunks and recalculate
calc_list<-list(mtcars[1:8,1], mtcars[9:16,1], mtcars[17:24,1], mtcars[25:32,1])


parSapply(cl,
          calc_list,
          mean)

#parallelize user defined functions
split_func <- function(x){
  return(mtcars[(x):(x+7), 1])
}

exec_list <- list(1, 9, 17, 25)

parLapply(cl,
          exec_list,
          split_func
          )

#SQL example
#Using RJDBC library
require(RJDBC)

options(java.parameters = "-Xmx4096m")
drv <- JDBC("com.microsoft.sqlserver.jdbc.SQLServerDriver","/sqljdbc4.jar",identifier.quote = "`")
connectionString <- paste0("DATABASE_CONNECTION_HERE")
connection <- dbConnect(drv,connectionString, "USERNAME", "PASSWORD")

split_func_sql <- function(x){
  query <- paste("select * from tablename order by columnname offset", x,
                 "rows fetch next 1000000 rows only")
  return(dbGetQuery(connection, query))
}

# Fetch in chunks of 1m rows
exec_list_sql <- list(0, 1000000, 2000000, 3000000)

parLapply(cl,
          exec_list_sql,
          split_func_sql
)

# Close cluster
parallel::stopCluster(cl)
