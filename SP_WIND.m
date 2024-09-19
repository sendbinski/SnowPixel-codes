%% Block stats for SnowPixel SWE
%%% Ryan Szczerbinski


%close all

%%% load rawdata
% load jan_6_SP.txt;
% data= jan_6_SP;  % Select data
% load deidswe_jan_6_fivemin.txt;
% load pale_white_vec.txt;


%%%%%%%%% Method 2
quant = 0.99; % percentage for quantile separation between wind and precip. between 0 and 1

%%%%%%%% ------- CLEANING ------- %%%%%%%%
%%%% pixel fluctuation thresholds in mW
range_lower = 20; %mW. 20 works well, observationally
range_upper = 100; %mW. 100 works well, observationally
%%%% pixel median thresholds in mW
med_lower = 0;
med_upper = 40; % Anything above 40 is "la-la land" and does not appear to fluctuate appropriately

%%%% Choose inside or outside castle walls %%%

%inside_castle = data; 
inside_castle = pale_white_vec.*data; % nans everything outside the thermodynamic ring of fire


inside_castle(:,range(inside_castle)>range_upper)=nan; % nans pixels with a range over 100 mW. Cleans electronic nonsense. Observationally defined threshold.
inside_castle(:,range(inside_castle)<range_lower)=nan; % nans pixels with a range under 20 mW. Cleans non-responding pixels. Observationally defined threshold.
inside_castle(:,nanmedian(inside_castle)<med_lower | nanmedian(inside_castle)>med_upper)=nan; % nans pixels outside a selcet range. at this point very few pixels remain
num_pix = sum(~isnan(inside_castle(1,:))); % number of active pixels

%%%%%%%%%%%---------------%%%%%%%%%%%%%


Freq = 10; %Hz
Lv = 2225640; % J/kg water
rho = 1000; % kg/m3 water
mJtoJ = 1/1000;
mtomm=1000;
num_min = 5; % minutes per block
min_per_hour = 60;
hour_fraction = num_min/min_per_hour;
sample_per_min = Freq*60;
samples_per_block = num_min*sample_per_min;
L=length(inside_castle);
num_blocks=floor(L/samples_per_block);
D = .5/1000; % side length of single sensor in meters
sensor_area = (D*D)*num_pix; % in meters square

block_idx=0;
block_wind = double.empty(0,1);
%total_mw = double.empty(3001,0);


    for i = 1:num_blocks

    start_idx = (block_idx*samples_per_block)+1;
    end_idx = start_idx+samples_per_block;
    block = inside_castle(start_idx:end_idx-1,:); % define block of data
    block = block-min(block); %%%%% KEEP????? I think so YES. Makes minimal difference.
    
    %%%% total_mw(:,i) = nansum(block,2); % use total because the histograms are much cleaner

    %%% Threshold method
    wind_thresh = quantile(block,quant,"all");
    wind_data = block.*(block<=wind_thresh); 
    block_wind(start_idx:end_idx-1) = nansum(wind_data,2); %mW to mJ "integration" summation identical to trapz

    block_idx=block_idx+1;
    num_blocks-block_idx %Progress read-out
    end



% %%%%% scatter
% % figure;plot(swe_in_mm(1:18)*void_ratio,deid_jan(17:end,2),'o','LineWidth',2) %%%%%%  multiplies by void ratio. Funny indexing is to align time stamps
% % hold
% % plot([0 0.5],[0 0.5],'LineWidth',2)
% % xlabel('SP SWE (mm)')
% % ylabel('DEID SWE (mm)')
% % set(gca,'fontsize',16)
% % legend('','1:1','Location','nw','box','off')
% % title(['quantile = ' num2str(quant)])

% figure;plot(void_ratio*cumsum(swe_in_mm(1:18)),'LineWidth',2) %%%%%%%   multiplies by void ratio. Funny indexing is to align time stamps
% hold
% plot(cumsum(deid_jan(17:end,2)),'LineWidth',2)
% xlabel('Time (5-minute sample)')
% ylabel('accumulated swe (mm)')
% set(gca,'fontsize',16)
% legend('SP','DEID','Location','best','box','off')
% title(['Percentile = ' num2str(quant*100) ', ' num2str(num_pix) 'pix, medianbounds = ' num2str(med_lower) ' ' num2str(med_upper)])
% 
% %%%%% Time series %%%%%%
% figure;plot(void_ratio*(swe_in_mm(1:18)),'LineWidth',2) %%%%%%%   multiplies by void ratio. Funny indexing is to align time stamps
% hold
% plot((deid_jan(17:end,2)),'LineWidth',2)
% xlabel('Time (5-minute sample)')
% ylabel('swe (mm)')
% set(gca,'fontsize',16)
% legend('SP','DEID','Location','best','box','off')
% title(['Percentile = ' num2str(quant*100) ', ' num2str(num_pix) 'pix, medianbounds = ' num2str(med_lower) ' ' num2str(med_upper)])


if METHOD == 1
    %%%% SWE RATE
    figure;plot(hour_fraction:hour_fraction:length(swe_in_mm)*hour_fraction,swe_rate,'LineWidth',2) %%%%%%%   multiplies by void ratio. Funny indexing is to align time stamps
    hold
    plot(hour_fraction:hour_fraction:length(deidswe_jan_6_fivemin)*hour_fraction,deidswe_jan_6_fivemin/(hour_fraction),'LineWidth',2)
    xlabel('Time (hours)')
    ylabel('swe rate (mm/hr)')
    set(gca,'fontsize',16)
    legend('SP','DEID','Location','best','box','off')
    title(['Threshold = ' num2str(precip_threshold) ' mW*mW, ' num2str(num_pix) 'pix'])
    %%%% SWE ACCUM
    figure;plot(hour_fraction:hour_fraction:length(swe_in_mm)*hour_fraction,cumsum(swe_in_mm),'LineWidth',2) %%%%%%%   multiplies by void ratio. Funny indexing is to align time stamps
    hold
    plot(hour_fraction:hour_fraction:length(deidswe_jan_6_fivemin)*hour_fraction,cumsum(deidswe_jan_6_fivemin),'LineWidth',2)
    xlabel('Time (hours)')
    ylabel('accumulated swe (mm)')
    set(gca,'fontsize',16)
    legend('SP','DEID','Location','best','box','off')
    title(['Threshold = ' num2str(precip_threshold) ' mW*mW, ' num2str(num_pix) 'pix'])
end

if METHOD == 2
    %%%% SWE RATE
    figure;plot(hour_fraction:hour_fraction:length(swe_in_mm)*hour_fraction,new_swe_rate,'LineWidth',2) %%%%%%%   multiplies by void ratio. Funny indexing is to align time stamps
    hold
    plot(hour_fraction:hour_fraction:length(deidswe_jan_6_fivemin)*hour_fraction,deidswe_jan_6_fivemin/(hour_fraction),'LineWidth',2)
    xlabel('Time (hours)')
    ylabel('swe rate (mm/hr)')
    set(gca,'fontsize',16)
    legend('SP','DEID','Location','best','box','off')
    title(['Percentile = ' num2str(quant*100) ', ' num2str(num_pix) 'pix, medianbounds = ' num2str(med_lower) ' ' num2str(med_upper)])
    %%%% SWE ACCUM
    figure;plot(hour_fraction:hour_fraction:length(swe_in_mm)*hour_fraction,cumsum(new_swe_in_mm),'LineWidth',2) %%%%%%%   multiplies by void ratio. Funny indexing is to align time stamps
    hold
    plot(hour_fraction:hour_fraction:length(deidswe_jan_6_fivemin)*hour_fraction,cumsum(deidswe_jan_6_fivemin),'LineWidth',2)
    xlabel('Time (hours)')
    ylabel('accumulated swe (mm)')
    set(gca,'fontsize',16)
    legend('SP','DEID','Location','best','box','off')
    title(['Percentile = ' num2str(quant*100) ', ' num2str(num_pix) 'pix, medianbounds = ' num2str(med_lower) ' ' num2str(med_upper)])
end





