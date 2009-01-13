class StaticController < ApplicationController
  session :off
  skip_before_filter :login_required

  def about
    filename = "#{RAILS_ROOT}/REVISION"
    if File.exist?(filename)
      @revision = File.read(filename).chomp
    end
  end
end
