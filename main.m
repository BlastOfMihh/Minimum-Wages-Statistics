%% Load and clean dataset
filename = 'minimum_wage_eu_dataset.csv';
data = readtable(filename);

% Remove unnecessary columns
data(:, 1:7) = [];
data(:, end-4:end) = [];
data(:, 4) = [];

% Rename columns
newNames = {'CountryCode','Country','TimePeriod','Value'};
data.Properties.VariableNames = newNames;

% Convert to appropriate types
data.CountryCode = categorical(data.CountryCode);
data.Country = categorical(data.Country);
data.TimePeriod = categorical(data.TimePeriod);

% Convert Value to numeric
data.Value = str2double(string(data.Value));

%% Define country groups
highMedium = {'Germany','Luxembourg','Ireland','Netherlands','Belgium'};
similar = {'Poland','Hungary'};
low = {'Bulgaria'};
war = {'Ukraine','Moldova','Serbia','Slovenia'};

% Define groups for comparison
groups = {highMedium, similar, low, war, {'United States'}};
groupNames = {'High-Medium','Similar','Low','War','United States'};

% Loop through each group to plot Romania vs group
for g = 1:length(groups)
    figure;
    hold on;
    
    % Plot Romania
    idxR = data.Country=='Romania';
    timesR = data.TimePeriod(idxR);
    valsR = data.Value(idxR);
    plot(timesR, valsR, '-o', 'LineWidth',1.5, 'DisplayName','Romania');
    
    % Plot countries in current group
    currentGroup = groups{g};
    for c = currentGroup
        idxC = data.Country==c{1};
        timesC = data.TimePeriod(idxC);
        valsC = data.Value(idxC);
        plot(timesC, valsC, '-s', 'LineWidth',1.5, 'DisplayName', c{1});
    end
    
    xtickangle(45)
    xlabel('Time Period')
    ylabel('Minimum Wage Value')
    title(['Romania vs ', groupNames{g}])
    legend('Location','best')
    grid on
    hold off;
end

%% Boxplot for all countries
figure;
group = data.Country;
boxplot(data.Value, group)
xtickangle(45)
ylabel('Minimum Wage Value')
title('Boxplot of Minimum Wages by Country')

%% Histogram example: Romania
% figure;
% histogram(data.Value(data.Country=='Romania'),'BinWidth',10)
% xlabel('Minimum Wage Value')
% ylabel('Frequency')
% title('Histogram of Romania Minimum Wage')

%% Stem-like plot (MATLAB equivalent)
% Extract Romania data and remove missing values
idx = data.Country=='Romania' & ~isnan(data.Value);
romania_vals = data.Value(idx);
romania_years = data.TimePeriod(idx);  % categorical array

% Create the stem plot
figure;
stem(romania_years, romania_vals, 'filled')
xtickangle(45)  % rotate x-axis labels for readability
xlabel('Time Period')
ylabel('Minimum Wage Value')
title('Stem Plot of Romania Minimum Wage Over Time')


%% Frequency polygon: Romania
% vals = data.Value(data.Country=='Romania');
% [counts, edges] = histcounts(vals, 10);
% binCenters = edges(1:end-1) + diff(edges)/2;
% figure;
% plot(binCenters, counts, '-o')
% xlabel('Minimum Wage Value')
% ylabel('Frequency')
% title('Frequency Polygon for Romania')

%% Regression: US vs EU mean (handling missing and non-numeric values)

% Ensure Value is numeric
data.Value = str2double(string(data.Value));

% Compute EU mean per time period (excluding US)
EU_mean = varfun(@mean, data(data.Country~='United States',:), 'InputVariables','Value', 'GroupingVariables','TimePeriod');

% Get US values aligned to EU time periods
timePeriods = EU_mean.TimePeriod;
EU_mean_vals = [];
US_vals_matched = [];

for i = 1:length(timePeriods)
    EU_val = EU_mean.mean_Value(i);
    idxUS = data.Country=='United States' & data.TimePeriod==timePeriods(i);
    US_val = data.Value(idxUS);

    % Only include numeric, non-missing values
    if ~isnan(EU_val) && ~isempty(US_val) && ~isnan(US_val)
        EU_mean_vals(end+1,1) = EU_val;
        US_vals_matched(end+1,1) = US_val;
    end
end

% Ensure both vectors are column numeric vectors
EU_mean_vals = double(EU_mean_vals(:));
US_vals_matched = double(US_vals_matched(:));

% Fit regression
mdl = fitlm(EU_mean_vals, US_vals_matched);
disp('Regression: US vs EU mean minimum wage')
disp(mdl)

% Plot
figure;
plot(EU_mean_vals, US_vals_matched, '-g')
hold on
plot(EU_mean_vals, mdl.Fitted, '-r')
xlabel('EU Mean Minimum Wage')
ylabel('US Minimum Wage')
title('Regression: US vs EU Mean Minimum Wage')
grid on
hold off


%% Romania vs Moldova vs Ukraine (EU entrance)
allYears = unique(data.TimePeriod);  % categorical array
allYears = sort(allYears);           % chronological order

romania_vals = [];
moldova_vals = [];
ukraine_vals = [];
% montenegro_vals = [];
% albania_vals = [];
% turkey_vals = [];

years_to_plot = {};  % keep as cell array

for i = 1:length(allYears)
    % Use ismember to compare categorical values
    idxR = data.Country=='Romania' & ismember(data.TimePeriod, allYears(i));
    idxM = data.Country=='Moldova' & ismember(data.TimePeriod, allYears(i));
    idxU = data.Country=='Ukraine' & ismember(data.TimePeriod, allYears(i));
    % idxN = data.Country=='Montenegro' & ismember(data.TimePeriod, allYears(i));
    % idxA = data.Country=='Albania' & ismember(data.TimePeriod, allYears(i));
    % idxT = data.Country=='Turkey' & ismember(data.TimePeriod, allYears(i));

    valR = data.Value(idxR);
    valM = data.Value(idxM);
    valU = data.Value(idxU);
    % valN = data.Value(idxN);
    % valA = data.Value(idxA);
    % valT = data.Value(idxT);
    
    % Only include if all three countries have valid numeric values
    if ~isempty(valR) && ~isempty(valM) && ~isempty(valU) && ...
       ~isnan(valR) && ~isnan(valM) && ~isnan(valU) % && ...
    %    ~isempty(valN) && ~isempty(valA) && ~isempty(valT) && ...
    %    ~isnan(valN) && ~isnan(valA) && ~isnan(valT)
       
        romania_vals(end+1,1) = valR;
        moldova_vals(end+1,1) = valM;
        ukraine_vals(end+1,1) = valU;
        % montenegro_vals(end+1,1) = valN;
        % albania_vals(end+1,1) = valA;
        % turkey_vals(end+1,1) = valT;
        
        % Convert categorical to string for storing in cell
        years_to_plot{end+1,1} = string(allYears(i));
    end
end

% Convert cell array of strings to string array
years_to_plot_str = string(years_to_plot);

% Convert to categorical
years_to_plot_cat = categorical(years_to_plot_str);

% Optional: sort chronologically based on numeric index of semesters
[~, sortIdx] = sort(years_to_plot_cat);  % simple chronological order
years_to_plot_cat = years_to_plot_cat(sortIdx);
romania_vals = romania_vals(sortIdx);
moldova_vals = moldova_vals(sortIdx);
ukraine_vals = ukraine_vals(sortIdx);
% montenegro_vals = montenegro_vals(sortIdx);
% albania_vals = albania_vals(sortIdx);
% turkey_vals = turkey_vals(sortIdx);


% Plot
figure;
plot(years_to_plot_cat, romania_vals, '-o', 'DisplayName','Romania')
hold on
plot(years_to_plot_cat, moldova_vals, '-s', 'DisplayName','Moldova')
plot(years_to_plot_cat, ukraine_vals, '-^', 'DisplayName','Ukraine')
% plot(years_to_plot_cat, montenegro_vals, '-b', 'DisplayName','Montenegro')
% plot(years_to_plot_cat, albania_vals, '-r', 'DisplayName','A')
% plot(years_to_plot_cat, turkey_vals, '-y', 'DisplayName','T')
xtickangle(45)
xlabel('Time Period')
ylabel('Minimum Wage Value')
title('Romania vs Moldova vs Ukraine (All Years)')
legend('Location','best')
grid on
hold off

% Reason behind Moldova's minimum wage significant jump in 2022
% Extract Moldova values
idxM = data.Country=='Moldova';
modova_vals = data.Value(idxM);
modova_periods = data.TimePeriod(idxM);

% Plot Moldova minimum wage over time
figure;
stem(modova_periods, modova_vals, 'filled')
xtickangle(45)
xlabel('Time Period')
ylabel('Minimum Wage')
title('Moldova Minimum Wage 1999-2025')
grid on

%% Serbia and Slovenia – Simple Extract & Plot
countries = {'Serbia','Slovenia'};

figure;
hold on;

for i = 1:length(countries)
    c = countries{i};

    % Select rows
    idx = data.Country == c;

    years = data.TimePeriod(idx);
    vals  = data.Value(idx);

    % Remove missing
    valid = ~isnan(vals);
    years = years(valid);
    vals  = vals(valid);

    % Plot
    plot(years, vals, '-o', 'LineWidth', 1.4, 'DisplayName', c);
end

hold off;
grid on;
xlabel('Semester');
ylabel('Minimum Wage');
title('Minimum Wage: Serbia vs Slovenia');
legend('Location','best');
xtickangle(45);

%% Growth Rate Comparison
figure;
hold on;

for i = 1:length(countries)
    c = countries{i};

    % Select rows
    idx = data.Country == c;

    years = data.TimePeriod(idx);
    vals  = data.Value(idx);

    % Remove missing
    valid = ~isnan(vals);
    years = years(valid);
    vals  = vals(valid);

    % Compute growth rate (%)
    growth = [NaN; diff(vals) ./ vals(1:end-1) * 100];

    % Plot growth rate
    plot(years, growth, '-o', 'LineWidth', 1.4, 'DisplayName', [c ' Growth']);
end

hold off;
grid on;
xlabel('Semester');
ylabel('Growth Rate (%)');
title('Minimum Wage Growth Rate: Serbia vs Slovenia');
legend('Location','best');
xtickangle(45);
