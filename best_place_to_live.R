

# Showing the structure of the dataset and first three rows

str(df)
head(df, 3)

# We have some scrubbing to do here!
# First, subsetting the dataset to keep only apartment and house rentals
df <- subset(df, df$Category %in% c("Appartement", "Maison"), drop = TRUE)

# Then, extracting prices from "Monthly Rent" and convert them to integers
library(stringr)

df$Monthly.Rent <- gsub(" ", "", df$Monthly.Rent)
expr <- "[[:digit:]]+"
df$Monthly.Rent <- df$Monthly.Rent %>% str_extract(expr) %>% as.integer()

# And, redoing it for "Area" column
df$Area <- df$Area %>% str_extract(expr) %>% as.integer()

# Then, converting "Category" variables to factor and "Number of Rooms" to integers
df$Category <- as.factor(gsub("Appartement", 1, df$Category))
df$Category <- as.factor(gsub("Maison", 2, df$Category))
df$Number.of.Rooms <- as.integer(df$Number.of.Rooms)

# Continue by droping all rows with NAs and resetting index names
df <- df[complete.cases(df),]
rownames(df) <- NULL # Reset index names

# We now have a clean dataset to start working with
head(df, 5)

# Exploring the dataset
library(ggplot2)

str(df)
summary(df)

# It seems that some values for "Monthly Rent", "Number of rooms" and "Area" 
# are a little odds. Let's investigate!

df[which(df$Number.of.Rooms == 22),] # Looks like a typo here and two identical entries
df <- df[-423,] # Remove one of the entries
rownames(df) <- NULL # Reset index names
df$Number.of.Rooms[423] <- 1 # 1 room make more sense for this entry

# Dropping the entry with a monthly rent of 10€

df <- df[-which(df$Monthly.Rent == 10),]

# Dropping every row whom has an area greater than 200m2

df <- df[-which(df$Area > 200),]

# Resetting index names for the last time
rownames(df) <- NULL

summary(df) # Much better!

# And now for the plotting part

p <- ggplot(df)
p <- p + geom_point(aes(x = df$Area, y = df$Monthly.Rent), color = "blue")
p