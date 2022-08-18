% Return the names of the metrics in test results.
function [names,units] = metricnames()

names = {'processing time',...
         'training under true reward',...
         'training under learned reward',...
         'training reward loss',...
         'training reward error',...
         'true reward',...
         'learned reward',...
         'reward loss',...
         'reward error'};

units = {'seconds',...
         'reward',...
         'reward',...
         'reward loss',...
         'reward error',...
         'reward',...
         'reward',...
         'reward loss',...
         'reward error'};
