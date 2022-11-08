USE [DWH_CZR]
GO

/****** Object:  UserDefinedFunction [dbo].[getGroup]    Script Date: 8-11-2022 16:23:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* 
   Date: 	2020-08-20
   Last Change: 2022-08-11
   Author: 	L Ruijter
   Description: 
       	Function to put units into a group. 
	For instance you want to group numbers from 1-100 into sections of 10.
	This function will return the group for each unit with the group it should be in + a optional sort number.
	77 for istance would be placed inside "8. 70 - 80 anything g greater then the max size will be returned as max group size +.
	So using the same parameters as the previous example 140 would be "11. 100+" 	
	When you groups are not rounded like 24 with a max of 30 it will divide the last group with the remainder.
	Groups of 24 with a max of 30 will result in:
	1. 0 - 24
	2. 24- 30
	3. 30+ 		
   NL:TL:DR 	Getallen in groepen doen.
				
*/
alter  function [dbo].[getGroup] (  
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

	declare	   @UnitInt int
		 , @GroupSortNo  int
		 , @Group varchar(50) --Return Var
		 , @round  int = 1

	set @UnitInt = cast(cast(@Unit as numeric(20,2)) as int)

	--Check if the units are bigger then the max size. If this is true we want to find the max group number and return it with a '+' sign.
	if @UnitInt >= @MaxGroupSize
	begin
		select @GroupSortNo = (@MaxGroupSize / @GroupSize) 

		--Check if the groups are nice and round are we should break before 
		if @MaxGroupSize % @GroupSize > 0 
		set @round = 0

		set @Group =  concat(
				     case when  @ShowGroup = 1 
					   then concat(@GroupSortNo + case when @round = 0 then 2 else  1 end ,'. ') -- +2 if the groups are not round
			 	     end
				    ,format(@MaxGroupSizels ,'#,0' )
				    ,'+'		 
					) 
				   
	end 
	else
	--Units are within the max range. 
	--Devide the group size trough the units to find its index + 1 , then find the group range by multiplying this index with the group size.
	begin
		select @GroupSortNo = (@UnitInt / @GroupSize) + 1  --This only works because they are both ints so the results is automaticly floored.
		
		-- If the Unit is closer to the max then a group then set the boundary to the max unit.
		if @UnitInt >=  @MaxGroupSize - ( @MaxGroupSize % @GroupSize)
		set @Group  =  concat(
				    case when  @ShowGroup = 1 
				        then concat(@GroupSortNo ,'. ') 
				    end
				    ,FORMAT(@GroupSize *  (@GroupSortNo-1),'#,0') -- Min 
				    ,' - ' 
				    ,FORMAT(@MaxGroupSize,'#,0') -- Max
				    ) 
		else
		--Calculate Normaly
		set @Group  =  concat(
				      case when  @ShowGroup = 1 
				           then concat(@GroupSortNo ,'. ') 
				      end
				     ,FORMAT(@GroupSize *  (@GroupSortNo-1),'#,0') -- Min 
				     ,' - ' 
				     ,FORMAT(@GroupSize *  (@GroupSortNo),'#,0') -- Max
				     )
	end
	--Fix the ',' thousand separtor to a '.' since we are not yankees. 
	return replace(@Group,',','.')
end

GO
