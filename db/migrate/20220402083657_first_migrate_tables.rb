class FirstMigrateTables < ActiveRecord::Migration[7.0]

  def change

    create_table :line_user do |t|
      t.bigint :line_user_id
      t.string :display_name
      t.timestamps
    end

    create_table :saunas do |t|
      t.string  :name
      t.string  :lat
      t.string  :lng
      t.integer :rating
      t.text    :note
      t.timestamps
    end

  end
end
