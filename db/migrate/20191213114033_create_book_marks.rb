class CreateBookMarks < ActiveRecord::Migration[5.2]
  def change
    create_table :book_marks do |t|
      t.belongs_to :app_user
      t.belongs_to :hit_product, foreign_key: true

      t.timestamps
    end
  end
end
