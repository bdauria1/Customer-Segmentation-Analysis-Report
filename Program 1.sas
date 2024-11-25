proc import datafile="/home/u64092424/Customers.csv"
    out=customer_data
    dbms=csv
    replace;
    getnames=yes;
run;

data customer_data_cleaned;
    set customer_data;
    if Profession = '' then Profession = 'Unknown';
run;

proc sql;
    create table customer_data_encoded as
    select *,
        (case when Gender = "Male" then 1 else 0 end) as Gender_Num,
        (case 
            when Profession = "Healthcare" then 1
            when Profession = "Engineer" then 2
            when Profession = "Lawyer" then 3
            when Profession = "Entertainment" then 4
            else 5
        end) as Profession_Num
    from customer_data_cleaned;
quit;

proc standard data=customer_data mean=0 std=1
    out=customer_data_standardized;
    var Age "Annual Income"n "Spending Score"n "Family Size"n "Work Experience"n;
run;

proc fastclus data=customer_data_standardized maxclusters=4 out=segmented_data;
    var Age "Annual Income"n "Spending Score"n "Family Size"n "Work Experience"n;
run;

proc means data=segmented_data;
    class cluster;
    var Age "Annual Income"n "Spending Score"n "Family Size"n "Work Experience"n;
run;

proc sgplot data=segmented_data;
    scatter x="Annual Income"n y="Spending Score"n / group=cluster;
run;

proc sgplot data=segmented_data;
    vbar cluster / response=cluster group=cluster stat=freq datalabel;
    xaxis label="Cluster";
    yaxis label="Number of Customers";
    title "Cluster Sizes";
run;

proc export data=segmented_data
    outfile="/home/u64092424/Segmented_Customers.csv"
    dbms=csv
    replace;
run;
