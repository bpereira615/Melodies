%   Benjamin Hoertnagl-Pereira
%   bhoertn1@jhu.edu
%   
%   Signals and Systems
%   Project 1
%       Part 2 - Melody Enrichment (Volume Variation)

function [] = generate_melody_volume(filename, playbackSpeed)
%generate_melody_volume - creates a melody from an array of notes 
%   and durations. The function takes in the name of a .mat file 
%   (containing a notes and score array), generates the corresonding 
%   melody and adds an ADSR enrichment, and saves the output melody 
%   as a .wav file. PlaybackSpeed multiplyer controls the speed of the
%   melody by alterning the time duration for each note in seconds (default
%   is 0.25 seconds).


%the set of notes
noteSet = {'A3', 'B3b', 'B3', 'C3', 'D3b', 'D3', 'E3b', 'E3', 'F3', 'G3b', 'G3', 'A4b',...
    'A4', 'B4b', 'B4', 'C4', 'D4b', 'D4', 'E4b', 'E4', 'F4', 'G4b', 'G4', 'A5b', '-'};

%the set of frequencies associated with the respective notes
freqSet = [220*2.^(0/12), 220*2.^(1/12), 220*2.^(2/12), 220*2.^(3/12), 220*2.^(4/12), 220*2.^(5/12), 220*2.^(6/12), 220*2.^(7/12), 220*2.^(8/12), 220*2.^(9/12), 220*2.^(10/12), 220*2.^(11/12),...
    220*2.^(12/12), 220*2.^(13/12), 220*2.^(14/12), 220*2.^(15/12), 220*2.^(16/12), 220*2.^(17/12), 220*2.^(18/12), 220*2.^(19/12), 220*2.^(20/12), 220*2.^(21/12), 220*2.^(22/12), 220*2.^(23/12), 0];    

%lookup table for frequencey of given note
noteFreq = containers.Map(noteSet, freqSet);

%sampling frequency
Fs = 8000;

%respective period of sampling
Ts = 1/Fs;


%loads the given .mat file
load (filename);

%duration of a unit note length (default - 0.5)
noteLength = 0.25 / playbackSpeed;



%total duration of piece in seconds
totalSec = 0;
for sec = score
    totalSec = totalSec + sec;
end 
totalSec = totalSec * noteLength;

%the signal array for melody, initializing
melody = zeros(1, Fs * totalSec);

i = 1;
timeMark = 1;
%iterate through each note
for n = notes
    dur = score(i);
    t = 0:Ts:dur * noteLength;

    
    freq = noteFreq(char(n));

    y = sin(freq*2*pi*t);
    
    %enrichment, ADSR
    a = linspace(0, 1, 0.1*dur * noteLength*Fs);
    d = linspace(1, 0.8, 0.15*dur * noteLength*Fs);
    
    %need to account for extra +1 sample,
    %round function to prevent error: size inputs must be integers
    %TODO: fix weird corner case for following durations
    if dur == 1.5 || dur == 0.75
        s = 0.8*ones(1, round(0.6*dur * noteLength*Fs) + 3);    
    else
        s = 0.8*ones(1, round(0.6*dur * noteLength*Fs) + 1);    
    end
    
    r = linspace(0.8, 0, 0.15*dur * noteLength*Fs);
    enrich = [a d s r];
    %
    
    
    %plot the first note
    if (i == 1)
        figure;
        subplot(3,1,1);
        plot(t, enrich, '-b')
        title('generate-melody-volume: ADSR Envelope') 
        xlabel('Time (sec)')
        ylabel('Amp')
        
        subplot(3,1,2);
        plot(t, y.*enrich, '-b')
        title('generate-melody-volume: First Note') 
        xlabel('Time (sec)')
        ylabel('Amp')
        
    end
    
    melody(1, timeMark:timeMark + size(t, 2) - 1) = y.* enrich;

    
    %updates counter for index in score array
    i = i + 1;
    
    %updates the current time marker in melody
    timeMark = timeMark + (dur * noteLength) * Fs;
end

%soundsc(melody, Fs);
tTotal = 0:Ts:totalSec;
%plot(tTotal, melody(1, 1:1.5*Fs + 1));

subplot(3,1,3); 
plot(tTotal, melody, '-b')
title('generate-melody-volume: Melody') 
xlabel('Time (sec)')
ylabel('Amp')




%change filename based on playback
outfile = '';
if (playbackSpeed > 1)
    outfile = strcat(filename(1:7), 'FasterADSR.wav');
elseif (playbackSpeed < 1)
    outfile = strcat(filename(1:7), 'SlowerADSR.wav');        
else
    outfile = strcat(filename(1:7), 'ADSR.wav');
end
audiowrite(outfile, melody, Fs);

%soundsc(melody, Fs)


end

