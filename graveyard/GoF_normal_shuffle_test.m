function [pval, gof_obs, gof_shuf] = GoF_normal_shuffle_test(data_obs, shufs)
% compares the observed goodness-of-fit (GoF) statistic to a distribution 
% of GoF statistics generated by shuffling the observed data points and 
% refitting each time
%
% obs_data is a cell length N, where N is the number of possible
% observation points. Each cell contains all the samples taken at that
% observation point.
%
% the desired number of shuffles is indicated by shufs

% observed GoF
%
    % fit data
    [~, fit_yvals, yvals_obs] = plot_normal_fit_subj(data_obs, 0);
   
    % obs GoF    
     gof_obs = goodnessOF(yvals_obs, fit_yvals);
    
    
% shuffled GoFs
%

    %prep
    all_obs_data = cell2mat(data_obs);
    samp_per_op = cellfun('length', data_obs);
    rebuild_cell_idx = []; 
    for iop = 1:length(samp_per_op) 
        rebuild_cell_idx = [rebuild_cell_idx; ones(samp_per_op(iop),1).*iop]; 
    end

    % iterate through shuffles
    gof_shuf = [];
    warning ('off','all');
    
    %
    shuf_ct = 0;
    while length(gof_shuf)<shufs

        % shuffle observations
        all_shuf_data = all_obs_data(randperm(length(all_obs_data)));
        data_shuf = cell(size(data_obs));
        for icell = 1:length(data_shuf)
            data_shuf{icell} = all_shuf_data(rebuild_cell_idx==icell);
        end
        
        shuf_ct = shuf_ct+1;
        if shuf_ct > 1000
            break
        end
            
        
        % fit shuffled data
        try
        [~, fit_yvals, yvals_shuf] = plot_normal_fit_subj(data_shuf, 0);
        catch
            continue
        end
            

       
        % obs GoF (normal distribution formula susceptible to nan/inf values)
        gof_hold = goodnessOF(yvals_shuf, fit_yvals);
        if ~isnan(gof_hold)
            gof_shuf = [gof_shuf; gof_hold];
        else
            continue
        end
    end
    
    %}
    warning ('on','all');

% compute pval (shuffled gof stats less than obs)
pval = sum(gof_shuf<=gof_obs)/length(gof_shuf);
