/* 
   Date: 	2020-08-20 
   Author: 	L Ruijter
   Description: 
       	 	Function to put units into a group. 
		For instance you want to group numbers from 1-100 into sections of 10.
		This function will result the group for each unit the group it would be in + a optional sort number.
		77 for istance would be placed inside "8. 70 - 80 anything g greater then the max size will be returned as max group size +.
		So using the same parameters as the previous example 140 would be "11. 100+" 	
		
   NL:TL:DR 	Getallen in groepen doen.
				
*/
create  function dbo.getGroup (  
                                @Unit varchar(50)    -- The value you want to put in a group.
			      , @GroupSize int       -- Size of your groups. 
			      , @MaxGroupSize int    -- If you want to limit the group size
			      , @ShowGroup bit = 0   -- Set on 1  if you want a sort number before your group name.
			      )  
returns varchar(250)
begin
	
	--If for some reason the Units are not a number stop the function and return null.
	if ISNUMERIC(@unit) = 0
	return null

	declare	   @UnitInt int
		 , @GroupSortNo  int
		 , @Group varchar(50) --Return Var

	set @UnitInt = cast(cast(@unit as numeric(10,2)) as int)

	--Check if the units are bigger then the max size. If this is true we want to find the max group number and return it with a '+' sign.
	if @UnitInt >= @MaxGroupSize
	begin
		select @GroupSortNo = (@MaxGroupSize / @groupsize) 
		set @Group =  concat(
				     case when  @ShowGroup = 1 
					   then concat(@GroupSortNo + 1 ,'. ') 
			 	     end
				    ,format(@groupsize  * @GroupSortNo,'#,0')
				    ,'+'
				   )
	end 
	
	else

	--Units are within the max range. 
	--Devide the group size trough the units to find its index + 1 , then find the group range by multiplying this index with the group size.
	begin
		select @GroupSortNo = (@UnitInt / @groupsize) + 1  --This only works because they are both ints so the results is automaticly floored.
		set @Group  =  concat(
				      case when  @ShowGroup = 1 
				           then concat(@GroupSortNo ,'. ') 
				      end
				     ,FORMAT(@groupsize *  (@GroupSortNo-1),'#,0') -- Min 
				     ,' - ' 
				     ,FORMAT(@groupsize *  (@GroupSortNo),'#,0') -- Max
				     )
	end

	--Fix the ',' thousand separtor to a '.' since we are not yankees. 
	return replace(@group,',','.')
end


