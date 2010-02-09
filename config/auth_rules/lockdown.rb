authorization do
  role :guest do
    # NO PERMISSIONS
  end

  role :user do
    includes :guest
    has_permission_on :assets, :to => [:read, :create, :update]
    has_permission_on :instantiations, :to => [:read, :create, :update]
    has_permission_on :last_used_ids, :to => :index
    has_permission_on :users, :to => [:show, :update] do
      if_attribute :id => is { user.id }
    end
  end

  role :admin do
    includes :user
    has_permission_on :assets, :to => [:destroy, :merge]
    has_permission_on :instantiations, :to => [:destroy, :borrow]
    has_permission_on :users, :to => :crud
    has_permission_on :users, :to => :make_admin do
      if_attribute :id => is_not { user.id }
    end
    has_permission_on :picklists, :to => :crud
    PicklistsController::SUBCLASSES.each do |kl|
      has_permission_on kl.to_sym, :to => :crud
    end
    has_permission_on :borrowings, :to => :index
    has_permission_on :assets, :to => :multilend
    has_permission_on :assets, :to => :destroy_found_set
  end
end

privileges do
  privilege :read, :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :borrow, :includes => [:borrowings, :return]
  privilege :crud, :includes => [:create, :read, :update, :destroy]
  privilege :merge, :includes => :multiprocess
end
