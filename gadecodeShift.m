function shift = gadecodeShift(pop, nbits, bitNumPersons)
    shift = zeros(size(pop,1),nbits/bitNumPersons)-9;
    for i = 1:size(pop,1)
        shift(i,:) = convert2person(pop(i,:),bitNumPersons);


    end
end

function persons = convert2person(vec,bitCount)    
    temp = reshape(vec,numel(vec)/bitCount,bitCount);
    persons = bi2de(temp,'left-msb')';
end