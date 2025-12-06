filename = 'minimum_wage_eu_dataset.csv';
data = readtable(filename);

data(:, 1:7) = [];
data(:, end-4:end) = [];
data(:, 4) = [];

newNames = {'CountryCode','Country','TimePeriod','Value'};
data.Properties.VariableNames = newNames;

data.CountryCode = categorical(data.CountryCode);
data.Country = categorical(data.Country);
data.TimePeriod = categorical(data.TimePeriod);

disp('Preview of the dataset:')
disp(head(data))

N = 10;
disp(data(1:N, :))

