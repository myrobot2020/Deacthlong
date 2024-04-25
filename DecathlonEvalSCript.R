pacman::p_load(readxl,tidyverse,lubridate,dplyr,ggplot2,zoo,tseries,prophet)
df09 <- read_excel("customer_transactions_sample.xlsx",
                   col_types =
                     c("text", "text", "text",
                       "numeric", "date", "numeric", "numeric",
                       "text"),sheet = "Year 2009-2010")

pacman::p_load(readxl,tidyverse,lubridate)
df10 <- read_excel("customer_transactions_sample.xlsx",
                   col_types =
                     c("text", "text", "text",
                       "numeric", "date", "numeric", "numeric",
                       "text"),sheet = "Year 2010-2011")


df11<-rbind.data.frame(df09,df10)
names(df11)[names(df11) == "Customer ID"] <- "CustomerID"
```

```{r,warning=F}
df11$InvoiceDate <- as.Date(df11$InvoiceDate)
df11_aggregated <- df11 %>%
  group_by(InvoiceDate) %>%
  summarise(total_quantity = sum(Quantity))

ggplot(df11_aggregated, aes(x = InvoiceDate, y = total_quantity)) +
  geom_line() +
  labs(x = "Date", y = "Total Quantity") +
  ggtitle("Aggregated Quantity by Day of all Products across Regions including all transactions")


df11<-df11[complete.cases(df11),]
df11<-df11[df11$Quantity>0,]
df11<-df11[df11$Country %in% "United Kingdom",]
df11 <- df11[grepl("CHRISTMAS|TREE|DECORATIONS|SIGNS|LIGHTS|ORNAMENTS", df11$Description, ignore.case = TRUE), ]
a<-aggregate(df11,df11$Quantity~df11$`CustomerID`,sum)
Q1 <- quantile(a$`df11$Quantity`, 0.25)
Q3 <- quantile(a$`df11$Quantity`, 0.75)
IQR <- Q3 - Q1
lower_bound <- Q1 - 1.5 * IQR
upper_bound <- Q3 + 1.5 * IQR
a <- a[a$`df11$Quantity` >= lower_bound & a$`df11$Quantity` <= upper_bound,]
df11<-df11[df11$CustomerID %in% a$`df11$CustomerID`,c("InvoiceDate","Quantity")]
df11$InvoiceDate <- as.Date(df11$InvoiceDate)
df11_aggregated <- df11 %>%
  group_by(InvoiceDate) %>%
  summarise(Quantity_quantity = sum(Quantity))
ggplot(df11_aggregated, aes(x = InvoiceDate, y = Quantity_quantity)) +
  geom_line() +
  labs(x = "Date", y = "Quantity Quantity") +
  ggtitle("Aggregated Quantity by Day")

t1<-ts(df11_aggregated$Quantity_quantity,start = c(2009,12,01),end = c(2011,12,09),frequency = 365)
colnames(df11_aggregated)<-c("ds","y")
t<-df11_aggregated
m<-prophet(t,yearly.seasonality = T,weekly.seasonality = T)
f<-make_future_dataframe(m,periods = 364)
p<-predict(m,f)
pred<-data.frame(yhat=p$yhat,upper=p$yhat_upper,lower=p$yhat_lower)
act<-t$y
act[601:965]<-mean(act)
dates <- seq(as.Date("2009-12-01"), as.Date("2012-12-30"), by = "day")
dates <- dates[weekdays(dates) != "Friday"]
data<-data.frame(act,pred)
data$index<-dates
p <- ggplot(data) +
  geom_line(aes(x = index, y = act, color = "Actual"), size = 1) +
  geom_line(aes(x = index, y = yhat, color = "Predicted"), size = 1) +
  geom_point(aes(x = index, y = upper), color = "grey", size = 0.5) +  
  geom_point(aes(x = index, y = lower), color = "grey", size = 0.5) +  
  scale_color_manual(values = c("Actual" = "red", "Predicted" = "blue")) +
  labs(x = "Date", y = "Values", title = "Actual vs. Predicted with Upper and Lower Bounds") +
  theme_minimal() +
  theme(legend.position = "bottom") +
  guides(color = guide_legend(title = "Data Type"))
print(p)

df11<-rbind.data.frame(df09,df10)
names(df11)[names(df11) == "Customer ID"] <- "CustomerID"
df11$total<-df11$Quantity*df11$Price

df_profit<-df11 %>% group_by(Country) %>% summarise(Profit=sum(Price,na.rm = T))

df_positive <- df11 %>% filter(Quantity > 0)
country_sales <- df_positive %>% group_by(Country) %>% 
  summarise(Quantity_Sold = sum(Quantity, na.rm = TRUE))

df_negative <- df11 %>% filter(Quantity < 0)
country_returns <- df_negative %>% group_by(Country) %>%
  summarise(Quantity_Returned = sum(Quantity, na.rm = TRUE))

country_totals <- merge(country_sales, country_returns, by = "Country", all = TRUE)
country_totals$Quantity_Returned<-abs(country_totals$Quantity_Returned)
country_totals$Quantity_Returned[is.na(country_totals$Quantity_Returned)] <- 0
country_totals$returnrate<-round(country_totals$Quantity_Returned/country_totals$Quantity_Sold*100)

dfhol<-df11
dfhol<-data.frame(day=as.Date(dfhol$InvoiceDate),Country=dfhol$Country)
dfhol<-unique(dfhol)
dfhol<-table(dfhol$Country)
dfhol<-data.frame(dfhol)
colnames(dfhol)<-c("Country","Working_Days")
df12<-merge(dfhol,country_totals)
df13<-merge(df12,df_profit,"Country")
customer_counts<-df11[,c("Country","CustomerID")]
customer_counts<-unique(customer_counts)
customer_counts<-table(customer_counts$Country)
customer_counts<-data.frame(customer_counts)
colnames(customer_counts)<-c("Country","No.Customers")
df14<-merge(df13,customer_counts,"Country")

stockcount<-df11[,c("StockCode","Country")]
stockcount<-table(stockcount$Country)
stockcount<-data.frame(stockcount)
colnames(stockcount)<-c("Country","UniqueProd")
df15<-merge(df14,stockcount,"Country")

data<-df15

lm(formula = Profit~Working_Days,df15)
lm(formula = UniqueProd~No.Customers,df15)

df11$total<-df11$Price*df11$Quantity
names(df11)[names(df11) == "Customer ID"] <- "CustomerID"
df11$InvoiceDate <- as.Date(df11$InvoiceDate)
df_oct_to_dec <- df11 %>%
  filter(month(InvoiceDate) %in% 10:12)
df_rest <- df11 %>%
  filter(!(month(InvoiceDate) %in% 10:12))
head(df_oct_to_dec)
head(df_rest)


sum(df_oct_to_dec$total)/sum(df_rest$total)

df_oct_to_dec<-df_oct_to_dec %>% group_by(Country) %>% summarise(Holiday_revenue=sum(total))
df_rest<-df_rest %>% group_by(Country) %>% summarise(NonHoliday_revenue=sum(total))

df16<-merge(df15,df_rest,"Country")
df16<-merge(df16,df_oct_to_dec,"Country")
df16$holidayrevenueshare<-(df16$Holiday_revenue/df16$NonHoliday_revenue)*100

