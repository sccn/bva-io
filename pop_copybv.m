% pop_copybv - copy a Brain Vision file set and updates the appropriate
% file names (DataFile and MarkerFile lines) in .vhdr and .vmrk files with
% a new file name
% 
% Usage:
%   >> [com] = pop_copybv();   % a window pops up for input file and output files
%   >> [com] = pop_copybv(vhdr_file);   % a window pops up for outputfile
%
% Inputs:
%   vhdr_file      - vdhr_file to copy
%   outputfile     - new file name (including path if different than pwd,
%                    extension is ignored, but best to use .vhdr)
%
% Author: Joshua Koen, University of Notre Dame

% Copyright (C) 2019, Joshua Koen (jkoen@nd.edu)
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

function com = pop_copybv( vhdr_file, outputfile )

% initialize com
com = '';

% handle vhdr_file
if nargin < 1
    [vhdr_file, hdrpath] = uigetfile2('*.vhdr', 'Select Brain Vision vhdr-file - pop_copybv()');
    if isempty( vhdr_file ), return; end
    vhdr_file = fullfile(hdrpath,vhdr_file); % Remove extension
end

% Handle output file (Removes dot extension)
if nargin < 2
    [outputfile, outputpath] = uiputfile('*', 'Output file');
    if isempty(outputfile), return; end    
    outputfile = fullfile(outputpath,outputfile);
end

% Remove extensions
[hdrpath, vhdr_file] = fileparts(vhdr_file); 
[outputpath, outputfile] = fileparts(outputfile);

% Open input vhdr and vmrk files for reading
vhdr_in = fopen( fullfile(hdrpath, [vhdr_file '.vhdr']), 'r' );
vmrk_in = fopen( fullfile(hdrpath, [vhdr_file '.vmrk']), 'r' );

% Open output paths for writing
vhdr_out = fopen( fullfile(outputpath, [outputfile '.vhdr']), 'w' );
vmrk_out = fopen( fullfile(outputpath, [outputfile '.vmrk']), 'w' );

% File output names for .vhdr
DataFile = [ outputfile '.eeg' ];
MarkerFile = [ outputfile '.vmrk' ];

% Update header header
disp('pop_copybv(): copying and updating header file');
while ~feof(vhdr_in)
    this_line = fgetl(vhdr_in);
    this_line = bv_text_catcher(this_line, DataFile, MarkerFile);
    fwrite(vhdr_out,sprintf('%s\n',this_line));
end

% Update vmrk file
disp('pop_copybv(): copying and updating marker file');
while ~feof(vmrk_in)
    this_line = fgetl(vmrk_in);
    this_line = bv_text_catcher(this_line, DataFile, MarkerFile);
    fwrite(vmrk_out,sprintf('%s\n',this_line));
end

% Simply copy the .eeg file
disp('pop_copybv(): copying data (.eeg) file');
copyfile(fullfile(hdrpath, [vhdr_file '.eeg']), fullfile(outputpath, [outputfile '.eeg']));
        
% Close files
fclose('all');

% update com
com = sprintf('pop_copybv( ''%s.vhdr'', ''%s.vhdr'' );', ...
    fullfile(hdrpath,vhdr_file), fullfile(outputpath,outputfile) );

function out_text = bv_text_catcher(in_text, DataFile, MarkerFile)
    % bv_text_catcher() - checks information in a line of text from a .vhdr or
    % .vmrk file for the DataFile= or MarkerFile= lines to update them
    % appropriately.
    %
    % Usage:
    %   >> bv_text_catcher(in_text,DataFile,MarkerFile);   % a window pops up
    %   >> EEG = pop_writebva(EEG, filename);
    %
    % Inputs:
    %   in_text    - line of text to evaluate for presence of 'DataFile=' or
    %                'MarkerFile='
    %   DataFile   - String for the new DataFile name to save in the .vhdr and
    %                .vmrk files. should only be file name and extension (no
    %                path).
    %   MarkerFile- String for the new DataFile name to save in the .vhdr file.
    %               Should only be file name and extension (no path).
    
    % Error Check
    if ~ischar(in_text) || ~ischar(DataFile) || ~ischar(MarkerFile) || nargin < 3
        error('bv_file_catcher requires string inputs for in_text, DataFile, and MarkerFile');
    end
    
    
    if all(ismember('DataFile=',in_text)) % DataFile replace
        out_text = sprintf('DataFile=%s', DataFile);
    elseif all(ismember('MarkerFile=', in_text)) % MarkerFile replace
        out_text = sprintf('MarkerFile=%s', MarkerFile);
    else % Otherwise simply pass it in
        out_text = in_text;
    end

end


end % of function

