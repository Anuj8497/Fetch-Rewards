# Executed before writing dataframes from the ipynb file into the database.
create database raw_fetch;

#Once the dataframes are written into the sql table. Execute below lines of code
use raw_fetch;

# users, receipts, brands

# Q) What are the top 5 brands by receipts scanned for most recent month?
Select max(dateScanned) from receipts;
# Most recent month is March 2021.
# But for the month of March the query returned any insightful result (mainly because of the nulls present in the data).

# Hence I've considered Feb 2021 as my most recent month for this query

Select receipts.brandCode,count(receipts.barcode) as 'Number_of_times_scanned'
from 
receipts
where month(dateScanned) = 2 and year(dateScanned) = 2021 
group by receipts.brandCode
order by count(receipts.dateScanned) desc
limit 5;

#######################################################################################################################################
# Q) How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
# -> 
# Since for the month of March, the query didn't return any insightful result (mainly because of the nulls present in the data).
# I've perfomed comparison between february 2021 and Januray 2021.

Select receipts.brandCode,count(receipts.barcode) as 'Number_of_times_scanned'
from 
receipts
where month(dateScanned) = 2 and year(dateScanned) = 2021 
group by receipts.brandCode
order by count(receipts.dateScanned) desc
limit 5;

#In the month of February NULL,BRAND, MISSION,VIVA were the most popular brands.


Select receipts.brandCode,count(receipts.barcode) as 'Number_of_times_scanned'
from 
receipts
where month(dateScanned) = 1 and year(dateScanned) = 2021 
group by receipts.brandCode
order by count(receipts.dateScanned) desc
limit 5;

#In the month of January NULL,HY-VEE,BEN AND JERRYS,PEPSI,KROGER were the most popular brands 
#######################################################################################################################################

# Q) When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
Select distinct rewardsReceiptStatus from receipts;

# Assuming reward status Accepted is same as finished.
Select avg(totalSpent) as 'Average_Spent' from receipts where rewardsReceiptStatus = 'FINISHED';

Select avg(totalSpent) as 'Average_Spent' from receipts where rewardsReceiptStatus = 'REJECTED';

# Average spend from receipts with rewardsReceiptStatus as 'Accepted' is greater than ones having  status as 'Rejected'.
####################################################################################################################################################

# Q) When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
Select count(_id) as 'items_purchased' from receipts where rewardsReceiptStatus = 'FINISHED';

Select count(_id) as 'items_purchased' from receipts where rewardsReceiptStatus = 'REJECTED';

# The total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ is greater than ones having status as 'Rejected'.

######################################################################################################################################################

# Q) Which brand has the most spend among users who were created within the past 6 months?
Select * from users;

Select min(createdDate) , max(createdDate) from users;
# the latest user was created in the month of february
# So we will track the users with created date between September 2020 and February 2021

with last_six_months as 
(
select distinct(_id) from users where substring(createdDate,1,7) IN ('2020-09','2020-10','2020-11','2020-12','2021-01','2021-02')
),
other as
(
  Select sum(totalSpent) as 'total_spent',brandCode,userId from receipts where brandCode is not null group by brandCode 
)
Select max(other.total_spent),other.brandCode
from 
other
join 
last_six_months 
on
other.UserId = last_six_months._id;

#MISSION has the most spend among users who were created within the past 6 months
##########################################################################################################################################################

# Q) Which brand has the most transactions among users who were created within the past 6 months?

with last_six_months as 
(
select * from users where substring(createdDate,1,7) IN ('2020-09','2020-10','2020-11','2020-12','2021-01','2021-02')
),
other as
(
  Select count(distinct _id) as 'total_transactions',brandCode,userId from receipts where brandCode is not null group by brandCode 
)
Select max(other.total_transactions),other.brandCode 
from 
other
left join 
last_six_months 
on
other.UserId = last_six_months._id;

################################################################################################################################################
# Data Quality issues
#Issue 1
   # In users_fetch table, _id should have been unique. We can see there are multiple duplicate entries for each user.
   Select *, count(_id) from users group by _id; 
   # User with _id = '5ff1e194b6a9d73a3a9f1052' has 11 instances. This can make the results of query inconsistent 
   # when performing join with this table.
   Select * from users where _id = '5ff1e194b6a9d73a3a9f1052';
   # All the rows are duplicate. Hence it would be better to consider just one instance per user.

#Issue2

  # In brands_fetch table, in my opinion, brandCode should also be unique for each brand.
  # But we can see multiple brandCode for a same brands.
  Select name, count(brandCode) from brands group by name having count(brandCode) > 1;
  # In my opinion, every brand should have a unique brandcode.

#Issue3 
   # There are many NULL in various columns of different tables which makes results of certain queries inconsistent.

