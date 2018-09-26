% #########################################################################
% #     check_sources_in_vgosDB_file
% #########################################################################
%
% DESCRIPTION
%   This function checks if sources in a vgosDB files are missing in a superstation file.
%   For each missing source one line is written to the MATLAB command window 
%   which can directly be copied to the vievsCRF.txt file.
%
% CREATED  
%   2018-08-20     Andreas Hellerschmied
%
% INPUT
% - session_name              - Session name (= name of vgosDB folder in .../DATA/vgosDB/<year>/)
% - supersource_name          - Name of supersource file in .../CRF/
%
% CHANGES:
%
function check_sources_in_vgosDB_file(session_name, supersource_name)

% ##### Load supersource file #####
load(['../CRF/', supersource_name]);
IVSname = {source.IVSname}'; % List of all sources (IVS names) in supersource file


% ##### Read nc files #####

% Get year:
session_year = str2num(session_name(1:2));
if session_year < 79
    session_year = session_year + 2000;
else
    session_year = session_year + 1900;
end

vgosdb_path = ['../DATA/vgosDB/', num2str(session_year), '/', session_name];
vgosdb_src_name_list = cellstr(ncread([vgosdb_path, '/Apriori/Source.nc'], 'AprioriSourceList')');
tmp = ncread([vgosdb_path, '/Apriori/Source.nc'], 'AprioriSource2000RaDec')';
vgosdb_src_ra = tmp(:, 1);
vgosdb_src_dec = tmp(:, 2);


% Check, if sources in the vgosDB file are missing in the supersource file:

for i_src = 1 : length(vgosdb_src_name_list)
    src_ind = strcmp(IVSname, vgosdb_src_name_list{i_src});
    
    if sum(src_ind) == 1 % Found source
        
    elseif sum(src_ind) == 0 % No entry in supersource file for this source
        % Example for entry in vievsCRF.txt:
        % *IVS-Name     hh mm ss.ssss    sdd mm as.sssss epoch  0.0  catalogue        fix
        % 1221+503      12 24  9.919900   50  1 55.472400 2000.0 0.0 17SEP18XC_N004    0
        
        ra_hr  = vgosdb_src_ra(i_src)*180/pi/15;
        dec_deg = vgosdb_src_dec(i_src)*180/pi;
        dec_dms = degrees2dms(dec_deg);
        ra_hms = degrees2dms(ra_hr);
        
        fprintf('%8s      %2d %2d %9.6f  %+3d %2d %9.6f 2000.0 0.0 %s         0\n', vgosdb_src_name_list{i_src}, ra_hms(1), ra_hms(2), ra_hms(3), dec_dms(1), dec_dms(2), dec_dms(3), session_name)
        
        
    else % More than 1 entry!
        fprintf(1, 'WARNING: There is more than one entry for source %s (src_ID = %d) in the superstation file!\n', vgosdb_src_name_list{i_src}, i_src);
    end
        
    
    
    
end