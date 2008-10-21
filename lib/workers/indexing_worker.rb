class IndexingWorker < BackgrounDRb::MetaWorker
  set_worker_name :indexing_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end
  
  def reindex
    Kernel.system("rake", "RAILS_ENV=#{RAILS_ENV}", "thinking_sphinx:index")
  end
end

