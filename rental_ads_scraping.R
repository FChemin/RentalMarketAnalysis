# A program to get leboncoin.fr rental ads links in Britany, France
# And transform those pages into structured data
#
# Author: Florian CHEMIN
# Date: 26th January 2017
#
# R_version: 3.3.2
# OS: linux-gnu

get_ads_links = function(zipcode){
    
    # Requiring necessary libraries
    require(rvest)
    require(magrittr)
    
    # Setting base url
    url_base <- "https://www.leboncoin.fr/locations/offres/bretagne/"
    
    # Setting output variable
    result <- NULL
    
    for (i in 1:40){
        tryCatch({page <- url_base %>% paste("?o=", i, "&zz=", zipcode, sep = "") %>%
            read_html()
        
        tags <- "//section/ul/li/a[contains(@href, 'locations')]" # Setting our selector
        
        ad_links <- page %>% html_nodes(xpath = tags) %>% # Scraping data from web page and get ads links
            html_attr("href")
        ad_links <- paste("https:", ad_links, sep = "")
        },
        
        error = function(e){NA},
        
        finally ={
            result <- c(result, ad_links)
            
            Sys.sleep(runif(1, 5, 10))
        }
        )
    }
    
    result <- data.frame(result, stringsAsFactors = FALSE)
    
    write.csv(result, file = "links.csv", row.names = FALSE)
    
    return(result)
    
}

get_ads_details = function(url){
    
    # Requiring necesseray libraries
    require(rvest)
    require(magrittr)
    
    # Setting output variable
    result <- NULL
    
    # Looping over url pages to get desired values
    for (i in 1:nrow(url)){
        tryCatch({page <- read_html(url[i,])
        
        cost <- page %>% html_node(css = ".item_price .value") %>% 
            html_text()
        
        category <- page %>% html_node(css = ".line_city+ .line .value") %>% 
            html_text()
        
        rooms <- page %>% html_node(css = ".line:nth-child(8) .value") %>% 
            html_text()
        
        area <- page %>% html_node(css = ".line:nth-child(10) .value") %>% 
            html_text()
        },
        
        error = function(e){NA},
        
        finally = {
            result <- rbind(result,c(cost, category, rooms, area, url[i,]))
            
            Sys.sleep(runif(1, 5, 10))
        }
        )
    }
    
    df <- data.frame(result, stringsAsFactors = FALSE)
    names(df) <- c("Monthly Rent", "Category", "Number of Rooms", "Area", "URL")
    
    write.csv(df, file = "rental_market.csv", row.names = FALSE)
    
    return(df)
}