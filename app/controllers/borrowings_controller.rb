class BorrowingsController < ApplicationController
  filter_access_to :all

  def index
    @borrowings = Borrowing.find_all_by_returned(nil)
  end
end
