function cost = shiftCostFunc(shifts,personnel,month)
numShiftPop = size(shifts,1);%shift population size
numPersons = length(personnel);

cost = zeros(numShiftPop,1);
for shiftInd = 1 : numShiftPop
    shift = shifts(shiftInd,:);
    for person = 0 : numPersons-1
        preferdDaysOfPerson = cell2mat(personnel(person+1).prefWeekDays);
        offDaysOfPerson = cell2mat(personnel(person+1).dateOff);
        cost(shiftInd) = cost(shiftInd)...
            + equalHolidaysCost(month,shift,person,numPersons)...
            +avgDaysPerWeekCost(month,shift,person)...
            +preferredDaysInWeekCost(month,preferdDaysOfPerson,shift,person)...
            +daysInRowCost(shift,person)...
            + avgDaysPerWeekCost(month,shift,person)...
            + offDaysCost(offDaysOfPerson,shift,person);
    end 
end
end

function avgWeekCost = avgDaysPerWeekCost(month,shift,person)
%cost of avg days per week that is deviates from standard
[holidays, fridays]=calcHolidays(month);
lenOfMonth = length(shift);
prefNumDaysPerWeek = 2;
beginOfWeek = 1;
avgWeekCost = 0;
alpha = 1;

for i = 1:length(fridays) %loop over fridays to extract weeks
    endOfWeek = fridays(i);
    week = beginOfWeek:endOfWeek;
    numOfShiftsOfPersonInWeek = sum(shift(week)==person);
    if numOfShiftsOfPersonInWeek > prefNumDaysPerWeek
        avgWeekCost = avgWeekCost + alpha*(numOfShiftsOfPersonInWeek - prefNumDaysPerWeek);
    end
    beginOfWeek = endOfWeek+1;%next Sat
end
% the remaining days after last friday
if beginOfWeek < lenOfMonth
    endOfWeek = lenOfMonth;
    week = beginOfWeek:endOfWeek;
    numOfShiftsOfPersonInWeek = sum(shift(week)==person);
    if numOfShiftsOfPersonInWeek > prefNumDaysPerWeek
        avgWeekCost = avgWeekCost + alpha*( numOfShiftsOfPersonInWeek - prefNumDaysPerWeek);
    end
end


end



function holCost = equalHolidaysCost(month,shift,person,numPersons)
%cost of unequal holidays for diff personnels
allHolidays = calcHolidays(month);
numHolidayShiftOfPerson = sum(shift(allHolidays) == person);
maxOfHolidayShiftOfEachPerson = ceil(length(allHolidays)/numPersons);
minOfHolidayShiftOfEachPerson = floor(length(allHolidays)/numPersons);
alpha = 1;
if(numHolidayShiftOfPerson <= maxOfHolidayShiftOfEachPerson && ...
       numHolidayShiftOfPerson >= minOfHolidayShiftOfEachPerson )
    holCost = 0;
else
    holCost = alpha * abs(numHolidayShiftOfPerson - maxOfHolidayShiftOfEachPerson);
end
end

function prefDaysCost = preferredDaysInWeekCost(month,preferdDaysOfPerson,shift,person)
weeks = extractWeeks(month);
prefDaysCost = 0;
for i = 1 : length(weeks)
    daysOfPerson = find(shift(weeks(i).dates)==person);
    numOfDaysFromPreferedDays = length(intersect(preferdDaysOfPerson,daysOfPerson));
    prefDaysCost = prefDaysCost - 1*numOfDaysFromPreferedDays;%+length (preferdDaysOfPerson); 
end
end

function twoDayCost = daysInRowCost(shift,person)
twoDayCost = 0;
twoDayCost = twoDayCost + 10*sum(diff(find(shift==person))==1);
end

function DayOffCost = offDaysCost(offDaysOfPerson,shift,person)
DayOffCost = 0;alpha = 20;
DayOffCost = DayOffCost + alpha * length(intersect(find(shift==person),offDaysOfPerson));
end

function [allHolidays, fridays] = calcHolidays(month)
%calculate fridays in the month and return them plus all holidays
fridays =[];
for i = 1 : month.len
    if mod(month.startDay+i-1,7)==0 %friday
        fridays = [fridays i];
    end
end
allHolidays = union(month.holidays, fridays);

end

function weeks = extractWeeks(month)
%extract weeks of month in a struct. each element contains dates of the
%week
[holidays, fridays]=calcHolidays(month);
lenOfMonth = month.len;
beginOfWeek = 1;
for i = 1:length(fridays) %loop over fridays to extract weeks
    endOfWeek = fridays(i);
    weeks(i).dates = beginOfWeek:endOfWeek;    
    beginOfWeek = endOfWeek+1;%next Sat
end
% the remaining days after last friday
if beginOfWeek < lenOfMonth
    endOfWeek = lenOfMonth;
    weeks(i+1).dates = beginOfWeek:endOfWeek;    
end
end