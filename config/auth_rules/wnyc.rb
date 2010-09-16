authorization do
  role :guest do
    # no permissions
  end

  role :user do
    includes :guest
    has_permission_on :assets, :to => [:read, :request]
    has_permission_on :instantiations, :to => [:read]
    has_permission_on :users, :to => [:show, :update] do
      if_attribute :id => is { user.id }
    end
  end

  role :cataloger do
    includes :user
    has_permission_on :assets, :to => [:create]
    has_permission_on :assets, :to => [:update, :delete] do
      if_attribute :creator_id => is { user.id }
    end
    has_permission_on :instantiatons, :to => [:create]
    has_permission_on :instantiations, :to => [:update, :delete] do
      if_attribute :creator_id => is { user.id }
    end
  end

  role :editor do
    includes :user
    has_permission_on :assets, :to => :crud
    has_permission_on :instantiations, :to => :crud
  end

  role :admin do
    includes :editor
    has_permission_on :last_used_ids, :to => :index
    has_permission_on :templates, :to => :crud
    has_permission_on :users, :to => :crud
    has_permission_on :users, :to => :make_admin do
      if_attribute :id => is_not { user.id }
    end
    has_permission_on :picklists, :to => :crud
    (PicklistsController::SUBCLASSES - ['subjects']).each do |kl|
      has_permission_on kl.to_sym, :to => :crud
    end
    has_permission_on :assets, :to => :multilend
    has_permission_on :assets, :to => :destroy_found_set
    has_permission_on :ip_blocks, :to => :crud
  end
end

privileges do
  privilege :read, :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :borrow, :includes => [:borrowings, :return]
  privilege :crud, :includes => [:create, :read, :update, :destroy]
  privilege :merge, :includes => :multiprocess
  privilege :video, :includes => [:upload_video, :thumbnail, :upload_thumbnail]
end
