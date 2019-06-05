% pop_copybv - copy a BVA file set and updates with new DataFile and
% MarkerFile lines in .vhdr and .vmrk files. Also updates events with
% EEG.events structure (if provided. 
% 
% Usage:
%   >> [com] = pop_copybv();   % a window pops up for input file and output files
%   >> [com] = pop_copybv(vhdr_file);   % a window pops up for outputfile

%   >> [com] = pop_copybv(vhdr_file, outputfile, EEG); 
%
% Inputs:
%   vhdr_file      - vdhr_file to copy
%   outputfile     - new file name (including path if different than pwd)
%   EEG            - EEG structure to extract events from (if empty, simple
%                    copy of original vmrk file.
%
% If copying events from EEG.events, uses code for marker type
% (Mk1=EEG.event(i).code) and type as description
%   
%
% Author: Joshua Koen, UND

% Copyright (C) 2019, Joshua Koen jkoen@nd.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function com = pop_copybv( vhdr_file, outputfile, EEG );

% initialize com
com = '';

% handle vhdr_file
if nargin < 1
    [vhdr_file hdrpath] = uigetfile2('*.vhdr', 'Select Brain Vision vhdr-file - pop_copybv()');
    if length( vhdr_file ) == 0 return; end;
    vhdr_file = fullfile(hdrpath,vhdr_file); % Remove extension
end

% Handle output file (Removes dot extension)
if nargin < 2
    [outputfile, outputpath] = uiputfile('*', 'Output file');
    if length( outputfile ) == 0 return; end;    
    outputfile = fullfile(outputpath,outputfile);
end

% Remove extensions
[hdrpath vhdr_file] = fileparts(vhdr_file); 
[outputpath outputfile] = fileparts(outputfile);

% Open input vhdr and vmrk files for reading
vhdr_in = fopen( fullfile(hdrpath, [vhdr_file '.vhdr']), 'r' );
vmrk_in = fopen( fullfile(hdrpath, [vhdr_file '.vmrk']), 'r' );

% Open output paths for writing
vhdr_out = fopen( fullfile(outputpath, [outputfile '.vhdr']), 'w' );
vmrk_out = fopen( fullfile(outputpath, [outputfile '.vmrk']), 'w' );

% File output names for .vhdr
DataFile = [ outputfile '.eeg' ];
MarkerFile = [ outputfile '.vmrk' ];

% Update header DataFile and MarkerFile
disp('pop_copybv(): copying and updating header file');
while ~feof(vhdr_in)
    this_line = fgetl(vhdr_in);
    this_line = bv_text_catcher(this_line, DataFile, MarkerFile);
    fwrite(vhdr_out,sprintf('%s\n',this_line));
end

% Deal with the vmrk output
if ~exist('EEG','var')
    
    disp('pop_copybv(): copying marker file');
    while ~feof(vmrk_in)
        this_line = fgetl(vmrk_in);
        this_line = bv_text_catcher(this_line, DataFile, MarkerFile);
        fwrite(vmrk_out,sprintf('%s\r',this_line));
    end
    
else % Update with EEG event info
    
    disp('pop_copybv(): copying and updating marker file');
    e = EEG.event;
    copy_events = false;
    
    % Copy stuff until events
    index = 1;
    while ~feof(vmrk_in)
        % read line
        this_line = fgetl(vmrk_in);
        
        
        
        % Check if I should stop
        if ~copy_events
            % Update data file
            this_line = bv_text_catcher(this_line, DataFile, MarkerFile);
            
            % Try and find the first marker line (Mk1)
            try
                if all(ismember('Mk',this_line(1:2))) % Once markers are reached, add stuff
                    copy_events = true;
                end
            catch
            end
        
        end
        
        % Separate from above so it will do the things in the same
        % iteration
        if copy_events
            
            % Handle event marker conversion. This will only do so if there is
            % not a new segment (preserves 
            if ~all(ismember('New Segment',this_line)) % If a new segment is present
                if ~strcmpi(e(index).code,'New Segment')
                    this_line = bv_event_string(e(index), index);
                end
            end
            index = index + 1; % Increment index
            
        end
        
        % Write stuff
        fwrite(vmrk_out,sprintf('%s\r',this_line));
        
    end
    
end

% Simply copy the .egg file
disp('pop_copybv(): copying data (.eeg) file');
copyfile(fullfile(hdrpath, [vhdr_file '.eeg']), fullfile(outputpath, [outputfile '.eeg']));
        
% Close files
fclose('all');
        
%
end % of function