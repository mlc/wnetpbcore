These files are prebuilt binaries of mediainfo. They are provided here 
as a convenience only. If they don't work on your server (which is, 
um, quite likely actually), you should build your own.

To build your own, visit 
http://mediainfo.sourceforge.net/en/Download/Source
and download the 'all in one' CLI package. Untar it, go into the created 
directory, and type
./CLI_Compile.sh --with-libcurl 

Note that libcurl support is required for proper operation with the 
PBCore database but is not available in the prebuilt binaries provided 
on the mediainfo website.
