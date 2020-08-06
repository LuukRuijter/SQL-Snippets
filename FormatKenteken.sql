/* 
   Date: 	2020-06-08 
   Author: 	L Ruijter
   Description: 
       	 	Function to format a Dutch licenceplate into the correct format. 
		A dutch licence plate can exist of Numbers and Chars. (https://nl.wikipedia.org/wiki/Nederlands_kenteken ) 
		Whenever a switch a from numbers or chars exists a "-" should be added with a maximum of two.
        	Or whenever 4 the same datatypes follow eachother with 1 switch after or previous (XXXX99 / 99XXXX). It should split in to a XX-XX-XX format.
		The rules are bit more complicated but this catches around 99.99% of the legal normal licence plates.
   NL:TL:DR 	Format Kenteken SQL Functie. 
				
*/
create function FormatKenteken (
				@kenteken nvarchar(32)
			       )
returns nvarchar(16)  
begin
	declare @result  nvarchar(8) 

	-- Clean the Licenceplate so incase of vaulty input.
	set @kenteken = replace(@kenteken,'-','')

 	-- Slice the Licenceplate into Differnt Vars so we can insert them into the temp table.
	declare  @1 varchar(2) = substring(@kenteken,1,1)
			,@2 varchar(2) = substring(@kenteken,2,1)
			,@3 varchar(2) = substring(@kenteken,3,1)
			,@4 varchar(2) = substring(@kenteken,4,1)
			,@5 varchar(2) = substring(@kenteken,5,1)
			,@6 varchar(2) = substring(@kenteken,6,1)

    	declare  @1i int = isnumeric(@1)
		,@2i int = isnumeric(@2)
		,@3i int = isnumeric(@3)
		,@4i int = isnumeric(@4)
		,@5i int = isnumeric(@5)
		,@6i int = isnumeric(@6)
		,@StreepCount int = 0

	--Check if the next char has a differnt datatype then current.
	--If this is the case add a "-" to the current char. 
	--Since the max amount of stripes per plate is 2 stop after 2 have been added
	if @1i <> @2i
		set @1 += '-'
		set @StreepCount += 1

	if @2i <> @3i  
		set @2 += '-'
		set @StreepCount += 1

	if @3i <> @4i and @StreepCount < 2
		set @3 += '-'
		set @StreepCount += 1 

	if @4i <> @5i and @StreepCount < 2
		set @4 += '-'
		set @StreepCount += 1

	if @5i <> @6i and @StreepCount < 2
		set @5 += '-'
	
	--Once all the checks have been concat them back to 1 licence plate.
	set @result = concat(@1,@2,@3,@4,@5,@6)
    
	-- If 2 "-" have not been added yet strip any existing and add both the "-"  in the XX-XX-XX format.
	-- This our desired go to format for fictional licence plates. This wil also take care of the old 9999XX plates that only have 1 "-" added yet.
	if len(@result) in (6,7)
	begin
		set @result = replace(@result,'-','')
		set @result = substring( @result, 1, 2 ) + '-' + substring( @result, 3, 2 ) + '-' + substring( @result, 5, 2 )
	end

	return upper(@result)

end
