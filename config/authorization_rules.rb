authorization do
  role :guest do
    has_permission_on :assets, :to => :read
  end

  role :user do
    includes :guest
    has_permission_on :assets, :to => [:create, :update]
  end

  role :admin do
    includes :user
    has_permission_on :assets, :to => :destroy
  end
end

privileges do
  privilege :read, :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
end