# Clean Data - Project
library(reshape2)

# Download zipped file
URL <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
zipfile <- paste0(getwd(), '/getdata-projectfiles-UCI-HAR-Dataset.zip')
download.file(URL, destfile=zipfile)
cat('Downloaded "', zipfile, '"\n',sep='')
rm(URL)

# Unzip file
unzip(zipfile); file.remove(zipfile)
ifelse('UCI HAR Dataset' %in% dir(), 'File has unzip', stop('Folder not exist!'))
rm(zipfile)

# Read features and labels
txtfile <- dir('UCI HAR Dataset')[substr(dir('UCI HAR Dataset'),nchar(dir('UCI HAR Dataset'))-3,nchar(dir('UCI HAR Dataset')))=='.txt'][1:2]
subfold <- dir('UCI HAR Dataset')[substr(dir('UCI HAR Dataset'),nchar(dir('UCI HAR Dataset'))-3,nchar(dir('UCI HAR Dataset')))!='.txt']
labels <- lapply(as.list(txtfile), function(x) read.table(paste0(getwd(),'/UCI HAR Dataset/',x), col.names=c('Code','Label')))
names(labels) <- substr(txtfile,1,nchar(txtfile)-4)
labels$filtered_features <- labels$features[grep("mean\\(|std\\(", labels$features[,2]),]

# Read train and test files
txtfile <- lapply(as.list(subfold), function(x) dir(paste0('UCI HAR Dataset/',x))[-1])
names(txtfile) <- subfold
dat <- lapply(as.list(subfold),function(x) lapply(txtfile, function(y) paste0(getwd(),'/UCI HAR Dataset/',x,'/',y))[[x]])
names(dat) <- subfold

dat2 <- lapply(seq(dat),function(i) lapply(seq(dat[[i]]), function(j) read.table(dat[[i]][j])))
names(dat2) <- subfold
dat2names <- lapply(txtfile, function(x) substr(x, 1, nchar(x)-4))
nms <- list('Subject', as.character(labels$features[,2]), 'Code')
nms <- list(nms,nms)
for(i in seq(dat2)){
  for(j in seq(dat2[[i]])){
    names(dat2[[i]]) <- dat2names[[i]]
    names(dat2[[i]][[j]]) <- nms[[i]][[j]] }
  dat2[[i]][[2]] <- dat2[[i]][[2]][as.character(labels$filtered_features[,2])]
}; rm(i, j, subfold, txtfile, dat, dat2names, nms)

for(i in seq(dat2)){
  df <- cbind(dat2[[i]][[1]],dat2[[i]][[3]],dat2[[i]][[2]])
}; rm(i, dat2)

# Merge the datasets
cat('Merging datasets to be one dataset.\n')
dfm = merge(labels$activity_labels, df, by.x='Code', by.y='Code')
dfm <- dfm[,-1]; rm(labels, df)

# Reshape the dataset
cat('Melting dataset.\n')
long_data <- melt(df, id = c("Label", "Subject"))
cat('Dcasting dataset.\n')
wide_data <- dcast(long_data, Label + Subject ~ variable, mean)

# Save dataset
cat('Saving dataset.\n')
write.table(wide_data, file="tidydata.txt", quote=FALSE, row.names=FALSE)
