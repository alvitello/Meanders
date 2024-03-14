close all
clear all
clc

%% Import data

opts = spreadsheetImportOptions("NumVariables", 14);

% Specify sheet and range
opts.Sheet = "Data";
opts.DataRange = "A2:N8103";

% Specify column names and types
opts.VariableNames = ["MeanderType", "StreamName", "Source", "TypeOfData", "OriginalData", "MeanMeanderWidthm", "MeanderIntrinsicLengthm", "MeanderCartesianLenghtm", "MeanderSinuosity", "MeanderAsymmetry", "MeanderRadiusm", "MeanderAmplitudem", "MeanderDepthm", "Notes"];
opts.VariableTypes = ["categorical", "categorical", "categorical", "categorical", "categorical", "double", "double", "double", "double", "double", "double", "double", "double", "string"];

% Specify variable properties
opts = setvaropts(opts, ["Notes"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["MeanderType", "StreamName", "Source", "TypeOfData", "OriginalData", "MeanderDepthm", "Notes"], "EmptyFieldRule", "auto");

% Import the data
data = readtable("G:\Il mio Drive\DATI\PhD_Meandri\2023_GSL_SPecialIssue_Editor\zz_NostroCapitolo\FinotelloDurkinSylvester_2024_DATABASE.xlsx", opts, "UseExcel", false);

%
clear opts

type=unique(data.MeanderType);
colors = linspecer(length(type),'sequential'); % see https://it.mathworks.com/matlabcentral/fileexchange/42673-beautiful-and-distinguishable-line-colors-colormap
markers = {'o','*','h','p','^','d','>','<','v','.','s','+'};


%% Sinuosity filter (decomment to filter out sinuosity values <1.5)
idx_over = find(data.MeanderSinuosity >= 1.5);
data=data(idx_over,:);

%% Average values for meander trains in the same stream
streamNames = cellstr(data.StreamName);
% Find unique stream names
uniqueStreams = unique(streamNames);

% Initialize new table
avgData = table();

if uniqueStreams(1)=="<undefined>"
    idx = find(isundefined(data.StreamName));
    avgData=[avgData; data(idx,:)];

    for i=2:length(uniqueStreams)
        idx=find(data.StreamName==uniqueStreams(i));

        MeanderType = data.MeanderType(idx(1));
        StreamName = data.StreamName(idx(1));
        Source = data.Source(idx(1));
        TypeOfData = data.TypeOfData(idx(1));
        OriginalData=data.OriginalData(idx(1));
        MeanMeanderWidthm=mean(data.MeanMeanderWidthm(idx));
        MeanderIntrinsicLengthm=mean(data.MeanderIntrinsicLengthm(idx));
        MeanderCartesianLenghtm=mean(data.MeanderCartesianLenghtm(idx));
        MeanderSinuosity=mean(data.MeanderSinuosity(idx));
        MeanderAsymmetry=mean(data.MeanderAsymmetry(idx));
        MeanderRadiusm=mean(data.MeanderRadiusm(idx));
        MeanderAmplitudem=mean(data.MeanderAmplitudem(idx));
        MeanderDepthm=mean(data.MeanderDepthm(idx));

        Notes = unique(data.Notes(idx));

        butta=table(MeanderType, StreamName, Source, TypeOfData, OriginalData, ...
            MeanMeanderWidthm, MeanderIntrinsicLengthm, MeanderCartesianLenghtm, ...
            MeanderSinuosity, MeanderAsymmetry, MeanderRadiusm, MeanderAmplitudem, MeanderDepthm, Notes);

        avgData=[avgData;butta];
    end

else
    disp 'ERROR'
    stop
end




%% Width vs. Wavelength
figure('Units', 'centimeters', 'Position', [0, 0, 8.5, 6.5]);
hold on
for i=1:length(type)
    idx=find(data.MeanderType==type(i));
    plot(data.MeanMeanderWidthm(idx),data.MeanderCartesianLenghtm(idx), 'Color', [0.7 0.7 0.7], 'Marker', markers{i}, 'LineStyle', 'none')
    hold on
    idx=find(avgData.MeanderType==type(i));
    scatter(avgData.MeanMeanderWidthm(idx),avgData.MeanderCartesianLenghtm(idx),30, markers{i},'MarkerEdgeColor',colors(i,:),...
              'MarkerFaceColor',colors(i,:),...
              'LineWidth',2)
end
set(gca,'XScale','log','Yscale','log','Xlim',[0.1 10^5],'Ylim',[10^0 10^6])
% legend(type,'Location','SouthEast')
xlabel('Meander Width W [m]')
ylabel('Meander Cartesian Length L_{xy} [m]')
print('W_vs_Lxy.eps', '-depsc', '-painters');

%% Width vs. Arclength
figure('Units', 'centimeters', 'Position', [0, 0, 8.5, 6.5]);
hold on
for i=1:length(type)
    idx=find(data.MeanderType==type(i));
    plot(data.MeanMeanderWidthm(idx),data.MeanderIntrinsicLengthm(idx), 'Color', [0.7 0.7 0.7], 'Marker', markers{i}, 'LineStyle', 'none')
    hold on
    idx=find(avgData.MeanderType==type(i));
    scatter(avgData.MeanMeanderWidthm(idx),avgData.MeanderIntrinsicLengthm(idx),30, markers{i},'MarkerEdgeColor',colors(i,:),...
              'MarkerFaceColor',colors(i,:),...
              'LineWidth',2)
end
set(gca,'XScale','log','Yscale','log','Xlim',[0.1 10^5],'Ylim',[10^0 10^5])
% legend(type,'Location','SouthEast')
xlabel('Meander Width W [m]')
ylabel('Meander Intrinsic Length L_{s} [m]')
print('W_vs_Ls.eps', '-depsc', '-painters');

%% Width vs. Radius
figure('Units', 'centimeters', 'Position', [0, 0, 8.5, 6.5]);
hold on
for i=1:length(type)
    idx=find(data.MeanderType==type(i));
    plot(data.MeanMeanderWidthm(idx),data.MeanderRadiusm(idx), 'Color', [0.7 0.7 0.7], 'Marker', markers{i}, 'LineStyle', 'none')
    hold on
    idx=find(avgData.MeanderType==type(i));
    scatter(avgData.MeanMeanderWidthm(idx),avgData.MeanderRadiusm(idx),30, markers{i},'MarkerEdgeColor',colors(i,:),...
              'MarkerFaceColor',colors(i,:),...
              'LineWidth',2)
end
set(gca,'XScale','log','Yscale','log','Xlim',[0.1 10^5],'Ylim',[10^-2 10^6])

% legend(type,'Location','SouthEast')
xlabel('Meander Width W [m]')
ylabel('Meander Radius R [m]')
print('W_vs_R.eps', '-depsc', '-painters');

%% Width vs. Amplitude
figure('Units', 'centimeters', 'Position', [0, 0, 8.5, 6.5]);
hold on
for i=1:length(type)
    idx=find(data.MeanderType==type(i));
    plot(data.MeanMeanderWidthm(idx),data.MeanderAmplitudem(idx), 'Color', [0.7 0.7 0.7], 'Marker', markers{i}, 'LineStyle', 'none')
    hold on
    idx=find(avgData.MeanderType==type(i));
    scatter(avgData.MeanMeanderWidthm(idx),avgData.MeanderAmplitudem(idx),30, markers{i},'MarkerEdgeColor',colors(i,:),...
              'MarkerFaceColor',colors(i,:),...
              'LineWidth',2)
end
set(gca,'XScale','log','Yscale','log','Xlim',[0.1 10^5],'Ylim',[10^-2 10^6])
% legend(type,'Location','SouthEast')
xlabel('Meander Width W [m]')
ylabel('Meander Amplitude A [m]')
print('W_vs_A.eps', '-depsc', '-painters');









