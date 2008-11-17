class StaticController < ApplicationController
  session :off

  def about
    filename = "#{RAILS_ROOT}/REVISION"
    if File.exist?(filename)
      @revision = File.read(filename).chomp
    end
  end
end
