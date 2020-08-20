create  function dbo.getGroup (  
                                 @unit varchar(50)
						  	               , @groupsize int		 -- Size of your group
							                 , @MaxGroupSize int    -- If you want to limit the group size
							                 , @ShowGroup bit = 0   -- Set on 1  if you want a sort number before your group name.
							                 )  
returns varchar(250)
begin
	
	--If for some reason the Units is not a number stop the function and return null.
	if ISNUMERIC(@unit) = 0
	return null

	declare	   @UnitInt int
			 , @GroupSortNo  int
			 , @Group varchar(50)

	set @UnitInt = cast(@unit as int)

	--Check if the units are bigger then the max size. If this is true we want to find the max group number and return it with a '+' sign.
	if @UnitInt >= @MaxGroupSize
	begin
		select @GroupSortNo = (@MaxGroupSize / @groupsize) 
		set @Group =  concat(
						      case when  @ShowGroup = 1 then concat(@GroupSortNo + 1 ,'. ') end
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


