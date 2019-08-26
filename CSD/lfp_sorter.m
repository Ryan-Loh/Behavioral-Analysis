function lfp = lfp_sorter(lfp, stiRm)
%LFP_SOFTER    Only account for voltage data within trigger window.
%
%   avg_lfp = LFP_SOFTER(avg_LFP, remove_stimulation)
%   AVG_LFP            - Averaged local field potential
%   REMOVE_STIMULATION - Samples that occur during stimulation

for col = 1:size(lfp ,2)
    coeffs = polyfit(stiRm, [lfp(stiRm(1),col), lfp(stiRm(2),col)],1);
    slope = coeffs(1);
    intercept = coeffs(2);
    lfp(stiRm,col) = slope * stiRm + intercept;
end