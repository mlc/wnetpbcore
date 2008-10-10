# extend ZipInputStream to take an IO object rather than just a filename
# warning: this is really not expected, and breaks a lot of things.
require 'zip/zip'

Zip::ZipInputStream.class_eval do
  def initialize(filename_or_io, offset = 0)
    @archiveIO = (filename_or_io.respond_to?(:seek) ? filename_or_io : File.open(filename_or_io, "rb"))
    @archiveIO.seek(offset, IO::SEEK_SET)
    @decompressor = Zip::NullDecompressor.instance
    @currentEntry = nil
  end
end