% From the TIFF specification
%   Peter Li 30-Aug-05
%   Some rights reserved.  Licensed under Creative Commons: http://creativecommons.org/licenses/by-nc-sa/3.0/

CONTENTS_TIFF_H = {
    'ENTRY_LENGTH'      ;...
    'TIFFHEAD'          ;...
    'IFD_TAGMAP'        ;...
    'CONTENTS_TIFF_H'   ;...
};

ENTRY_LENGTH = 12;

TIFFHEAD = struct(                  ...
    'byte_order'    ,   '2*uchar'   ,...
    'tiff_id'       ,   'uint8'     ,...
    'ifd_offset'    ,   'uint32'    ...
);

% See toolbox/matlab/iofun/private/imtifinfo.mat
IFD_TAGMAP = struct(                            ...
    'x254'      ,   'NewSubFileType'            ,...
    'x256'      ,   'ImageWidth'                ,...
    'x257'      ,   'ImageLength'               ,...
    'x258'      ,   'BitsPerSample'             ,...
    'x259'      ,   'Compression'               ,...
    'x262'      ,   'PhotometricInterpretation' ,...
    'x273'      ,   'StripOffsets'              ,...
    'x277'      ,   'SamplesPerPixel'           ,...
    'x279'      ,   'StripByteCounts'           ,...
    'x284'      ,   'PlanarConfiguration'       ,...
    'x34412'    ,   'LSMInfoOffset'             ...
);