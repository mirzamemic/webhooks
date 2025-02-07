class CreateInitialSchema < ActiveRecord::Migration[8.0]
  def change
    create_customers_table
    create_subscriptions_table
    create_events_table
  end

  private

  def create_customers_table
    create_table :customers do |t|
      t.string :external_id, null: false
      t.string :email
      t.string :name

      t.timestamps
    end
    add_index :customers, :external_id, unique: true
  end

  def create_subscriptions_table
    create_table :subscriptions do |t|
      t.string :external_id, null: false
      t.string :status, default: "unpaid"
      t.references :customer, null: false, foreign_key: true

      t.timestamps
    end
    add_index :subscriptions, :external_id, unique: true
  end

  def create_events_table
    create_table :events do |t|
      t.string :type, null: false
      t.string :external_id, null: false
      t.string :name, null: false
      t.string :status, default: "pending", null: false
      t.column :payload, :jsonb

      t.timestamps
    end
    add_index :events, :external_id, unique: true
  end
end
