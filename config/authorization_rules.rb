authorization do
  role :guest do
    has_permission_on :assets, :to => :read
    has_permission_on :instantiations, :to => :read
  end

  role :user do
    includes :guest
    has_permission_on :assets, :to => [:create, :update]
    has_permission_on :instantiations, :to => [:create, :update]
    has_permission_on :users, :to => [:show, :update] do
      if_attribute :id => is { user.id }
    end
  end

  role :admin do
    includes :user
    has_permission_on :assets, :to => :destroy
    has_permission_on :instantiations, :to => [:destroy, :borrow]
    has_permission_on :users, :to => :crud
    has_permission_on :picklists, :to => :crud
    PicklistsController::SUBCLASSES.each do |kl|
      has_permission_on kl.to_sym, :to => :crud
    end
  end
end

privileges do
  privilege :read, :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :borrow, :includes => [:borrowings, :return]
  privilege :crud, :includes => [:create, :read, :update, :destroy]
end