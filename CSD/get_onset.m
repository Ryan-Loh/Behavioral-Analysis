function onset = get_onset(aux)
%GET_ONSET    Find the onset time of trigger.
%
%    T = GET_ONSET(data)
%    T - Onset time

onset = find(aux > 2.0); %??

if length(onset) > 1
    rm_index = diff(onset) <= 1;
    rm_index = [false; rm_index];
    onset(rm_index) = [];
end