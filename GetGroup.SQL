/* 
   Date: 	2020-08-20
   Last Change: 2023-03-04
   Author: 	L Ruijter
   Description: 
       	Function to put units into a group. 
		For instance you want to group numbers from 1-100 into sections of 10.
		This function will result the group for each unit the group it would be in + a optional sort number.
		77 for istance would be placed inside "8. 70 - 80 anything g greater then the max size will be returned as max group size +.
		So using the same parameters as the previous example 140 would be "11. 100+" 	
		If you would use not round groups like 24 with a max of 30 it will divide the last group with the remainder.
		Groups of 24 with a max of 30 with result in:
		1. 0 - 24
		2. 24- 30
		3. 30+ 		
   NL:TL:DR 	Getallen in groepen doen.
				
*/
ALTER  function [dbo].[getGroup] (  
                    @Unit varchar(50)    -- The value you want to put in a group.
			      , @GroupSize int       -- Size of your groups. 
			      , @MaxGroupSize int    -- If you want to limit the group size
			      , @ShowGroup bit = 0   -- Set on 1  if you want a sort number before your group name.
			      )  
returns varchar(250)
begin
	
	--If for some reason the Units are not a number stop the function and return null.
	if ISNUMERIC(@Unit) = 0
	return null

	declare	@UnitInt int
		  , @GroupSortNo  int
		  , @GroupLen  int
		  , @Group varchar(50) --Return Var
		  , @NotRound  int = 1
		  , @Negative int = 0 

	set @UnitInt = cast(cast(@Unit as numeric(20,2)) as int)

	--Take care of negative numbers by making them +
	if @UnitInt < 0 
	begin
	 set @Negative = 1 
	 set @UnitInt = abs(@UnitInt)
	end

	set @GroupSortNo = (@MaxGroupSize / @GroupSize) 

	--Check if the groups are nice and round are we should break before 
	if @MaxGroupSize % @GroupSize > 0 
	set @NotRound = 1

	set @GroupSortNo = @GroupSortNo + 1 + @NotRound 

	--Check if the units are bigger then the max size. If this is true we want to find the max group number and return it with a '+' sign.
	if @UnitInt >= @MaxGroupSize
	begin
		
		set @Group =  concat(
				     case when  @ShowGroup = 1 
					   then concat(@GroupSortNo,'. ') -- +2 if the groups are not round
			 	     end
				    ,format(@MaxGroupSize,'#,0' )
				    ,'+'		 
					) 				   
	end 
	
	else

	--Units are within the max range. 
	--Devide the group size trough the units to find its index + 1 , then find the group range by multiplying this index with the group size.
	begin
		select @GroupLen = len(@GroupSortNo)
		select @GroupSortNo = (@UnitInt / @GroupSize) + 1  --This only works because they are both ints so the results is automaticly floored.
		
		--Calculate Normaly
		set @Group  =  concat(
				      case when  @ShowGroup = 1 
				           then concat(right(concat(REPLICATE('0',@GroupLen), @GroupSortNo), @GroupLen ) ,'. ') 
				      end
				     ,FORMAT(@GroupSize *  (@GroupSortNo-1),'#,0') -- Min 
				     ,' - ' 
				     ,FORMAT(@GroupSize *  (@GroupSortNo),'#,0') -- Max
				     )
	end

	--Give the group a minus if the int was Negative @start 
	if @Negative = 1
	set @Group = '-' + @Group

	--Fix the ',' thousand separtor to a '.' since we are not yankees. 
	return replace(@Group,',','.')
end
