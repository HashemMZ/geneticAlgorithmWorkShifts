%           Binary Genetic Algorithm
%

%rng(1234);

clear
%_____________________________________________________________
%                       I. Setup the GA
ff='shiftCostFunc';      % objective function
nday=30;			% number of optimization variables here days
%prefered days for all personnels Sat = 1 to Fri = 7
personnel = struct('name',{'Moradmand','Fallah','Ahmadi','Abbasi'},...
    'prefWeekDays',{{[2 4 7]},{[1 3 7]},{[2 6 7]},{[6]}},...
    'dateOff',{{[10]},{[21 5]},{[10 16]},{[3 10 17 16 24]}});



month.startDay = 5; % the day of 1st day of month
month.len = 30;
month.holidays = [16]; %other than fridays
month.name = 'Dey';


%_____________________________________________________________
%                     II. Stopping criteria
maxit=100;			    	% max number of iterations
mincost=-9999999;			% minimum cost

%_____________________________________________________________
%                       III. GA parameters
popsize=100;				   % set population size
mutrate=.15;			   % set mutation rate
selection=0.5;			   % fraction of population kept
nbitsPersons=2;                         % number of bits in each parameter
Nt=nbitsPersons*nday;                   % total number of bits in a chormosome
keep=floor(selection*popsize);   % #population members that survive

%_____________________________________________________________
%               Create the initial population
iga=0;					% generation counter initialized
pop=round(rand(popsize,Nt));		% random population of 1s and 0s
shifts=gadecodeShift(pop,Nt, nbitsPersons);     % convert binary to continuous values
cost=feval(ff,shifts,personnel,month); 		      % calculates population cost using ff
[cost,ind]=sort(cost);              % min cost in element 1
shifts=shifts(ind,:);	pop=pop(ind,:);   % sorts population with lowest cost first
minc(1)=min(cost);		      % minc contains min of population
meanc(1)=mean(cost);		      % meanc contains mean of population

%_____________________________________________________________
%               Iterate through generations
while iga<maxit
    iga=iga+1;                       % increments generation counter

    %_____________________________________________________________
    %                       Pair and mate
    M=ceil((popsize-keep)/2);		    % number of matings
    prob=flipud([1:keep]'/sum([1:keep]));   % weights chromosomes based upon position in list
    odds=[0 cumsum(prob(1:keep))'];	    % probability distribution function
    pick1=rand(1,M);				    % mate #1
    pick2=rand(1,M);				    % mate #2

    % ma and pa contain the indicies of the chromosomes that will mate
    ic=1;
    while ic<=M
        for id=2:keep+1
            if pick1(ic)<=odds(id) & pick1(ic)>odds(id-1)
                ma(ic)=id-1;
            end % if
            if pick2(ic)<=odds(id) & pick2(ic)>odds(id-1)
                pa(ic)=id-1;
            end % if
        end % id
        ic=ic+1;
    end % while

    %_____________________________________________________________
    %           Performs mating using single point crossover
    ix=1:2:keep;                                      % index of mate #1
    xp=ceil(rand(1,M)*(Nt-1));                        % crossover point
    pop(keep+ix,:)=[pop(ma,1:xp) pop(pa,xp+1:Nt)];    % first offspring
    pop(keep+ix+1,:)=[pop(pa,1:xp) pop(ma,xp+1:Nt)];  % second offspring

    %_____________________________________________________________
    %                       Mutate the population
    nmut=ceil((popsize-1)*Nt*mutrate);		% total number of mutations
    mrow=ceil(rand(1,nmut)*(popsize-1))+1;    % row to mutate
    mcol=ceil(rand(1,nmut)*Nt);               % column to mutate
    for ii=1:nmut
        pop(mrow(ii),mcol(ii))=abs(pop(mrow(ii),mcol(ii))-1); % toggles bits
    end % ii

    %_____________________________________________________________
    %   The population is re-evaluated for cost
    shifts(2:popsize,:)=gadecodeShift(pop(2:popsize,:),Nt,nbitsPersons); % decode
    cost(2:popsize)=feval(ff,shifts(2:popsize,:),personnel,month);
    
    %_____________________________________________________________
    %           Sort the costs and associated parameters
    [cost,ind]=sort(cost);
    shifts=shifts(ind,:);	pop=pop(ind,:);

    %_____________________________________________________________
    %           Do statistics for a single nonaveraging run
    minc(iga+1)=min(cost);
    meanc(iga+1)=mean(cost);

    %_____________________________________________________________
    %                       Stopping criteria
    if iga>maxit | cost(1)<mincost
        break
    end
    
    pause(.025)
    clc
    [iga cost(1)]

end %iga

%_____________________________________________________________
%                      Displays the output
day=clock;
disp(datestr(datenum(day(1),day(2),day(3),day(4),day(5),day(6)),0))
disp(['optimized function is ' ff])
format short g
disp(['popsize = ' num2str(popsize) ' mutrate = ' num2str(mutrate) ' # par = ' num2str(nday)])
disp(['#generations=' num2str(iga) ' best cost=' num2str(cost(1))])
disp(['best solution'])
disp([num2str(shifts(1,:))])
for i = 1:month.len
   str = sprintf('%2d %10s %10s \t\t\t %s',i,month.name,date2DayOfWeek(i,month),personnel(shifts(1,i)+1).name);
   disp(str)
   if isequal(date2DayOfWeek(i,month),'Jomeh')
       disp('=================')
   end        
end
disp('binary genetic algorithm')
disp(['each parameter represented by ' num2str(nbitsPersons) ' bits'])
figure(24)
iters=0:length(minc)-1;
plot(iters,minc,iters,meanc,'--');
xlabel('generation');ylabel('cost');
text(0,minc(1),'best');text(1,minc(2),'population average')


function day = date2DayOfWeek(date,month)
%make an a vector of day of week for the whole month
weekDays = {'Shanbeh','1-shanbeh','2-shanbeh','3-shanbeh','4-shanbeh',...
    '5-shanbeh','Jomeh'};
weekDays = circshift(weekDays,-month.startDay+1);
dayOfWeekNum = mod(date,7);
if dayOfWeekNum == 0
    dayOfWeekNum = dayOfWeekNum  +7;
end
day = cell2mat(weekDays(dayOfWeekNum));
end