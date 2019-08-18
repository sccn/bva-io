% bv_text_catcher() - checks information in a line of text from a .vhdr or
% .vmrk file for the DataFile= or MarkerFile= lines to update them
% appropriately.
%
% Usage:
%   >> out_text = pop_writebva(in_text,DataFile,MarkerFile);   % a window pops up
%   >> EEG = pop_writebva(EEG, filename);
%
% Inputs:
%   EEG            - eeglab dataset
%   filename       - file name
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

function out_text = bv_text_catcher(in_text, DataFile, MarkerFile)
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