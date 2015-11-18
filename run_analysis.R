#Check whether data exists. If not, download data.
if(!file.exists("./wearable.zip")){
    url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(url, destfile = "wearable.zip")
    dateDownloaded <- date() 
}
#check whether unzipped data folder exists. If not, unzip the data.
if(!file.exists("./UCI HAR Dataset")){
    unzip("./wearable.zip")
}

#load activity labels and features;  transform them[the second colomn] from factor to character
features <- read.table("./UCI HAR Dataset/features.txt")
features$V2 <- as.character(features$V2)
activity.labels <- read.table("./UCI HAR Dataset/activity_labels.txt")
activity.labels$V2 <- as.character(activity.labels$V2)

#Get the measurements on the mean and standard deviation for each measurement.[for requirement 2]
feature.mean.std <- grepl(".*[Mm][Ee][Aa][Nn].*|.*[Ss][Tt][Dd].*", features[,2])
feature.names <- features[feature.mean.std,][,2]

#load files needed: train and test data [for requirement 2]
Datatrain.x <- read.table("./UCI HAR Dataset/train/X_train.txt")[feature.mean.std]
Datatrain.y <- read.table("./UCI HAR Dataset/train/y_train.txt")
Datatrain.subjects <- read.table("./UCI HAR Dataset/train/subject_train.txt")
train <- cbind(Datatrain.subjects,Datatrain.x,Datatrain.y)

Datatest.x <- read.table("./UCI HAR Dataset/test/X_test.txt")[feature.mean.std]
Datatest.y <- read.table("./UCI HAR Dataset/test/y_test.txt")
Datatest.subjects <- read.table("./UCI HAR Dataset/test/subject_test.txt")
test <- cbind(Datatest.subjects,Datatest.x,Datatest.y)

#merge the train and test data; and add the right colomn names for each colomn.[for requirement 1&4]
Data.wearable <- rbind(train,test)
colnames(Data.wearable) <- c("subjects", feature.names, "activity")

#Label the activity with the exact description[For requirement 3]
Data.wearable$activity <- factor(Data.wearable$activity, levels = activity.labels[,1], labels = activity.labels[,2])

# creates an independent tidy data set with the average of each variable for each activity and each subject.
library(reshape2)
Data.melted <- melt(Data.wearable, id = c("subjects", "activity"))
Data.melted.mean <- dcast(Data.melted, subjects+activity ~variable, mean)

write.table(Data.melted.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
