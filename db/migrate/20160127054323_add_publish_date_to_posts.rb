class AddPublishDateToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :publish_date, :datetime
  end
end
