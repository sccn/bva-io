% bv_event_string() - converts an EEG.events entry to the string for Brain
% Vision .vmrk files. Uses the CODE field for the MK#= entry, and the type
% field for the marker description. 
%
% Usage:
%   >> out_text = bv_event_string(event, marker_number)
%
% Inputs:
%   event         - EEG.event structure (e.g., EEG.event(1) as input)
%
% This function uses the events. 
%
% Author: Joshua D. Koen

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

function out_text = bv_event_string(event, marker_number)

if ~isstruct(event)
    error('input must be a strcutre variable.')
elseif ~all(isfield(event,{'code','type','latency', 'duration'}))
    error('input must have latency, duration, code and type fields.')
end

% If event.type is boundary, replace with ''
if strcmp(event.type,'boundary')
    event.type = '';
end

% Define out_text string
out_text = sprintf('Mk%d=%s,%s,%d,%d,0', ...
    marker_number, ...
    char(event.code), ...
    char(event.type), ...
    event.latency, ...
    event.duration );

end % of function
