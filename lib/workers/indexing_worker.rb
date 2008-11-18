class IndexingWorker < BackgrounDRb::MetaWorker
  set_worker_name :indexing_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end
  
  def reindex
    AssetTerms.reindex
  end
end

